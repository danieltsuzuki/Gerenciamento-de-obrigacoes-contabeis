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
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_detail_page.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_form_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

class MockCompanyRepository implements CompanyRepository {
  Company? companyToReturn;
  bool shouldThrow = false;
  int getByIdCalls = 0;

  @override
  Future<Company> getCompanyById(int id) async {
    getByIdCalls++;
    if (shouldThrow) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'Empresa não encontrada.',
      );
    }
    return companyToReturn ??
        Company(
          id: id,
          legalName: 'Empresa Alpha Ltda',
          tradeName: 'Alpha Tech',
          cnpj: '33000167000101',
          active: true,
        );
  }

  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async =>
      throw UnimplementedError();

  @override
  Future<Company> createCompany(CreateCompanyRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async =>
      throw UnimplementedError();
}

class FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CompanyDetailPage - SPEC-016', () {
    late MockCompanyRepository mockRepo;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController authController;

    setUp(() {
      mockRepo = MockCompanyRepository();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      authController = AuthSessionController(
        authRepository: FakeAuthRepository(),
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Widget createWidgetUnderTest({
      required int companyId,
      Company? initialCompany,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: CompanyDetailPage(
          repository: mockRepo,
          companyId: companyId,
          initialCompany: initialCompany,
          authController: authController,
        ),
      );
    }

    testWidgets('deve exibir dados da empresa e NÃO exibir botões de editar quando deslogado',
        (tester) async {
      const comp = Company(
        id: 3,
        legalName: 'Petróleo Brasileiro S.A.',
        tradeName: 'Petrobras',
        cnpj: '33000167000101',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        companyId: 3,
        initialCompany: comp,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Detalhes da Empresa'), findsOneWidget);
      expect(find.text('Petrobras'), findsWidgets);
      expect(find.text('Petróleo Brasileiro S.A.'), findsWidgets);
      expect(find.text('33.000.167/0001-01'), findsOneWidget);
      expect(find.text('#3'), findsOneWidget);
      expect(find.text('Ativa'), findsOneWidget);
      expect(
        find.text('Ativa — Pode ser vinculada a novas obrigações fiscais'),
        findsOneWidget,
      );

      // Não deve exibir botão de editar quando deslogado
      expect(find.byKey(const Key('company-detail-edit-button')), findsNothing);
      expect(find.byKey(const Key('company-detail-edit-action')), findsNothing);
    });

    testWidgets('deve exibir botões de editar e abrir CompanyFormPage quando logado',
        (tester) async {
      const session = AuthSession(
        token: 'token-valido',
        responsible: Responsible(id: 1, name: 'Admin', email: 'admin@empresa.com', active: true),
      );
      await sessionStorage.saveSession(session);
      await authController.initialize();

      const comp = Company(
        id: 3,
        legalName: 'Petróleo Brasileiro S.A.',
        tradeName: 'Petrobras',
        cnpj: '33000167000101',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        companyId: 3,
        initialCompany: comp,
      ));
      await tester.pumpAndSettle();

      // Botões devem estar visíveis
      expect(find.byKey(const Key('company-detail-edit-button')), findsOneWidget);
      expect(find.byKey(const Key('company-detail-edit-action')), findsOneWidget);

      await tester.tap(find.byKey(const Key('company-detail-edit-button')));
      await tester.pumpAndSettle();

      expect(find.byType(CompanyFormPage), findsOneWidget);
      expect(find.text('Editar Empresa'), findsOneWidget);
      expect(find.text('Petrobras'), findsWidgets);
    });

    testWidgets('deve buscar dados da API quando initialCompany for nulo', (tester) async {
      mockRepo.companyToReturn = const Company(
        id: 8,
        legalName: 'Beta Serviços Contábeis',
        tradeName: 'Beta Contábil',
        cnpj: '11222333000181',
        active: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(companyId: 8));
      await tester.pumpAndSettle();

      expect(mockRepo.getByIdCalls, 1);
      expect(find.text('Beta Contábil'), findsWidgets);
      expect(find.text('Inativa'), findsOneWidget);
      expect(
        find.text('Inativa — Não recebe novas obrigações fiscais (RN-006)'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir ErrorStateView e permitir retry quando a requisição falhar',
        (tester) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(createWidgetUnderTest(companyId: 99));
      await tester.pumpAndSettle();

      expect(find.text('Empresa não encontrada.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      mockRepo.shouldThrow = false;
      mockRepo.companyToReturn = const Company(
        id: 99,
        legalName: 'Empresa Recuperada',
        cnpj: '33000167000101',
        active: true,
      );

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Empresa Recuperada'), findsWidgets);
    });
  });
}

