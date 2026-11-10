import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_detail_page.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_form_page.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_list_page.dart';

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

    final filtered = active != null
        ? items.where((c) => c.active == active).toList()
        : items;

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

  Widget createWidgetUnderTest({required CompanyRepository repository}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CompanyListPage(repository: repository),
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

    testWidgets('deve abrir formulário de cadastro ao tocar no FAB', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
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

    testWidgets('deve abrir formulário de edição ao tocar no botão de editar', (tester) async {
      final repository = MockCompanyListRepository()..items = [company1];

      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('company-edit-button-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CompanyFormPage), findsOneWidget);
      expect(find.text('Editar Empresa'), findsOneWidget);
      expect(find.text('Alpha Tech Ltda'), findsOneWidget);
    });
  });
}

