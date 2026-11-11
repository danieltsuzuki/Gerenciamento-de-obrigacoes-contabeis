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
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_detail_page.dart';
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_form_page.dart';

class MockResponsibleRepository implements ResponsibleRepository {
  Responsible? responsibleToReturn;
  bool shouldThrow = false;
  int getByIdCalls = 0;

  @override
  Future<Responsible> getResponsibleById(int id) async {
    getByIdCalls++;
    if (shouldThrow) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'Responsável não encontrado.',
      );
    }
    return responsibleToReturn ??
        Responsible(
          id: id,
          name: 'Carlos Alberto',
          email: 'carlos@empresa.com',
          active: true,
        );
  }

  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
    String? q,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async =>
      throw UnimplementedError();
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ResponsibleDetailPage - SPEC-017', () {
    late MockResponsibleRepository mockRepo;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController authController;

    setUp(() {
      mockRepo = MockResponsibleRepository();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      authController = AuthSessionController(
        authRepository: FakeAuthRepository(),
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Widget createWidgetUnderTest({
      required int responsibleId,
      Responsible? initialResponsible,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ResponsibleDetailPage(
          repository: mockRepo,
          responsibleId: responsibleId,
          initialResponsible: initialResponsible,
          authController: authController,
        ),
      );
    }

    testWidgets('deve exibir informações completas do responsável com initialResponsible',
        (tester) async {
      const resp = Responsible(
        id: 7,
        name: 'Mariana Duarte',
        email: 'mariana@contabilidade.com',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        responsibleId: 7,
        initialResponsible: resp,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Detalhes do Responsável'), findsOneWidget);
      expect(find.text('Mariana Duarte'), findsWidgets);
      expect(find.text('mariana@contabilidade.com'), findsWidgets);
      expect(find.text('Ativo'), findsOneWidget);
      expect(find.text('#7'), findsOneWidget);
      expect(
        find.text('Ativo — Pode ser vinculado a novas obrigações'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('responsible-detail-edit-button')), findsNothing);
      expect(find.byKey(const Key('responsible-detail-edit-action')), findsNothing);
    });

    testWidgets('não deve exibir botão de editar responsável quando usuário não estiver autenticado',
        (tester) async {
      const resp = Responsible(
        id: 7,
        name: 'Mariana Duarte',
        email: 'mariana@contabilidade.com',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        responsibleId: 7,
        initialResponsible: resp,
      ));
      await tester.pumpAndSettle();

      expect(authController.isAuthenticated, isFalse);
      expect(find.byKey(const Key('responsible-detail-edit-button')), findsNothing);
      expect(find.byKey(const Key('responsible-detail-edit-action')), findsNothing);
    });

    testWidgets('deve buscar dados do responsável via API quando initialResponsible for nulo',
        (tester) async {
      mockRepo.responsibleToReturn = const Responsible(
        id: 12,
        name: 'Roberto Souza',
        email: 'roberto@contabilidade.com',
        active: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(responsibleId: 12));
      await tester.pumpAndSettle();

      expect(mockRepo.getByIdCalls, 1);
      expect(find.text('Roberto Souza'), findsWidgets);
      expect(find.text('roberto@contabilidade.com'), findsWidgets);
      expect(find.text('Inativo'), findsOneWidget);
      expect(
        find.text('Inativo — Não recebe novas obrigações (RN-005)'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir ErrorStateView e permitir recarregar quando API falhar',
        (tester) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(createWidgetUnderTest(responsibleId: 99));
      await tester.pumpAndSettle();

      expect(find.text('Responsável não encontrado.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      mockRepo.shouldThrow = false;
      mockRepo.responsibleToReturn = const Responsible(
        id: 99,
        name: 'Recuperado Silva',
        email: 'recuperado@empresa.com',
        active: true,
      );

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Recuperado Silva'), findsWidgets);
    });

    testWidgets('deve abrir formulário de edição ao clicar no botão de editar autenticado',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      const resp = Responsible(
        id: 5,
        name: 'Juliana Paes',
        email: 'juliana@empresa.com',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        responsibleId: 5,
        initialResponsible: resp,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('responsible-detail-edit-button')), findsOneWidget);
      expect(find.byKey(const Key('responsible-detail-edit-action')), findsOneWidget);

      await tester.tap(find.byKey(const Key('responsible-detail-edit-button')));
      await tester.pumpAndSettle();

      expect(find.byType(ResponsibleFormPage), findsOneWidget);
      expect(find.text('Editar Responsável'), findsOneWidget);
      expect(find.text('Juliana Paes'), findsWidgets);
    });
  });
}
