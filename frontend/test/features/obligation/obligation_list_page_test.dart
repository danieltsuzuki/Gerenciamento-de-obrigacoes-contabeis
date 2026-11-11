import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
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
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_list_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockObligationRepository implements ObligationRepository {
  List<Obligation> items = [];
  bool shouldThrow = false;
  String errorMessage = 'Falha ao buscar dados';
  ObligationStatus? lastFilterStatus;
  int callCount = 0;

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
  }) async {
    callCount++;
    lastFilterStatus = status;

    if (shouldThrow) {
      throw ApiException(statusCode: 500, code: 'SERVER_ERROR', message: errorMessage);
    }

    var filtered = items.where((o) {
      if (status != null && o.status != status) return false;
      if (companyId != null && o.company.id != companyId) return false;
      if (responsibleId != null && o.responsible.id != responsibleId) return false;
      if (q != null && q.isNotEmpty) {
        final query = q.toLowerCase();
        final matches = o.title.toLowerCase().contains(query) ||
            (o.description?.toLowerCase().contains(query) ?? false) ||
            o.company.name.toLowerCase().contains(query) ||
            o.responsible.name.toLowerCase().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();

    final total = filtered.length;
    final totalPages = (total / size).ceil() == 0 ? 1 : (total / size).ceil();
    final start = page * size;
    final pageContent = (start < total)
        ? filtered.sublist(start, (start + size) > total ? total : start + size)
        : <Obligation>[];

    return PageResponse<Obligation>(
      content: pageContent,
      totalElements: total,
      totalPages: totalPages,
      size: size,
      number: page,
      first: page == 0,
      last: page >= totalPages - 1,
      empty: pageContent.isEmpty,
    );
  }

  @override
  Future<Obligation> getObligationById(int id) async => throw UnimplementedError();

  @override
  Future<Obligation> createObligation(CreateObligationRequest request) async => throw UnimplementedError();

  @override
  Future<Obligation> updateObligation(int id, UpdateObligationRequest request) async => throw UnimplementedError();

  @override
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async => throw UnimplementedError();

  @override
  Future<List<ObligationStatusHistory>> getObligationHistory(int id) async => [];
}

void main() {
  final sampleObligation = Obligation(
    id: 1,
    title: 'DAS Mensal - Simples',
    description: 'Guia de recolhimento mensal',
    status: ObligationStatus.pending,
    dueDate: DateTime(2026, 11, 20),
    createdAt: DateTime(2026, 11, 1),
    company: const ObligationParticipantSummary(id: 10, name: 'Empresa Alpha Ltda'),
    responsible: const ObligationParticipantSummary(id: 20, name: 'Carlos Contador'),
    attachmentCount: 3,
  );

  Widget createWidgetUnderTest({
    required ObligationRepository repository,
    void Function(Obligation)? onObligationTap,
    AuthSessionController? authController,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ObligationListPage(
        repository: repository,
        onObligationTap: onObligationTap,
        authController: authController,
      ),
    );
  }

  group('ObligationListPage - SPEC-015', () {
    testWidgets('deve exibir lista com título, empresa, responsável, status, anexos e datas', (tester) async {
      final repository = MockObligationRepository()..items = [sampleObligation];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Obrigações Fiscais'), findsWidgets);
      expect(find.text('DAS Mensal - Simples'), findsOneWidget);
      expect(find.text('Empresa Alpha Ltda'), findsOneWidget);
      expect(find.text('Carlos Contador'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('3 anexos'), findsOneWidget);
      expect(find.text('Criada em: 01/11/2026'), findsOneWidget);
      expect(find.text('Vencimento: 20/11/2026'), findsOneWidget);
    });

    testWidgets('deve exibir estado vazio quando não houver obrigações', (tester) async {
      final repository = MockObligationRepository()..items = [];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma obrigação encontrada'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('deve exibir estado de erro e permitir retry ao falhar a API', (tester) async {
      final repository = MockObligationRepository()..shouldThrow = true;

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Falha ao buscar dados'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      repository.shouldThrow = false;
      repository.items = [sampleObligation];

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('DAS Mensal - Simples'), findsOneWidget);
    });

    testWidgets('deve filtrar obrigações ao tocar nos chips de status', (tester) async {
      final inProgressObligation = Obligation(
        id: 2,
        title: 'DEFIS Anual',
        status: ObligationStatus.inProgress,
        dueDate: DateTime(2026, 12, 10),
        createdAt: DateTime(2026, 11, 2),
        company: const ObligationParticipantSummary(id: 10, name: 'Empresa Alpha Ltda'),
        responsible: const ObligationParticipantSummary(id: 20, name: 'Carlos Contador'),
        attachmentCount: 0,
      );

      final repository = MockObligationRepository()
        ..items = [sampleObligation, inProgressObligation];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('DAS Mensal - Simples'), findsOneWidget);
      expect(find.text('DEFIS Anual'), findsOneWidget);

      // Filtra por Em Andamento
      await tester.tap(find.byKey(const Key('filter-in-progress')));
      await tester.pumpAndSettle();

      expect(repository.lastFilterStatus, ObligationStatus.inProgress);
      expect(find.text('DAS Mensal - Simples'), findsNothing);
      expect(find.text('DEFIS Anual'), findsOneWidget);

      // Volta para Todas
      await tester.tap(find.byKey(const Key('filter-all')));
      await tester.pumpAndSettle();

      expect(repository.lastFilterStatus, isNull);
      expect(find.text('DAS Mensal - Simples'), findsOneWidget);
      expect(find.text('DEFIS Anual'), findsOneWidget);
    });

    testWidgets('deve chamar callback onObligationTap ao selecionar um item', (tester) async {
      Obligation? tappedItem;
      final repository = MockObligationRepository()..items = [sampleObligation];

      await tester.pumpWidget(
        createWidgetUnderTest(
          repository: repository,
          onObligationTap: (item) => tappedItem = item,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('obligation-card-1')));
      await tester.pumpAndSettle();

      expect(tappedItem, isNotNull);
      expect(tappedItem!.id, 1);
      expect(tappedItem!.title, 'DAS Mensal - Simples');
    });

    testWidgets('deve navegar para detalhes da obrigação usando AppRoutes', (tester) async {
      final repository = MockObligationRepository()..items = [sampleObligation];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            AppRoutes.initial: (_) => ObligationListPage(repository: repository),
            AppRoutes.obligationDetails: (context) {
              final arg = ModalRoute.of(context)!.settings.arguments as Obligation;
              return Scaffold(
                appBar: AppBar(title: Text('Detalhe: ${arg.title}')),
              );
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('obligation-card-1')));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe: DAS Mensal - Simples'), findsOneWidget);
    });

    testWidgets('deve recarregar listagem ao acionar o botão de reload', (tester) async {
      final repository = MockObligationRepository()..items = [sampleObligation];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();
      expect(repository.callCount, 1);

      await tester.tap(find.byTooltip('Recarregar'));
      await tester.pumpAndSettle();
      expect(repository.callCount, 2);
    });

    testWidgets('SPEC-033: deve permitir pesquisar obrigações por título ou texto', (tester) async {
      final item2 = Obligation(
        id: 2,
        title: 'Folha de Pagamento',
        description: 'Cálculo de salários',
        status: ObligationStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        company: const ObligationParticipantSummary(id: 1, name: 'Alpha Tech'),
        responsible: const ObligationParticipantSummary(id: 1, name: 'Lucas Contábil'),
        attachmentCount: 0,
      );

      final repository = MockObligationRepository()..items = [sampleObligation, item2];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('DAS Mensal - Simples'), findsOneWidget);
      expect(find.text('Folha de Pagamento'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('obligation-search-field')), 'Folha');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Folha de Pagamento'), findsOneWidget);
      expect(find.text('DAS Mensal - Simples'), findsNothing);

      await tester.enterText(find.byKey(const Key('obligation-search-field')), 'SemResultado');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text("Nenhum resultado para 'SemResultado'"), findsOneWidget);

      await tester.tap(find.text('Limpar pesquisa'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('DAS Mensal - Simples'), findsOneWidget);
      expect(find.text('Folha de Pagamento'), findsOneWidget);
    });

    testWidgets('SPEC-032: deve exibir barra de paginação e navegar entre páginas de obrigações', (tester) async {
      final many = List.generate(
        15,
        (i) => Obligation(
          id: i + 1,
          title: 'Obrigação ${i + 1}',
          description: 'Desc ${i + 1}',
          status: ObligationStatus.pending,
          dueDate: DateTime.now().add(Duration(days: i + 1)),
          createdAt: DateTime.now(),
          company: const ObligationParticipantSummary(id: 1, name: 'Alpha Tech'),
          responsible: const ObligationParticipantSummary(id: 1, name: 'Lucas Contábil'),
          attachmentCount: 0,
        ),
      );

      final repository = MockObligationRepository()..items = many;

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Página 1 de 2 (15)'), findsOneWidget);
      expect(find.text('Obrigação 1'), findsOneWidget);
      expect(find.text('Obrigação 11'), findsNothing);

      await tester.tap(find.byKey(const Key('obligation-pagination-next')));
      await tester.pumpAndSettle();

      expect(find.text('Página 2 de 2 (15)'), findsOneWidget);
      expect(find.text('Obrigação 11'), findsOneWidget);
      expect(find.text('Obrigação 1'), findsNothing);
    });

    testWidgets('SPEC-034: deve filtrar por status Atrasadas e permitir selecionar ordenação', (tester) async {
      final repository = MockObligationRepository()..items = [sampleObligation];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      // Ativar chip Apenas Atrasadas
      await tester.ensureVisible(find.byKey(const Key('filter-overdue-chip')));
      await tester.tap(find.byKey(const Key('filter-overdue-chip')));
      await tester.pumpAndSettle();

      // Abrir menu de ordenação
      await tester.tap(find.byKey(const Key('obligation-sort-menu')));
      await tester.pumpAndSettle();

      expect(find.text('Prazo (Mais próximo)'), findsOneWidget);
      expect(find.text('Prazo (Mais distante)'), findsOneWidget);
      expect(find.text('Mais recentes'), findsOneWidget);
      expect(find.text('Título (A-Z)'), findsOneWidget);

      await tester.tap(find.text('Mais recentes'));
      await tester.pumpAndSettle();
    });

    testWidgets('SPEC-034: deve inicializar com initialCompanyId e exibir badge de filtro ativo', (tester) async {
      final repository = MockObligationRepository()..items = [sampleObligation];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ObligationListPage(
            repository: repository,
            initialCompanyId: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empresa: ID 1'), findsOneWidget);
      expect(find.byKey(const Key('clear-all-filters-button')), findsOneWidget);

      // Limpar todos
      await tester.tap(find.byKey(const Key('clear-all-filters-button')));
      await tester.pumpAndSettle();

      expect(find.text('Empresa: ID 1'), findsNothing);
    });

    testWidgets('deve esconder o botão de editar obrigação quando usuário não estiver autenticado e exibir quando autenticado', (tester) async {
      final repository = MockObligationRepository()..items = [sampleObligation];

      // Não autenticado
      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('obligation-edit-button-1')), findsNothing);

      // Autenticado
      final sessionStorage = InMemoryAuthSessionStorage();
      final apiClient = ApiClient(httpClient: http.Client(), baseUrl: 'http://localhost');
      final authController = AuthSessionController(
        authRepository: FakeAuthRepository(),
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
      const session = AuthSession(
        token: 'token-abc',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      await tester.pumpWidget(createWidgetUnderTest(
        repository: repository,
        authController: authController,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('obligation-edit-button-1')), findsOneWidget);
    });
  });
}
