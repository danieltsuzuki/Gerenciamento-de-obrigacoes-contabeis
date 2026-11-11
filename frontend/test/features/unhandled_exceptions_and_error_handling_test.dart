import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/attachment/domain/entities/attachment.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_form_page.dart';
import 'package:player_contabilidade_front/features/company/presentation/pages/company_list_page.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_list_page.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_form_page.dart';
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_list_page.dart';

class ErrorCompanyRepository implements CompanyRepository {
  Exception errorToThrow;

  ErrorCompanyRepository(this.errorToThrow);

  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'legalName,asc',
  }) async {
    throw errorToThrow;
  }

  @override
  Future<Company> getCompanyById(int id) async => throw errorToThrow;

  @override
  Future<Company> createCompany(CreateCompanyRequest request) async => throw errorToThrow;

  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async => throw errorToThrow;
}

class ErrorResponsibleRepository implements ResponsibleRepository {
  Exception errorToThrow;

  ErrorResponsibleRepository(this.errorToThrow);

  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'name,asc',
  }) async {
    throw errorToThrow;
  }

  @override
  Future<Responsible> getResponsibleById(int id) async => throw errorToThrow;

  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) async => throw errorToThrow;

  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async => throw errorToThrow;
}

class ErrorObligationRepository implements ObligationRepository {
  Exception errorToThrow;

  ErrorObligationRepository(this.errorToThrow);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw errorToThrow;
}

void main() {
  group('Tratamento Estrito de Erros e Exceções - SPEC-023', () {
    test('ApiException.fromResponse trata corpos nulos ou vazios sem lançar exceção não tratada', () {
      final nullBodyError = ApiException.fromResponse(502, null);
      expect(nullBodyError.statusCode, 502);
      expect(nullBodyError.code, 'HTTP_502');
      expect(nullBodyError.isServerError, isTrue);

      final emptyMapError = ApiException.fromResponse(500, {});
      expect(emptyMapError.statusCode, 500);
      expect(emptyMapError.message, 'Erro na requisição.');

      final completeError = ApiException.fromResponse(422, {
        'code': 'COMPANY_INACTIVE',
        'message': 'Empresa inativa.',
        'details': ['ID 123'],
      });
      expect(completeError.statusCode, 422);
      expect(completeError.code, 'COMPANY_INACTIVE');
      expect(completeError.isBusinessRuleViolation, isTrue);
      expect(completeError.details, ['ID 123']);

      final networkErr = ApiException.networkError('TimeoutException after 0:00:30.000000');
      expect(networkErr.statusCode, 0);
      expect(networkErr.code, 'NETWORK_ERROR');
    });

    test('Desserialização de modelos com payloads degenerados não lança exceções não tratadas', () {
      final comp = Company.fromJson({
        'id': 1,
        'legalName': 'Empresa Parcial',
        'cnpj': '12.345.678/0001-90',
        'createdAt': 'data_invalida',
        'updatedAt': 'outra_invalida',
      });
      expect(comp.id, 1);
      expect(comp.createdAt, isNull);
      expect(comp.updatedAt, isNull);

      final resp = Responsible.fromJson({
        'id': 2,
        'name': 'Responsável Teste',
        'email': 'teste@teste.com',
        'createdAt': 'data_invalida',
      });
      expect(resp.id, 2);
      expect(resp.createdAt, isNull);

      final att = Attachment.fromJson({
        'id': 3,
        'obligationId': 10,
        'name': 'arquivo.bin',
        'size': null,
        'uploadedAt': '2026-11-10T12:00:00.000Z',
      });
      expect(att.size, 0);
      expect(att.formattedSize, '0 B');
    });

    testWidgets('CompanyListPage trata erro 500 sem exceções não tratadas e renderiza ErrorStateView',
        (tester) async {
      final repo = ErrorCompanyRepository(
        const ApiException(statusCode: 500, code: 'INTERNAL_ERROR', message: 'Serviço temporariamente indisponível.'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CompanyListPage(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Serviço temporariamente indisponível.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('ResponsibleListPage trata falha de rede sem exceções não tratadas e renderiza ErrorStateView',
        (tester) async {
      final repo = ErrorResponsibleRepository(
        ApiException.networkError('SocketException: Connection refused'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ResponsibleListPage(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Não foi possível conectar ao servidor'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('ObligationListPage trata exceção inesperada sem crashar a interface',
        (tester) async {
      final repo = ErrorObligationRepository(
        Exception('Falha catastrófica de infraestrutura'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ObligationListPage(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Falha catastrófica'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('CompanyFormPage trata erro 409 DUPLICATE_CNPJ exibindo mensagem de erro sem lançar exceção',
        (tester) async {
      final repo = ErrorCompanyRepository(
        const ApiException(statusCode: 409, code: 'DUPLICATE_CNPJ', message: 'CNPJ duplicado.'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CompanyFormPage(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('company-legal-name-input')), 'Empresa Teste');
      await tester.enterText(find.byKey(const Key('company-cnpj-input')), '11.222.333/0001-81');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('company-save-button')));
      await tester.pumpAndSettle();

      expect(find.text('Este CNPJ já está cadastrado para outra empresa (RN-002).'), findsOneWidget);
    });

    testWidgets('ResponsibleFormPage trata erro 409 DUPLICATE_EMAIL sem lançar exceção não tratada',
        (tester) async {
      final repo = ErrorResponsibleRepository(
        const ApiException(statusCode: 409, code: 'DUPLICATE_EMAIL', message: 'Email duplicado.'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ResponsibleFormPage(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('responsible-name-input')), 'Carlos');
      await tester.enterText(find.byKey(const Key('responsible-email-input')), 'carlos@teste.com');
      await tester.enterText(find.byKey(const Key('responsible-password-input')), 'SenhaSegura123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('responsible-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Este e-mail já está em uso por outro responsável (RN-003).'), findsOneWidget);
    });
  });
}
