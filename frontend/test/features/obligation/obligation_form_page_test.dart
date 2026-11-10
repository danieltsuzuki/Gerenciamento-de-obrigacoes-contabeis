import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_form_page.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';

class MockObligationRepository implements ObligationRepository {
  CreateObligationRequest? lastCreateRequest;
  UpdateObligationRequest? lastUpdateRequest;
  int? lastUpdateId;
  bool shouldThrowInactive = false;
  bool shouldThrowError = false;

  @override
  Future<Obligation> createObligation(CreateObligationRequest request) async {
    lastCreateRequest = request;
    if (shouldThrowInactive) {
      throw const ApiException(
        statusCode: 422,
        code: 'COMPANY_INACTIVE',
        message: 'Empresa inativa.',
      );
    }
    if (shouldThrowError) {
      throw const ApiException(
        statusCode: 500,
        code: 'SERVER_ERROR',
        message: 'Erro interno.',
      );
    }
    return Obligation(
      id: 99,
      title: request.title,
      description: request.description,
      status: ObligationStatus.pending,
      dueDate: DateTime.parse(request.dueDate),
      company: ObligationParticipantSummary(id: request.companyId, name: 'Empresa Teste'),
      responsible: ObligationParticipantSummary(id: request.responsibleId, name: 'Resp Teste'),
    );
  }

  @override
  Future<Obligation> updateObligation(int id, UpdateObligationRequest request) async {
    lastUpdateId = id;
    lastUpdateRequest = request;
    return Obligation(
      id: id,
      title: request.title,
      description: request.description,
      status: ObligationStatus.pending,
      dueDate: DateTime.parse(request.dueDate),
      company: ObligationParticipantSummary(id: request.companyId, name: 'Empresa Teste'),
      responsible: ObligationParticipantSummary(id: request.responsibleId, name: 'Resp Teste'),
    );
  }

  @override
  Future<PageResponse<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    int page = 0,
    int size = 20,
    String sort = 'dueDate,asc',
  }) async =>
      throw UnimplementedError();

  @override
  Future<Obligation> getObligationById(int id) async => throw UnimplementedError();

  @override
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async =>
      throw UnimplementedError();
}

class MockCompanyRepository implements CompanyRepository {
  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    return PageResponse<Company>(
      content: [
        const Company(id: 1, legalName: 'Alpha Tech Ltda', cnpj: '33000167000101', active: true),
        const Company(id: 2, legalName: 'Beta Indústria S.A.', cnpj: '11222333000181', active: true),
      ],
      totalElements: 2,
      totalPages: 1,
      size: 20,
      number: 0,
      first: true,
      last: true,
      empty: false,
    );
  }

  @override
  Future<Company> getCompanyById(int id) async => throw UnimplementedError();
  @override
  Future<Company> createCompany(CreateCompanyRequest request) async => throw UnimplementedError();
  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async => throw UnimplementedError();
}

class MockResponsibleRepository implements ResponsibleRepository {
  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    return PageResponse<Responsible>(
      content: [
        const Responsible(id: 10, name: 'Carlos Alberto', email: 'carlos@empresa.com', active: true),
        const Responsible(id: 20, name: 'Mariana Duarte', email: 'mariana@empresa.com', active: true),
      ],
      totalElements: 2,
      totalPages: 1,
      size: 20,
      number: 0,
      first: true,
      last: true,
      empty: false,
    );
  }

  @override
  Future<Responsible> getResponsibleById(int id) async => throw UnimplementedError();
  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) async => throw UnimplementedError();
  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async => throw UnimplementedError();
}

void main() {
  group('ObligationFormPage - SPEC-018', () {
    late MockObligationRepository mockObligationRepo;
    late MockCompanyRepository mockCompanyRepo;
    late MockResponsibleRepository mockResponsibleRepo;

    setUp(() {
      mockObligationRepo = MockObligationRepository();
      mockCompanyRepo = MockCompanyRepository();
      mockResponsibleRepo = MockResponsibleRepository();
    });

    Widget createWidgetUnderTest({Obligation? obligation}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ObligationFormPage(
          obligationRepository: mockObligationRepo,
          companyRepository: mockCompanyRepo,
          responsibleRepository: mockResponsibleRepo,
          obligation: obligation,
        ),
      );
    }

    testWidgets('deve renderizar campos do formulário em modo criação', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nova Obrigação'), findsOneWidget);
      expect(find.byKey(const Key('obligation-title-input')), findsOneWidget);
      expect(find.byKey(const Key('obligation-description-input')), findsOneWidget);
      expect(find.byKey(const Key('obligation-company-select')), findsOneWidget);
      expect(find.byKey(const Key('obligation-responsible-select')), findsOneWidget);
      expect(find.byKey(const Key('obligation-due-date-input')), findsOneWidget);
      expect(find.byKey(const Key('obligation-submit-button')), findsOneWidget);
      expect(find.text('Cadastrar Obrigação'), findsOneWidget);
      expect(
        find.text(
          'Toda obrigação recém-cadastrada inicia automaticamente com status Pendente no servidor (RN-008).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve validar campos obrigatórios vazios', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('obligation-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('O título da obrigação é obrigatório.'), findsOneWidget);
      expect(find.text('Selecione a empresa vinculada.'), findsOneWidget);
      expect(find.text('Selecione o responsável atribuído.'), findsOneWidget);
      expect(find.text('A data de vencimento é obrigatória.'), findsOneWidget);
      expect(mockObligationRepo.lastCreateRequest, isNull);
    });

    testWidgets('deve abrir em modo de edição com dados preenchidos', (tester) async {
      final existing = Obligation(
        id: 5,
        title: 'Declaração DCTF',
        description: 'Instruções DCTF',
        status: ObligationStatus.pending,
        dueDate: DateTime(2026, 12, 1),
        company: const ObligationParticipantSummary(id: 1, name: 'Alpha Tech Ltda'),
        responsible: const ObligationParticipantSummary(id: 10, name: 'Carlos Alberto'),
      );

      await tester.pumpWidget(createWidgetUnderTest(obligation: existing));
      await tester.pumpAndSettle();

      expect(find.text('Editar Obrigação'), findsOneWidget);
      expect(find.text('Declaração DCTF'), findsOneWidget);
      expect(find.text('Instruções DCTF'), findsOneWidget);
      expect(find.text('01/12/2026'), findsOneWidget);
      expect(find.text('Salvar Alterações'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('obligation-title-input')),
        'Declaração DCTF Retificadora',
      );
      await tester.tap(find.byKey(const Key('obligation-submit-button')));
      await tester.pumpAndSettle();

      expect(mockObligationRepo.lastUpdateId, 5);
      expect(mockObligationRepo.lastUpdateRequest, isNotNull);
      expect(mockObligationRepo.lastUpdateRequest!.title, 'Declaração DCTF Retificadora');
    });

    testWidgets('deve desabilitar campos e exibir aviso se obrigação for COMPLETED (RN-009)',
        (tester) async {
      final completedOb = Obligation(
        id: 7,
        title: 'Obrigação Já Concluída',
        status: ObligationStatus.completed,
        dueDate: DateTime(2026, 11, 1),
        completedAt: DateTime(2026, 11, 1),
        company: const ObligationParticipantSummary(id: 1, name: 'Alpha Tech Ltda'),
        responsible: const ObligationParticipantSummary(id: 10, name: 'Carlos Alberto'),
      );

      await tester.pumpWidget(createWidgetUnderTest(obligation: completedOb));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Esta obrigação está concluída (COMPLETED) e não permite alterações ou reabertura (RN-009).',
        ),
        findsOneWidget,
      );

      final submitBtn = tester.widget<ElevatedButton>(
        find.byKey(const Key('obligation-submit-button')),
      );
      expect(submitBtn.onPressed, isNull);
    });
  });
}

