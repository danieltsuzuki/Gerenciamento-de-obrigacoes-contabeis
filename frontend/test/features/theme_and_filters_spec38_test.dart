import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/core/theme/theme_controller.dart';
import 'package:player_contabilidade_front/core/widgets/app_scaffold.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_list_page.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_list_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_list_page.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockCompanyRepo implements CompanyRepository {
  List<Company> items = [
    const Company(id: 1, legalName: 'Alpha Ltda', cnpj: '11111111000101', active: true),
    const Company(id: 2, legalName: 'Beta Corp', cnpj: '22222222000102', active: false),
  ];
  String lastSort = 'id,asc';
  bool? lastActive;

  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
    String? q,
  }) async {
    lastSort = sort;
    lastActive = active;
    var filtered = items;
    if (active != null) {
      filtered = filtered.where((c) => c.active == active).toList();
    }
    return PageResponse<Company>(
      content: filtered,
      totalElements: filtered.length,
      totalPages: 1,
      size: size,
      number: page,
      first: true,
      last: true,
      empty: filtered.isEmpty,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockResponsibleRepo implements ResponsibleRepository {
  List<Responsible> items = [
    const Responsible(id: 1, name: 'Alice Silva', email: 'alice@player.com.br', active: true),
    const Responsible(id: 2, name: 'Bob Souza', email: 'bob@player.com.br', active: false),
  ];
  String lastSort = 'id,asc';
  bool? lastActive;

  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
    String? q,
  }) async {
    lastSort = sort;
    lastActive = active;
    var filtered = items;
    if (active != null) {
      filtered = filtered.where((r) => r.active == active).toList();
    }
    return PageResponse<Responsible>(
      content: filtered,
      totalElements: filtered.length,
      totalPages: 1,
      size: size,
      number: page,
      first: true,
      last: true,
      empty: filtered.isEmpty,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockObligationRepo implements ObligationRepository {
  List<Obligation> items = [
    Obligation(
      id: 1,
      title: 'Declaração Anual IRPJ',
      description: 'Envio à Receita Federal',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      status: ObligationStatus.pending,
      company: const ObligationParticipantSummary(id: 1, name: 'Alpha Ltda'),
      responsible: const ObligationParticipantSummary(id: 1, name: 'Alice Silva'),
      attachmentCount: 2,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<PageResponse<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    String? dueFrom,
    String? dueTo,
    int page = 0,
    int size = 10,
    String sort = 'dueDate,asc',
    String? q,
  }) async {
    return PageResponse<Obligation>(
      content: items,
      totalElements: items.length,
      totalPages: 1,
      size: size,
      number: page,
      first: true,
      last: true,
      empty: items.isEmpty,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SPEC-038 - Tema Claro e Escuro, Paleta Oficial, Modais e Filtros Avançados', () {
    test('AppTheme deve definir as cores oficiais da marca', () {
      expect(AppTheme.primaryNavy, const Color(0xFF17152F));
      expect(AppTheme.brandYellow, const Color(0xFFF5A900));
      expect(AppTheme.accentYellow, const Color(0xFFFFC52E));
      expect(AppTheme.white, const Color(0xFFFFFFFF));
    });

    test('ThemeController deve alternar entre modos claro, escuro e sistema', () {
      final controller = ThemeController();
      expect(controller.themeMode, ThemeMode.system);

      controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.dark);

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.light);
    });

    testWidgets('AppScaffold deve renderizar botão de alternar tema e executar toggle', (tester) async {
      final themeController = ThemeController(initialMode: ThemeMode.light);

      await tester.pumpWidget(
        AnimatedBuilder(
          animation: themeController,
          builder: (context, _) => MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: AppScaffold(
              title: 'Teste de Tema',
              currentNavIndex: 0,
              themeController: themeController,
              body: const Text('Conteúdo do scaffold'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('theme-toggle-button')), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      await tester.tap(find.byKey(const Key('theme-toggle-button')));
      await tester.pumpAndSettle();

      expect(themeController.themeMode, ThemeMode.dark);
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });

    testWidgets('CompanyListPage deve ocultar FAB para anônimos e exibir para logados', (tester) async {
      final compRepo = _MockCompanyRepo();
      final sessionStorage = InMemoryAuthSessionStorage();
      final authController = AuthSessionController(
        authRepository: _FakeAuthRepo(),
        sessionStorage: sessionStorage,
        apiClient: ApiClient(baseUrl: 'http://test.local'),
      );

      // Deslogado: FAB oculto
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CompanyListPage(
          repository: compRepo,
          authController: authController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new-company-fab')), findsNothing);

      // Loga
      const session = AuthSession(
        token: 'token-ok',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@player.com.br', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new-company-fab')), findsOneWidget);
    });

    testWidgets('CompanyListPage deve abrir modal de filtros avançados centralizado e aplicar', (tester) async {
      final compRepo = _MockCompanyRepo();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CompanyListPage(repository: compRepo),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('open-company-filters-button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('open-company-filters-button')));
      await tester.pumpAndSettle();

      // Modal aberto e centralizado
      expect(find.text('Filtros de Empresas'), findsOneWidget);
      expect(find.byKey(const Key('company-filter-active-chip-true')), findsOneWidget);

      // Seleciona ativas
      await tester.tap(find.byKey(const Key('company-filter-active-chip-true')));
      await tester.pumpAndSettle();

      // Aplica
      await tester.tap(find.byKey(const Key('apply-company-filters-button')));
      await tester.pumpAndSettle();

      expect(compRepo.lastActive, isTrue);
    });

    testWidgets('ResponsibleListPage deve ocultar FAB para anônimos e exibir para logados', (tester) async {
      final respRepo = _MockResponsibleRepo();
      final sessionStorage = InMemoryAuthSessionStorage();
      final authController = AuthSessionController(
        authRepository: _FakeAuthRepo(),
        sessionStorage: sessionStorage,
        apiClient: ApiClient(baseUrl: 'http://test.local'),
      );

      // Deslogado: FAB oculto
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: ResponsibleListPage(
          repository: respRepo,
          authController: authController,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new-responsible-fab')), findsNothing);

      // Loga
      const session = AuthSession(
        token: 'token-ok',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@player.com.br', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new-responsible-fab')), findsOneWidget);
    });

    testWidgets('ResponsibleListPage deve abrir modal de filtros avançados centralizado e aplicar', (tester) async {
      final respRepo = _MockResponsibleRepo();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: ResponsibleListPage(repository: respRepo),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('open-responsible-filters-button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('open-responsible-filters-button')));
      await tester.pumpAndSettle();

      // Modal aberto e centralizado
      expect(find.text('Filtros de Responsáveis'), findsOneWidget);
      expect(find.byKey(const Key('responsible-filter-active-chip-true')), findsOneWidget);

      // Seleciona ativos
      await tester.tap(find.byKey(const Key('responsible-filter-active-chip-true')));
      await tester.pumpAndSettle();

      // Aplica
      await tester.tap(find.byKey(const Key('apply-responsible-filters-button')));
      await tester.pumpAndSettle();

      expect(respRepo.lastActive, isTrue);
    });

    testWidgets('ObligationListPage no modo dark deve usar cores de texto legíveis e barra de pesquisa padronizada', (tester) async {
      final obRepo = _MockObligationRepo();

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: ObligationListPage(repository: obRepo),
      ));
      await tester.pumpAndSettle();

      // Barra de pesquisa deve usar a decoração padrão padronizada
      final textField = tester.widget<TextField>(find.byKey(const Key('obligation-search-field')));
      expect(textField.decoration?.hintText, 'Pesquisar obrigações...');
      // Não deve ter cor fixa cinza claro
      expect(textField.decoration?.fillColor, isNull);

      // Texto do título da obrigação no modo dark
      final titleText = tester.widget<Text>(find.text('Declaração Anual IRPJ'));
      expect(titleText.style?.color, isNot(const Color(0xFF0F172A)));
      expect(titleText.style?.color, AppTheme.darkTheme.colorScheme.onSurface);
    });
  });
}
