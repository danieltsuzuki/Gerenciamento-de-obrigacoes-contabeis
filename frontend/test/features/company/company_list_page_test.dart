import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_detail_page.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_form_page.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_list_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCompanyListRepository implements CompanyRepository {
  List<Company> items = [];
  bool? lastActiveFilter;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
    String? q,
  }) async {
    callCount++;
    lastActiveFilter = active;

    if (shouldThrow) {
      throw const ApiException(
        statusCode: 500,
        code: 'SERVER_ERROR',
        message: 'Falha ao buscar empresas',
      );
    }

    var filtered = active != null
        ? items.where((c) => c.active == active).toList()
        : items;

    if (q != null && q.isNotEmpty) {
      filtered = filtered.where((c) =>
          c.legalName.toLowerCase().contains(q.toLowerCase()) ||
          (c.tradeName?.toLowerCase().contains(q.toLowerCase()) ?? false) ||
          c.cnpj.contains(q)).toList();
    }

    final total = filtered.length;
    final totalPages = (total / size).ceil() == 0 ? 1 : (total / size).ceil();
    final start = page * size;
    final pageContent = (start < total)
        ? filtered.sublist(start, (start + size) > total ? total : start + size)
        : <Company>[];

    return PageResponse<Company>(
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
  Future<Company> createCompany(CreateCompanyRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Company> getCompanyById(int id) async => throw UnimplementedError();
}

void main() {
  const company1 = Company(
    id: 1,
    legalName: 'Alpha Tech Ltda',
    tradeName: 'Alpha Tech',
    cnpj: '33000167000101',
    active: true,
  );

  const company2 = Company(
    id: 2,
    legalName: 'Beta Serviços Contábeis',
    cnpj: '33000167000101',
    active: false,
  );

  Widget createWidgetUnderTest({
    required CompanyRepository repository,
    AuthSessionController? authController,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CompanyListPage(
        repository: repository,
        authController: authController,
      ),
    );
  }

  group('CompanyListPage - SPEC-016', () {
    testWidgets('deve exibir lista de empresas com dados formatados e chips de status', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1, company2];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Empresas'), findsWidgets);
      expect(find.text('Alpha Tech'), findsOneWidget);
      expect(find.text('Alpha Tech Ltda'), findsOneWidget);
      expect(find.text('CNPJ: 33.000.167/0001-01'), findsNWidgets(2));
      expect(find.text('Ativa'), findsOneWidget);
      expect(find.text('Inativa'), findsOneWidget);
    });

    testWidgets('deve filtrar empresas por situação ativa ou inativa', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1, company2];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      // Filtra por Ativas
      await tester.tap(find.byKey(const Key('company-filter-active')));
      await tester.pumpAndSettle();

      expect(repository.lastActiveFilter, isTrue);
      expect(find.text('Alpha Tech'), findsOneWidget);
      expect(find.text('Beta Serviços Contábeis'), findsNothing);

      // Filtra por Inativas
      await tester.tap(find.byKey(const Key('company-filter-inactive')));
      await tester.pumpAndSettle();

      expect(repository.lastActiveFilter, isFalse);
      expect(find.text('Alpha Tech'), findsNothing);
      expect(find.text('Beta Serviços Contábeis'), findsOneWidget);

      // Volta para Todas
      await tester.tap(find.byKey(const Key('company-filter-all')));
      await tester.pumpAndSettle();

      expect(repository.lastActiveFilter, isNull);
      expect(find.text('Alpha Tech'), findsOneWidget);
      expect(find.text('Beta Serviços Contábeis'), findsOneWidget);
    });

    testWidgets('deve exibir estado vazio e botão Nova Empresa', (tester) async {
      final repository = MockCompanyListRepository()..items = [];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma empresa encontrada'), findsOneWidget);
      expect(find.byIcon(Icons.business_outlined), findsOneWidget);
    });

    testWidgets('deve exibir estado de erro e permitir retry', (tester) async {
      final repository = MockCompanyListRepository()..shouldThrow = true;

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Falha ao buscar empresas'), findsOneWidget);

      repository.shouldThrow = false;
      repository.items = [company1];

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha Tech'), findsOneWidget);
    });

    testWidgets('deve esconder o FAB de cadastro quando deslogado', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new-company-fab')), findsNothing);
    });

    testWidgets('deve abrir formulário de cadastro ao tocar no FAB quando autenticado', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1];
      final sessionStorage = InMemoryAuthSessionStorage();
      final authController = AuthSessionController(
        authRepository: FakeAuthRepository(),
        sessionStorage: sessionStorage,
        apiClient: ApiClient(baseUrl: 'http://test.local'),
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

      await tester.tap(find.byKey(const Key('new-company-fab')));
      await tester.pumpAndSettle();

      expect(find.byType(CompanyFormPage), findsOneWidget);
      expect(find.text('Nova Empresa'), findsOneWidget);
    });

    testWidgets('deve abrir CompanyDetailPage ao tocar no card da empresa', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alpha Tech'));
      await tester.pumpAndSettle();

      expect(find.byType(CompanyDetailPage), findsOneWidget);
      expect(find.text('Detalhes da Empresa'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('deve esconder o botão de editar quando usuário não estiver autenticado', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('company-edit-button-1')), findsNothing);
    });

    testWidgets('deve abrir formulário de edição ao tocar no botão de editar quando autenticado', (tester) async {
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

      final repository = MockCompanyListRepository()..items = [company1];

      await tester.pumpWidget(createWidgetUnderTest(
        repository: repository,
        authController: authController,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('company-edit-button-1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('company-edit-button-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CompanyFormPage), findsOneWidget);
      expect(find.text('Editar Empresa'), findsOneWidget);
      expect(find.text('Alpha Tech Ltda'), findsOneWidget);
    });

    testWidgets('SPEC-033: deve permitir pesquisar empresas e exibir empty state específico quando não houver resultado', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1, company2];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Alpha Tech'), findsOneWidget);
      expect(find.text('Beta Serviços Contábeis'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('company-search-field')), 'Beta');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Beta Serviços Contábeis'), findsOneWidget);
      expect(find.text('Alpha Tech'), findsNothing);

      await tester.enterText(find.byKey(const Key('company-search-field')), 'Inexistente');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text("Nenhum resultado para 'Inexistente'"), findsOneWidget);

      await tester.tap(find.text('Limpar pesquisa'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Alpha Tech'), findsOneWidget);
      expect(find.text('Beta Serviços Contábeis'), findsOneWidget);
    });

    testWidgets('SPEC-032: deve exibir barra de paginação e navegar entre páginas', (tester) async {
      final manyCompanies = List.generate(
        15,
        (i) => Company(
          id: i + 1,
          legalName: 'Empresa Legal ${i + 1}',
          tradeName: 'Empresa Fantasia ${i + 1}',
          cnpj: '1122233300018${i % 10}',
          active: true,
          createdAt: DateTime.now(),
        ),
      );

      final repository = MockCompanyListRepository()..items = manyCompanies;

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Página 1 de 2 (15)'), findsOneWidget);
      expect(find.text('Empresa Fantasia 1'), findsOneWidget);
      expect(find.text('Empresa Fantasia 11'), findsNothing);

      await tester.tap(find.byKey(const Key('company-pagination-next')));
      await tester.pumpAndSettle();

      expect(find.text('Página 2 de 2 (15)'), findsOneWidget);
      expect(find.text('Empresa Fantasia 11'), findsOneWidget);
      expect(find.text('Empresa Fantasia 1'), findsNothing);
    });
  });
}

