import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';

class FakeObligationRepository implements ObligationRepository {
  @override
  Future<PageResponse<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    int page = 0,
    int size = 20,
    String sort = 'dueDate,asc',
  }) async {
    return PageResponse<Obligation>(
      content: [
        Obligation(
          id: 1,
          title: 'DAS Mensal',
          description: 'Guia do Simples Nacional',
          status: ObligationStatus.pending,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          company: const ObligationParticipantSummary(id: 1, name: 'Empresa Alpha'),
          responsible: const ObligationParticipantSummary(id: 1, name: 'Carlos Contador'),
          attachmentCount: 2,
        ),
      ],
      totalElements: 1,
      totalPages: 1,
      size: 20,
      number: 0,
      first: true,
      last: true,
      empty: false,
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
}

class FakeCompanyRepository implements CompanyRepository {
  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    return const PageResponse<Company>(
      content: [
        Company(
          id: 1,
          legalName: 'Alpha Tech Ltda',
          tradeName: 'Alpha Tech',
          cnpj: '33000167000101',
          active: true,
        ),
      ],
      totalElements: 1,
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

class FakeResponsibleRepository implements ResponsibleRepository {
  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    return const PageResponse<Responsible>(
      content: [
        Responsible(
          id: 1,
          name: 'Carlos Contador',
          email: 'carlos@contabilidade.com',
          active: true,
        ),
      ],
      totalElements: 1,
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
  testWidgets('App deve iniciar e navegar entre Obrigações, Empresas e Responsáveis', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final apiClient = ApiClient(baseUrl: 'http://mock.api');
    final obligationRepo = FakeObligationRepository();
    final companyRepo = FakeCompanyRepository();
    final responsibleRepo = FakeResponsibleRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.initial,
        onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
          settings,
          apiClient: apiClient,
          obligationRepository: obligationRepo,
          companyRepository: companyRepo,
          responsibleRepository: responsibleRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Obrigações Fiscais'), findsWidgets);
    expect(find.text('DAS Mensal'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.business_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Empresas'), findsWidgets);
    expect(find.text('Alpha Tech Ltda'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();
    expect(find.text('Responsáveis'), findsWidgets);
    expect(find.text('Carlos Contador'), findsOneWidget);
  });
}
