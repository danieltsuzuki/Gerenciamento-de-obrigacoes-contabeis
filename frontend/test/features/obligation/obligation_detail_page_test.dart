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
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_detail_page.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_form_page.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';

class MockObligationRepository implements ObligationRepository {
  Obligation? obligationToReturn;
  bool shouldThrow = false;
  int getByIdCalls = 0;
  ObligationStatus? lastUpdatedStatus;
  int updateStatusCalls = 0;

  @override
  Future<Obligation> getObligationById(int id) async {
    getByIdCalls++;
    if (shouldThrow) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'Obrigação não encontrada.',
      );
    }
    return obligationToReturn ??
        Obligation(
          id: id,
          title: 'DAS Mensal',
          description: 'Recolhimento do Simples Nacional',
          status: ObligationStatus.pending,
          dueDate: DateTime(2026, 12, 10),
          company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
          responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
          attachmentCount: 2,
        );
  }

  @override
  Future<PageResponse<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
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
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async {
    updateStatusCalls++;
    lastUpdatedStatus = newStatus;
    final current = obligationToReturn ??
        Obligation(
          id: id,
          title: 'DAS Mensal',
          status: ObligationStatus.pending,
          dueDate: DateTime(2026, 12, 10),
          company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
          responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        );

    final updated = Obligation(
      id: current.id,
      title: current.title,
      description: current.description,
      status: newStatus,
      dueDate: current.dueDate,
      createdAt: current.createdAt,
      completedAt: newStatus == ObligationStatus.completed ? DateTime(2026, 11, 10) : current.completedAt,
      company: current.company,
      responsible: current.responsible,
      attachmentCount: current.attachmentCount,
    );
    obligationToReturn = updated;
    return updated;
  }
}

class MockAttachmentRepository implements AttachmentRepository {
  List<Attachment> attachmentsToReturn = [];
  bool shouldThrow = false;
  int downloadCalls = 0;

  @override
  Future<List<Attachment>> getAttachments(int obligationId) async {
    if (shouldThrow) {
      throw const ApiException(
        statusCode: 500,
        code: 'STORAGE_ERROR',
        message: 'Erro ao carregar anexos do storage.',
      );
    }
    return attachmentsToReturn;
  }

  @override
  Future<Attachment> uploadAttachment({
    required int obligationId,
    required String filename,
    required List<int> bytes,
    String? contentType,
  }) async =>
      throw UnimplementedError();

  @override
  Future<DownloadedFile> downloadAttachment(int attachmentId) async {
    downloadCalls++;
    return DownloadedFile(
      filename: 'comprovante.pdf',
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      contentType: 'application/pdf',
    );
  }
}

class MockCompanyRepository implements CompanyRepository {
  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    return PageResponse<Company>(
      content: [
        const Company(id: 1, legalName: 'Empresa Alpha', cnpj: '33000167000101', active: true),
      ],
      totalElements: 1,
      totalPages: 1,
      size: 20,
      number: 0,
      first: true,
      last: true,
      empty: false,
    );
  }

  @override
  Future<Company> getCompanyById(int id) async => throw UnimplementedError();
  @override
  Future<Company> createCompany(CreateCompanyRequest request) async => throw UnimplementedError();
  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async => throw UnimplementedError();
}

class MockResponsibleRepository implements ResponsibleRepository {
  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    return PageResponse<Responsible>(
      content: [
        const Responsible(id: 2, name: 'Carlos Silva', email: 'carlos@empresa.com', active: true),
      ],
      totalElements: 1,
      totalPages: 1,
      size: 20,
      number: 0,
      first: true,
      last: true,
      empty: false,
    );
  }

  @override
  Future<Responsible> getResponsibleById(int id) async => throw UnimplementedError();
  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) async => throw UnimplementedError();
  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async => throw UnimplementedError();
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ObligationDetailPage - SPEC-019', () {
    late MockObligationRepository mockObligationRepo;
    late MockAttachmentRepository mockAttachmentRepo;
    late MockCompanyRepository mockCompanyRepo;
    late MockResponsibleRepository mockResponsibleRepo;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController authController;

    setUp(() {
      mockObligationRepo = MockObligationRepository();
      mockAttachmentRepo = MockAttachmentRepository();
      mockCompanyRepo = MockCompanyRepository();
      mockResponsibleRepo = MockResponsibleRepository();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      authController = AuthSessionController(
        authRepository: FakeAuthRepository(),
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Widget createWidgetUnderTest({
      required int obligationId,
      Obligation? initialObligation,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ObligationDetailPage(
          repository: mockObligationRepo,
          attachmentRepository: mockAttachmentRepo,
          companyRepository: mockCompanyRepo,
          responsibleRepository: mockResponsibleRepo,
          obligationId: obligationId,
          initialObligation: initialObligation,
          authController: authController,
        ),
      );
    }

    testWidgets('deve exibir dados da obrigação e NÃO exibir botões de status, edição ou card de anexos quando deslogado',
        (tester) async {
      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        description: 'Instruções DCTF Mensal',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 15),
        createdAt: DateTime(2026, 11, 1),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 3,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        obligationId: 10,
        initialObligation: ob,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Detalhes da Obrigação'), findsOneWidget);
      expect(find.text('Declaração DCTF'), findsOneWidget);
      expect(find.text('Instruções DCTF Mensal'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Empresa Alpha'), findsOneWidget);
      expect(find.text('Carlos Silva'), findsOneWidget);
      expect(find.text('#10'), findsOneWidget);
      expect(find.textContaining('3 anexos registrados no servidor'), findsOneWidget);

      // Botões de ação de status NÃO devem ser visíveis quando deslogado
      expect(find.byKey(const Key('obligation-detail-start-action')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-complete-action')), findsNothing);

      // Card de anexos inferior NÃO deve ser exibido quando deslogado
      expect(find.textContaining('Documentos Anexados ('), findsNothing);

      // Botões de edição NÃO devem ser exibidos quando deslogado
      expect(find.byKey(const Key('obligation-detail-edit-button')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-edit-action')), findsNothing);
    });

    testWidgets('deve permitir iniciar obrigação com status PENDING após confirmação',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(
        obligationId: 10,
        initialObligation: ob,
      ));
      await tester.pumpAndSettle();

      final startButton = find.byKey(const Key('obligation-detail-start-action'));
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Confirmação no AlertDialog
      expect(find.text('Iniciar Obrigação'), findsWidgets);
      final confirmButton = find.byKey(const Key('confirm-start-status'));
      expect(confirmButton, findsOneWidget);

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(mockObligationRepo.updateStatusCalls, 1);
      expect(mockObligationRepo.lastUpdatedStatus, ObligationStatus.inProgress);
      expect(find.text('Obrigação iniciada com sucesso!'), findsOneWidget);
      expect(find.text('Em Andamento'), findsOneWidget);
    });

    testWidgets('deve permitir concluir obrigação com status IN_PROGRESS após confirmação',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(
        obligationId: 10,
        initialObligation: ob,
      ));
      await tester.pumpAndSettle();

      final completeButton = find.byKey(const Key('obligation-detail-complete-action'));
      expect(completeButton, findsOneWidget);

      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Confirmação no AlertDialog
      expect(find.text('Concluir Obrigação'), findsWidgets);
      final confirmButton = find.byKey(const Key('confirm-complete-status'));
      expect(confirmButton, findsOneWidget);

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(mockObligationRepo.updateStatusCalls, 1);
      expect(mockObligationRepo.lastUpdatedStatus, ObligationStatus.completed);
      expect(find.text('Obrigação concluída com sucesso!'), findsOneWidget);
      expect(find.text('Concluída'), findsOneWidget);
    });

    testWidgets('deve exibir lista de anexos e permitir acionar download quando autenticado',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      mockAttachmentRepo.attachmentsToReturn = [
        Attachment(
          id: 1,
          obligationId: 10,
          name: 'recibo_entrega.pdf',
          contentType: 'application/pdf',
          size: 1024 * 250, // 250 KB
          uploadedAt: DateTime(2026, 11, 5, 14, 30),
        ),
      ];

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
        attachmentCount: 1,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        obligationId: 10,
        initialObligation: ob,
      ));
      await tester.pumpAndSettle();

      expect(find.text('recibo_entrega.pdf'), findsOneWidget);
      expect(find.textContaining('250.0 KB'), findsOneWidget);

      final downloadBtn = find.byTooltip('Baixar arquivo');
      expect(downloadBtn, findsOneWidget);

      await tester.ensureVisible(downloadBtn);
      await tester.pumpAndSettle();

      await tester.tap(downloadBtn);
      await tester.pumpAndSettle();

      expect(mockAttachmentRepo.downloadCalls, 1);
      expect(find.textContaining('baixado com sucesso'), findsOneWidget);
    });

    testWidgets('não deve exibir botão de editar e deve exibir aviso terminal se obrigação for COMPLETED (RN-009)',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      final completedOb = Obligation(
        id: 10,
        title: 'Declaração DCTF Concluída',
        status: ObligationStatus.completed,
        dueDate: DateTime(2026, 11, 10),
        completedAt: DateTime(2026, 11, 9, 10, 0),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        obligationId: 10,
        initialObligation: completedOb,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Concluída'), findsOneWidget);
      expect(find.text('Obrigação Concluída com Sucesso'), findsOneWidget);
      expect(find.byKey(const Key('obligation-detail-edit-button')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-edit-action')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-start-action')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-complete-action')), findsNothing);
    });

    testWidgets('deve exibir botão de editar e abrir ObligationFormPage quando autenticado e status não concluído',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        obligationId: 10,
        initialObligation: ob,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('obligation-detail-edit-button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('obligation-detail-edit-button')));
      await tester.pumpAndSettle();

      expect(find.byType(ObligationFormPage), findsOneWidget);
      expect(find.text('Editar Obrigação'), findsOneWidget);
    });
  });
}
