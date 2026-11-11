import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/downloaded_file.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/attachment/domain/entities/attachment.dart';
import 'package:player_contabilidade_front/features/attachment/domain/repositories/attachment_repository.dart';
import 'package:player_contabilidade_front/features/attachment/domain/services/file_picker_service.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_detail_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

class MockFilePickerService implements FilePickerService {
  SelectedFile? fileToReturn;
  bool wasCalled = false;

  @override
  Future<SelectedFile?> pickFile({
    BuildContext? context,
    List<String>? allowedExtensions,
  }) async {
    wasCalled = true;
    return fileToReturn;
  }
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
          attachmentCount: 0,
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
}

class MockAttachmentRepository implements AttachmentRepository {
  List<Attachment> attachments = [];
  ApiException? errorToThrow;
  int uploadCalls = 0;
  String? lastUploadedFilename;
  int? lastUploadedObligationId;

  @override
  Future<List<Attachment>> getAttachments(int obligationId) async {
    return List<Attachment>.from(attachments);
  }

  @override
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  }) async {
    uploadCalls++;
    lastUploadedObligationId = obligationId;
    lastUploadedFilename = filename;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    final newAtt = Attachment(
      id: attachments.length + 1,
      obligationId: obligationId,
      name: filename,
      contentType: contentType ?? 'application/pdf',
      size: bytes.length,
      uploadedAt: DateTime(2026, 11, 10, 15, 0),
    );
    return newAtt;
  }

  @override
  Future<DownloadedFile> downloadAttachment(int attachmentId) async =>
      throw UnimplementedError();
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Seleção e Envio de Anexos - SPEC-021', () {
    late MockObligationRepository mockObligationRepo;
    late MockAttachmentRepository mockAttachmentRepo;
    late MockFilePickerService mockPickerService;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController authController;

    setUp(() {
      mockObligationRepo = MockObligationRepository();
      mockAttachmentRepo = MockAttachmentRepository();
      mockPickerService = MockFilePickerService();
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
          filePickerService: mockPickerService,
          obligationId: obligation.id,
          initialObligation: obligation,
          authController: authController,
        ),
      );
    }

    testWidgets('deve selecionar e enviar anexo com sucesso, atualizando lista e contador',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 0,
      );
      mockObligationRepo.obligationToReturn = ob;

      final fileBytes = utf8.encode('Conteudo de teste do documento');
      mockPickerService.fileToReturn = SelectedFile(
        filename: 'comprovante_dctf.pdf',
        bytes: fileBytes,
        size: fileBytes.length,
        mimeType: 'application/pdf',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final addBtn = find.byKey(const Key('obligation-detail-add-attachment-button'));
      expect(addBtn, findsOneWidget);

      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(mockPickerService.wasCalled, isTrue);
      expect(mockAttachmentRepo.uploadCalls, 1);
      expect(mockAttachmentRepo.lastUploadedObligationId, 10);
      expect(mockAttachmentRepo.lastUploadedFilename, 'comprovante_dctf.pdf');

      // Verifica feedback de sucesso
      expect(find.text('Documento "comprovante_dctf.pdf" anexado com sucesso!'), findsOneWidget);

      // Verifica item renderizado na lista com metadados
      expect(find.text('comprovante_dctf.pdf'), findsOneWidget);
      expect(find.textContaining('Documentos Anexados (1)'), findsOneWidget);
      expect(find.textContaining('1 anexos registrados no servidor'), findsOneWidget);
    });

    testWidgets('deve rejeitar arquivo vazio (0 bytes) e não chamar o repositório',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 0,
      );

      mockPickerService.fileToReturn = const SelectedFile(
        filename: 'vazio.pdf',
        bytes: [],
        size: 0,
        mimeType: 'application/pdf',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final addBtn = find.byKey(const Key('obligation-detail-add-attachment-button'));
      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.uploadCalls, 0);
      expect(find.text('Não é permitido enviar arquivo vazio (0 bytes).'), findsOneWidget);
    });

    testWidgets('deve rejeitar arquivo que excede 10 MB e não chamar o repositório',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 0,
      );

      const excessSize = 11 * 1024 * 1024; // 11 MB
      mockPickerService.fileToReturn = SelectedFile(
        filename: 'arquivo_muito_grande.pdf',
        bytes: List<int>.filled(100, 1),
        size: excessSize,
        mimeType: 'application/pdf',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final addBtn = find.byKey(const Key('obligation-detail-add-attachment-button'));
      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.uploadCalls, 0);
      expect(find.textContaining('O arquivo excede o limite máximo permitido de 10 MB'), findsOneWidget);
    });

    testWidgets('deve tratar falha da API de upload exibindo SnackBar de erro sem corromper lista',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 0,
      );

      mockAttachmentRepo.errorToThrow = const ApiException(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Tipo de arquivo não permitido.',
      );

      final fileBytes = utf8.encode('script.exe');
      mockPickerService.fileToReturn = SelectedFile(
        filename: 'script.exe',
        bytes: fileBytes,
        size: fileBytes.length,
        mimeType: 'application/x-msdownload',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final addBtn = find.byKey(const Key('obligation-detail-add-attachment-button'));
      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.uploadCalls, 1);
      expect(find.textContaining('Falha ao enviar anexo: Tipo de arquivo não permitido.'), findsOneWidget);
    });

    testWidgets('deve tratar cancelamento da seleção de arquivo sem realizar requisição',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );

      mockPickerService.fileToReturn = null; // Usuário cancelou

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      final addBtn = find.byKey(const Key('obligation-detail-add-attachment-button'));
      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(mockPickerService.wasCalled, isTrue);
      expect(mockAttachmentRepo.uploadCalls, 0);
    });

    test('detectMimeType deve mapear extensões para os tipos MIME corretos', () {
      expect(detectMimeType('documento.pdf'), 'application/pdf');
      expect(detectMimeType('foto.PNG'), 'image/png');
      expect(detectMimeType('foto.jpg'), 'image/jpeg');
      expect(detectMimeType('foto.jpeg'), 'image/jpeg');
      expect(detectMimeType('nfe.xml'), 'application/xml');
      expect(detectMimeType('planilha.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      expect(detectMimeType('planilha.xls'), 'application/vnd.ms-excel');
      expect(detectMimeType('dados.csv'), 'text/plain');
      expect(detectMimeType('arquivo.zip'), 'application/zip');
      expect(detectMimeType('desconhecido.bin'), 'application/octet-stream');
    });

    testWidgets('DefaultFilePickerService deve invocar seletor de arquivos diretamente sem abrir modal',
        (tester) async {
      bool customPickerCalled = false;
      final picker = DefaultFilePickerService(
        customPicker: () async {
          customPickerCalled = true;
          return const SelectedFile(
            filename: 'documento_direto.pdf',
            bytes: [1, 2, 3],
            size: 3,
            mimeType: 'application/pdf',
          );
        },
      );

      final result = await picker.pickFile();
      expect(customPickerCalled, isTrue);
      expect(result, isNotNull);
      expect(result!.filename, 'documento_direto.pdf');
    });
  });
}
