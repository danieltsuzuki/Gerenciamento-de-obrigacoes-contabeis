import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/downloaded_file.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/attachment/domain/entities/attachment.dart';
import 'package:player_contabilidade_front/features/attachment/domain/repositories/attachment_repository.dart';
import 'package:player_contabilidade_front/features/attachment/domain/services/file_saver_service.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation_status_history.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_detail_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

class MockAttachmentRepository implements AttachmentRepository {
  List<Attachment> attachments = [];
  DownloadedFile? fileToReturn;
  ApiException? errorToThrow;
  int downloadCalls = 0;
  int? lastDownloadedAttachmentId;
  Completer<DownloadedFile>? downloadCompleter;

  @override
  Future<List<Attachment>> getAttachments(int obligationId) async {
    return List<Attachment>.from(attachments);
  }

  @override
  Future<DownloadedFile> downloadAttachment(int attachmentId) async {
    downloadCalls++;
    lastDownloadedAttachmentId = attachmentId;

    if (downloadCompleter != null) {
      return downloadCompleter!.future;
    }

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return fileToReturn ??
        DownloadedFile(
          filename: 'comprovante.pdf',
          bytes: Uint8List.fromList([1, 2, 3, 4]),
          contentType: 'application/pdf',
        );
  }

  @override
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  }) async =>
      throw UnimplementedError();
}

class MockObligationRepository implements ObligationRepository {
  Obligation? obligationToReturn;

  @override
  Future<Obligation> getObligationById(int id) async {
    return obligationToReturn ??
        Obligation(
          id: id,
          title: 'DAS Mensal',
          status: ObligationStatus.pending,
          dueDate: DateTime(2026, 12, 10),
          company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
          responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
          attachmentCount: 1,
        );
  }

  @override
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async =>
      throw UnimplementedError();

  @override
  Future<PageResponse<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    String? dueFrom,
    String? dueTo,
    String? q,
    int page = 0,
    int size = 20,
    String sort = 'dueDate,asc',
  }) async =>
      throw UnimplementedError();

  @override
  Future<Obligation> createObligation(CreateObligationRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Obligation> updateObligation(int id, UpdateObligationRequest request) async =>
      throw UnimplementedError();

  @override
  Future<List<ObligationStatusHistory>> getObligationHistory(int id) async => [];
}

class MockFileSaverService implements FileSaverService {
  DownloadedFile? lastSavedFile;
  int saveCalls = 0;
  String? pathToReturn = 'C:\\Downloads\\comprovante.pdf';

  @override
  Future<String?> saveAndOpenFile(DownloadedFile file) async {
    saveCalls++;
    lastSavedFile = file;
    return pathToReturn;
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Download e Abertura de Anexos - SPEC-022', () {
    late MockObligationRepository mockObligationRepo;
    late MockAttachmentRepository mockAttachmentRepo;
    late MockFileSaverService mockSaverService;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController authController;

    setUp(() {
      mockObligationRepo = MockObligationRepository();
      mockAttachmentRepo = MockAttachmentRepository();
      mockSaverService = MockFileSaverService();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      authController = AuthSessionController(
        authRepository: FakeAuthRepository(),
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Future<void> signIn() async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();
    }

    Widget createWidgetUnderTest(Obligation obligation) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ObligationDetailPage(
          repository: mockObligationRepo,
          attachmentRepository: mockAttachmentRepo,
          fileSaverService: mockSaverService,
          obligationId: obligation.id,
          initialObligation: obligation,
          authController: authController,
        ),
      );
    }

    testWidgets('deve baixar e abrir o anexo com sucesso utilizando o identificador correto',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'DAS Mensal',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 10),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 1,
      );

      mockAttachmentRepo.attachments = [
        Attachment(
          id: 42,
          obligationId: 10,
          name: 'recibo_das.pdf',
          contentType: 'application/pdf',
          size: 2048,
          uploadedAt: DateTime(2026, 11, 10, 10, 0),
        ),
      ];

      mockAttachmentRepo.fileToReturn = DownloadedFile(
        filename: 'recibo_das.pdf',
        bytes: Uint8List.fromList([10, 20, 30]),
        contentType: 'application/pdf',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      expect(find.text('recibo_das.pdf'), findsOneWidget);

      final downloadBtn = find.byKey(const Key('attachment-download-button-42'));
      await tester.ensureVisible(downloadBtn);
      await tester.pumpAndSettle();
      await tester.tap(downloadBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.downloadCalls, 1);
      expect(mockAttachmentRepo.lastDownloadedAttachmentId, 42);
      expect(mockSaverService.saveCalls, 1);
      expect(mockSaverService.lastSavedFile?.filename, 'recibo_das.pdf');
      expect(find.textContaining('recibo_das.pdf" baixado com sucesso!'), findsOneWidget);
    });

    testWidgets('deve exibir indicador de progresso durante o download e evitar cliques duplicados',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'DAS Mensal',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 10),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 1,
      );

      mockAttachmentRepo.attachments = [
        Attachment(
          id: 101,
          obligationId: 10,
          name: 'relatorio.xlsx',
          contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          size: 5120,
          uploadedAt: DateTime(2026, 11, 10, 10, 0),
        ),
      ];

      final completer = Completer<DownloadedFile>();
      mockAttachmentRepo.downloadCompleter = completer;

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final downloadBtn = find.byKey(const Key('attachment-download-button-101'));
      await tester.ensureVisible(downloadBtn);
      await tester.pumpAndSettle();
      await tester.tap(downloadBtn);
      await tester.pump(); // Inicia requisição e atualiza UI com o spinner

      expect(find.byKey(const Key('attachment-download-spinner')), findsOneWidget);

      // Segundo clique durante o download não deve duplicar a requisição
      expect(mockAttachmentRepo.downloadCalls, 1);

      completer.complete(
        DownloadedFile(
          filename: 'relatorio.xlsx',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('attachment-download-spinner')), findsNothing);
      expect(find.byKey(const Key('attachment-download-button-101')), findsOneWidget);
    });

    testWidgets('deve exibir feedback amigável para erro 404 NOT_FOUND sem bloquear a tela',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'DAS Mensal',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 10),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 1,
      );

      mockAttachmentRepo.attachments = [
        Attachment(
          id: 999,
          obligationId: 10,
          name: 'arquivo_inexistente.pdf',
          contentType: 'application/pdf',
          size: 1024,
          uploadedAt: DateTime(2026, 11, 10, 10, 0),
        ),
      ];

      mockAttachmentRepo.errorToThrow = const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'Anexo não encontrado.',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final downloadBtn = find.byKey(const Key('attachment-download-button-999'));
      await tester.ensureVisible(downloadBtn);
      await tester.pumpAndSettle();
      await tester.tap(downloadBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.downloadCalls, 1);
      expect(find.text('Arquivo ou anexo não encontrado no servidor.'), findsOneWidget);
      // Tela permanece interativa e lista de anexos intacta
      expect(find.text('arquivo_inexistente.pdf'), findsOneWidget);
    });

    testWidgets('deve exibir feedback para erro 500 STORAGE_ERROR sem travar a interface',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'DAS Mensal',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 10),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 1,
      );

      mockAttachmentRepo.attachments = [
        Attachment(
          id: 888,
          obligationId: 10,
          name: 'documento_corrompido.xml',
          contentType: 'application/xml',
          size: 2048,
          uploadedAt: DateTime(2026, 11, 10, 10, 0),
        ),
      ];

      mockAttachmentRepo.errorToThrow = const ApiException(
        statusCode: 500,
        code: 'STORAGE_ERROR',
        message: 'Falha de I/O no disco do servidor.',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final downloadBtn = find.byKey(const Key('attachment-download-button-888'));
      await tester.ensureVisible(downloadBtn);
      await tester.pumpAndSettle();
      await tester.tap(downloadBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.downloadCalls, 1);
      expect(find.text('Erro no armazenamento do servidor ao recuperar o arquivo.'), findsOneWidget);
    });

    test('DefaultFileSaverService salva e retorna caminho sem travar', () async {
      final service = const DefaultFileSaverService();
      final res = await service.saveAndOpenFile(
        DownloadedFile(
          filename: 'teste.pdf',
          bytes: Uint8List.fromList([1, 2]),
          contentType: 'application/pdf',
        ),
      );
      expect(res, contains('teste.pdf'));
    });

    test('DefaultFileSaverService delega para customSaver quando informado', () async {
      bool customCalled = false;
      final service = DefaultFileSaverService(
        customSaver: (file) async {
          customCalled = true;
          return '/custom/path/${file.filename}';
        },
      );

      final res = await service.saveAndOpenFile(
        DownloadedFile(
          filename: 'guia.pdf',
          bytes: Uint8List.fromList([1, 2]),
          contentType: 'application/pdf',
        ),
      );

      expect(customCalled, isTrue);
      expect(res, '/custom/path/guia.pdf');
    });

    test('DownloadedFile extrai nome do arquivo a partir do header Content-Disposition', () {
      expect(
        DownloadedFile.extractFilenameFromHeader('attachment; filename="recibo.pdf"'),
        'recibo.pdf',
      );
      expect(
        DownloadedFile.extractFilenameFromHeader('attachment; filename=relatorio.xlsx'),
        'relatorio.xlsx',
      );
      expect(
        DownloadedFile.extractFilenameFromHeader(null, fallback: 'padrao.bin'),
        'padrao.bin',
      );
    });
  });
}
