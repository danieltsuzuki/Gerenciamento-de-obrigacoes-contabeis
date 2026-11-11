import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
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

class MockObligationRepository implements ObligationRepository {
  Obligation? obligationToReturn;
  ApiException? errorToThrow;
  int updateStatusCalls = 0;
  ObligationStatus? lastUpdatedStatus;
  int? lastUpdatedId;

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
        );
  }

  @override
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async {
    updateStatusCalls++;
    lastUpdatedId = id;
    lastUpdatedStatus = newStatus;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

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

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Fluxo de Alteração de Status - SPEC-020', () {
    late MockObligationRepository mockObligationRepo;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController authController;

    setUp(() {
      mockObligationRepo = MockObligationRepository();
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
          obligationId: obligation.id,
          initialObligation: obligation,
          authController: authController,
        ),
      );
    }

    testWidgets('PENDING: deve apresentar ação Iniciar e transicionar para IN_PROGRESS',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      // Botão Iniciar deve estar visível
      final startBtn = find.byKey(const Key('obligation-detail-start-action'));
      expect(startBtn, findsOneWidget);
      expect(find.byKey(const Key('obligation-detail-complete-action')), findsNothing);

      await tester.tap(startBtn);
      await tester.pumpAndSettle();

      // Diálogo de confirmação
      expect(find.text('Iniciar Obrigação'), findsWidgets);
      expect(find.textContaining('Confirma o início da obrigação?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm-start-status')));
      await tester.pumpAndSettle();

      expect(mockObligationRepo.updateStatusCalls, 1);
      expect(mockObligationRepo.lastUpdatedId, 10);
      expect(mockObligationRepo.lastUpdatedStatus, ObligationStatus.inProgress);
      expect(find.text('Obrigação iniciada com sucesso!'), findsOneWidget);
      expect(find.text('Em Andamento'), findsOneWidget);
    });

    testWidgets('IN_PROGRESS: deve apresentar ação Concluir e transicionar para COMPLETED',
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
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      // Botão Concluir deve estar visível
      final completeBtn = find.byKey(const Key('obligation-detail-complete-action'));
      expect(completeBtn, findsOneWidget);
      expect(find.byKey(const Key('obligation-detail-start-action')), findsNothing);

      await tester.tap(completeBtn);
      await tester.pumpAndSettle();

      // Diálogo de confirmação
      expect(find.text('Concluir Obrigação'), findsWidgets);
      expect(find.textContaining('Atenção: ao concluir esta obrigação'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm-complete-status')));
      await tester.pumpAndSettle();

      expect(mockObligationRepo.updateStatusCalls, 1);
      expect(mockObligationRepo.lastUpdatedId, 10);
      expect(mockObligationRepo.lastUpdatedStatus, ObligationStatus.completed);
      expect(find.text('Obrigação concluída com sucesso!'), findsOneWidget);
      expect(find.text('Concluída'), findsOneWidget);
    });

    testWidgets('COMPLETED: não deve apresentar ação de alteração de status nem de edição',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.completed,
        dueDate: DateTime(2026, 12, 15),
        completedAt: DateTime(2026, 11, 10),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('obligation-detail-start-action')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-complete-action')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-edit-button')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-edit-action')), findsNothing);
      expect(find.text('Obrigação Concluída com Sucesso'), findsOneWidget);
    });

    testWidgets('deve manter status intacto ao cancelar o diálogo de confirmação',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('obligation-detail-start-action')));
      await tester.pumpAndSettle();

      // Clica em Cancelar
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(mockObligationRepo.updateStatusCalls, 0);
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('deve tratar 422 INVALID_STATUS_TRANSITION sem corromper estado local',
        (tester) async {
      await signIn();

      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;
      mockObligationRepo.errorToThrow = const ApiException(
        statusCode: 422,
        code: 'INVALID_STATUS_TRANSITION',
        message: 'Transição não permitida.',
      );

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('obligation-detail-start-action')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm-start-status')));
      await tester.pumpAndSettle();

      expect(mockObligationRepo.updateStatusCalls, 1);
      // Mensagem amigável de erro
      expect(find.textContaining('Transição de status não permitida pelas regras de negócio (RN-008).'), findsOneWidget);
      // Estado local permanece intacto
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('não deve exibir botões de status quando usuário estiver deslogado',
        (tester) async {
      final ob = Obligation(
        id: 10,
        title: 'Declaração DCTF',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 15),
        company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
        responsible: const ObligationParticipantSummary(id: 2, name: 'Carlos Silva'),
      );
      mockObligationRepo.obligationToReturn = ob;

      await tester.pumpWidget(createWidgetUnderTest(ob));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('obligation-detail-start-action')), findsNothing);
      expect(find.byKey(const Key('obligation-detail-complete-action')), findsNothing);
    });
  });
}

