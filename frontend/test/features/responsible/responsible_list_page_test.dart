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
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_list_page.dart';

class MockResponsibleRepository implements ResponsibleRepository {
  List<Responsible> responsibles = [];
  bool? lastActiveFilter;
  bool shouldThrow = false;

  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    lastActiveFilter = active;
    if (shouldThrow) {
      throw const ApiException(
        statusCode: 500,
        code: 'NETWORK_ERROR',
        message: 'Falha ao buscar responsáveis.',
      );
    }

    final filtered = active == null
        ? responsibles
        : responsibles.where((r) => r.active == active).toList();

    return PageResponse<Responsible>(
      content: filtered,
      totalElements: filtered.length,
      totalPages: 1,
      size: 20,
      number: 0,
      first: true,
      last: true,
      empty: filtered.isEmpty,
    );
  }

  @override
  Future<Responsible> getResponsibleById(int id) async =>
      responsibles.firstWhere((r) => r.id == id);

  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) async {
    final resp = Responsible(
      id: responsibles.length + 1,
      name: request.name,
      email: request.email,
      active: request.active,
    );
    responsibles.add(resp);
    return resp;
  }

  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async {
    final index = responsibles.indexWhere((r) => r.id == id);
    final updated = Responsible(
      id: id,
      name: request.name,
      email: request.email,
      active: request.active,
    );
    if (index >= 0) {
      responsibles[index] = updated;
    }
    return updated;
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ResponsibleListPage - SPEC-017', () {
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

    Widget createWidgetUnderTest({AuthSessionController? customAuthController}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ResponsibleListPage(
          repository: mockRepo,
          authController: customAuthController ?? authController,
        ),
      );
    }

    testWidgets('deve renderizar lista de responsáveis com status e avatar', (tester) async {
      mockRepo.responsibles = [
        const Responsible(id: 1, name: 'Alice Santos', email: 'alice@empresa.com', active: true),
        const Responsible(id: 2, name: 'Bruno Lima', email: 'bruno@empresa.com', active: false),
      ];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Alice Santos'), findsOneWidget);
      expect(find.text('alice@empresa.com'), findsOneWidget);
      expect(find.text('Bruno Lima'), findsOneWidget);
      expect(find.text('bruno@empresa.com'), findsOneWidget);

      expect(find.text('Ativo'), findsOneWidget);
      expect(find.text('Inativo'), findsOneWidget);

      expect(find.byKey(const Key('responsible-card-1')), findsOneWidget);
      expect(find.byKey(const Key('responsible-card-2')), findsOneWidget);
    });

    testWidgets('deve filtrar responsáveis ao clicar nos chips de filtro', (tester) async {
      mockRepo.responsibles = [
        const Responsible(id: 1, name: 'Alice Santos', email: 'alice@empresa.com', active: true),
        const Responsible(id: 2, name: 'Bruno Lima', email: 'bruno@empresa.com', active: false),
      ];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar em Ativos
      await tester.tap(find.byKey(const Key('responsible-filter-active')));
      await tester.pumpAndSettle();

      expect(mockRepo.lastActiveFilter, isTrue);
      expect(find.text('Alice Santos'), findsOneWidget);
      expect(find.text('Bruno Lima'), findsNothing);

      // Clicar em Inativos
      await tester.tap(find.byKey(const Key('responsible-filter-inactive')));
      await tester.pumpAndSettle();

      expect(mockRepo.lastActiveFilter, isFalse);
      expect(find.text('Alice Santos'), findsNothing);
      expect(find.text('Bruno Lima'), findsOneWidget);

      // Clicar em Todos
      await tester.tap(find.byKey(const Key('responsible-filter-all')));
      await tester.pumpAndSettle();

      expect(mockRepo.lastActiveFilter, isNull);
      expect(find.text('Alice Santos'), findsOneWidget);
      expect(find.text('Bruno Lima'), findsOneWidget);
    });

    testWidgets('deve exibir EmptyStateView quando não houver responsáveis', (tester) async {
      mockRepo.responsibles = [];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum responsável encontrado'), findsOneWidget);
      expect(find.text('Novo Responsável'), findsWidgets);
    });

    testWidgets('deve exibir ErrorStateView e permitir retry quando a requisição falhar', (tester) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Falha ao buscar responsáveis.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      mockRepo.shouldThrow = false;
      mockRepo.responsibles = [
        const Responsible(id: 1, name: 'Alice Santos', email: 'alice@empresa.com', active: true),
      ];

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Alice Santos'), findsOneWidget);
    });

    testWidgets('deve abrir ResponsibleFormPage ao clicar no FAB', (tester) async {
      // Autenticar controller via session storage + initialize
      const session = AuthSession(
        token: 'token-abc',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('new-responsible-fab')));
      await tester.pumpAndSettle();

      expect(find.byType(ResponsibleFormPage), findsOneWidget);
      expect(find.text('Novo Responsável'), findsOneWidget);
    });

    testWidgets('deve abrir ResponsibleDetailPage ao clicar no card do responsável', (tester) async {
      mockRepo.responsibles = [
        const Responsible(id: 10, name: 'Carlos Alberto', email: 'carlos@empresa.com', active: true),
      ];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar no card/ListTile
      await tester.tap(find.text('Carlos Alberto'));
      await tester.pumpAndSettle();

      expect(find.byType(ResponsibleDetailPage), findsOneWidget);
      expect(find.text('Detalhes do Responsável'), findsOneWidget);
      expect(find.text('#10'), findsOneWidget);
    });

    testWidgets('deve abrir ResponsibleFormPage em modo edição ao clicar no botão de editar', (tester) async {
      const session = AuthSession(
        token: 'token-abc',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      mockRepo.responsibles = [
        const Responsible(id: 10, name: 'Carlos Alberto', email: 'carlos@empresa.com', active: true),
      ];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('responsible-edit-button-10')));
      await tester.pumpAndSettle();

      expect(find.byType(ResponsibleFormPage), findsOneWidget);
      expect(find.text('Editar Responsável'), findsOneWidget);
      expect(find.text('Carlos Alberto'), findsOneWidget);
    });
  });
}
