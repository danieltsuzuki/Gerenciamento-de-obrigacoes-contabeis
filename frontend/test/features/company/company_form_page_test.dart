import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_form_page.dart';

class MockCompanyRepository implements CompanyRepository {
  CreateCompanyRequest? lastCreateRequest;
  UpdateCompanyRequest? lastUpdateRequest;
  int? lastUpdateId;
  bool shouldThrowDuplicate = false;
  bool shouldThrowError = false;

  @override
  Future<Company> createCompany(CreateCompanyRequest request) async {
    lastCreateRequest = request;
    if (shouldThrowDuplicate) {
      throw const ApiException(
        statusCode: 409,
        code: 'DUPLICATE_CNPJ',
        message: 'CNPJ já cadastrado',
      );
    }
    if (shouldThrowError) {
      throw const ApiException(
        statusCode: 500,
        code: 'SERVER_ERROR',
        message: 'Erro no servidor',
      );
    }
    return Company(
      id: 99,
      legalName: request.legalName,
      tradeName: request.tradeName,
      cnpj: request.cnpj,
      active: request.active,
    );
  }

  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async {
    lastUpdateId = id;
    lastUpdateRequest = request;
    if (shouldThrowDuplicate) {
      throw const ApiException(
        statusCode: 409,
        code: 'DUPLICATE_CNPJ',
        message: 'CNPJ já cadastrado',
      );
    }
    return Company(
      id: id,
      legalName: request.legalName,
      tradeName: request.tradeName,
      cnpj: request.cnpj,
      active: request.active,
    );
  }

  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
    String? q,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Company> getCompanyById(int id) async => throw UnimplementedError();
}

void main() {
  const validCnpj = '33.000.167/0001-01';

  Widget createWidgetUnderTest({
    required CompanyRepository repository,
    Company? company,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CompanyFormPage(
        repository: repository,
        company: company,
      ),
    );
  }

  group('CompanyFormPage - SPEC-016', () {
    testWidgets('deve renderizar campos em branco no modo criação', (tester) async {
      final repository = MockCompanyRepository();
      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Nova Empresa'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.byKey(const Key('company-legal-name-input')), findsOneWidget);
      expect(find.byKey(const Key('company-trade-name-input')), findsOneWidget);
      expect(find.byKey(const Key('company-cnpj-input')), findsOneWidget);
      expect(find.byKey(const Key('company-active-switch')), findsNothing);
    });

    testWidgets('deve renderizar campos pré-preenchidos no modo edição', (tester) async {
      final repository = MockCompanyRepository();
      const existing = Company(
        id: 10,
        legalName: 'Alpha Tech Ltda',
        tradeName: 'Alpha Tech',
        cnpj: '33000167000101',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        repository: repository,
        company: existing,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editar Empresa'), findsOneWidget);
      expect(find.text('Salvar Alterações'), findsOneWidget);
      expect(find.text('Alpha Tech Ltda'), findsOneWidget);
      expect(find.text('Alpha Tech'), findsOneWidget);
      expect(find.text('33.000.167/0001-01'), findsOneWidget);
      expect(find.byKey(const Key('company-active-switch')), findsOneWidget);
    });

    testWidgets('deve validar campos obrigatórios e formato de CNPJ', (tester) async {
      final repository = MockCompanyRepository();
      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      // Tenta submeter em branco
      await tester.tap(find.byKey(const Key('company-save-button')));
      await tester.pumpAndSettle();

      expect(find.text('A Razão Social é obrigatória.'), findsOneWidget);
      expect(find.text('O CNPJ é obrigatório.'), findsOneWidget);
      expect(repository.lastCreateRequest, isNull);

      // Preenche CNPJ com dígitos inválidos
      await tester.enterText(find.byKey(const Key('company-cnpj-input')), '11111111111111');
      await tester.tap(find.byKey(const Key('company-save-button')));
      await tester.pumpAndSettle();

      expect(find.text('CNPJ inválido (dígitos verificadores incorretos).'), findsOneWidget);
    });

    testWidgets('deve submeter e cadastrar nova empresa com sucesso', (tester) async {
      final repository = MockCompanyRepository();
      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('company-legal-name-input')),
        'Empresa Teste S.A.',
      );
      await tester.enterText(
        find.byKey(const Key('company-trade-name-input')),
        'Teste Fantasia',
      );
      await tester.enterText(
        find.byKey(const Key('company-cnpj-input')),
        validCnpj,
      );

      await tester.tap(find.byKey(const Key('company-save-button')));
      await tester.pumpAndSettle();

      expect(repository.lastCreateRequest, isNotNull);
      expect(repository.lastCreateRequest!.legalName, 'Empresa Teste S.A.');
      expect(repository.lastCreateRequest!.tradeName, 'Teste Fantasia');
      expect(repository.lastCreateRequest!.cnpj, '33000167000101');
      expect(repository.lastCreateRequest!.active, isTrue);
    });

    testWidgets('deve atualizar empresa existente e permitir inativação', (tester) async {
      final repository = MockCompanyRepository();
      const existing = Company(
        id: 10,
        legalName: 'Alpha Tech Ltda',
        tradeName: 'Alpha Tech',
        cnpj: '33000167000101',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        repository: repository,
        company: existing,
      ));
      await tester.pumpAndSettle();

      // Inativa empresa via switch
      await tester.tap(find.byKey(const Key('company-active-switch')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('company-save-button')));
      await tester.pumpAndSettle();

      expect(repository.lastUpdateId, 10);
      expect(repository.lastUpdateRequest, isNotNull);
      expect(repository.lastUpdateRequest!.active, isFalse);
    });

    testWidgets('deve exibir mensagem de erro quando CNPJ for duplicado (409 DUPLICATE_CNPJ)', (tester) async {
      final repository = MockCompanyRepository()..shouldThrowDuplicate = true;
      await tester.pumpWidget(createWidgetUnderTest(repository: repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('company-legal-name-input')),
        'Empresa Conflitante',
      );
      await tester.enterText(
        find.byKey(const Key('company-cnpj-input')),
        validCnpj,
      );

      await tester.tap(find.byKey(const Key('company-save-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Este CNPJ já está cadastrado para outra empresa (RN-002).'),
        findsOneWidget,
      );
    });
  });
}

