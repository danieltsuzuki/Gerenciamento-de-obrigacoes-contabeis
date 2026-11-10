import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/features/company/domain/entities/company.dart';
import 'package:player_contabilidade_front/features/company/domain/repositories/company_repository.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';

class FakeObligationRepository implements ObligationRepository {
  @override
  Future<List<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    DateTime? dueFrom,
    DateTime? dueTo,
    int page = 0,
    int size = 20,
  }) async {
    return [
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
    ];
  }

  @override
  Future<Obligation> getObligationById(int id) async => throw UnimplementedError();
  @override
  Future<Obligation> createObligation({required int companyId, required int responsibleId, required String title, String? description, required DateTime dueDate}) async => throw UnimplementedError();
  @override
  Future<Obligation> updateStatus(int id, ObligationStatus newStatus) async => throw UnimplementedError();
  @override
  Future<Obligation> updateObligation({required int id, required int companyId, required int responsibleId, required String title, String? description, required DateTime dueDate}) async => throw UnimplementedError();
}

class FakeCompanyRepository implements CompanyRepository {
  @override
  Future<List<Company>> getCompanies({bool? active, int page = 0, int size = 20}) async {
    return [
      const Company(
        id: 1,
        legalName: 'Alpha Tech Ltda',
        tradeName: 'Alpha Tech',
        cnpj: '33000167000101',
        active: true,
      ),
    ];
  }

  @override
  Future<Company> getCompanyById(int id) async => throw UnimplementedError();
  @override
  Future<Company> createCompany({required String legalName, String? tradeName, required String cnpj, bool active = true}) async => throw UnimplementedError();
  @override
  Future<Company> updateCompany({required int id, required String legalName, String? tradeName, required String cnpj, required bool active}) async => throw UnimplementedError();
}

class FakeResponsibleRepository implements ResponsibleRepository {
  @override
  Future<List<Responsible>> getResponsibles({bool? active, int page = 0, int size = 20}) async {
    return [
      const Responsible(
        id: 1,
        name: 'Carlos Contador',
        email: 'carlos@contabilidade.com',
        active: true,
      ),
    ];
  }

  @override
  Future<Responsible> getResponsibleById(int id) async => throw UnimplementedError();
  @override
  Future<Responsible> createResponsible({required String name, required String email, required String password, bool active = true}) async => throw UnimplementedError();
  @override
  Future<Responsible> updateResponsible({required int id, required String name, required String email, required bool active}) async => throw UnimplementedError();
}

void main() {
  testWidgets('App deve iniciar e navegar entre Obrigações, Empresas e Responsáveis', (tester) async {
    final fakeObligationRepo = FakeObligationRepository();
    final fakeCompanyRepo = FakeCompanyRepository();
    final fakeResponsibleRepo = FakeResponsibleRepository();
    final apiClient = ApiClient(baseUrl: 'http://test.local');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.initial,
        onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
          settings,
          apiClient: apiClient,
          obligationRepository: fakeObligationRepo,
          companyRepository: fakeCompanyRepo,
          responsibleRepository: fakeResponsibleRepo,
        ),
      ),
    );

    // Aguarda carregar as obrigações
    await tester.pumpAndSettle();

    // Valida que estamos na tela de Obrigações
    expect(find.text('Obrigações Fiscais'), findsOneWidget);
    expect(find.text('DAS Mensal'), findsOneWidget);
    expect(find.text('Empresa Alpha'), findsOneWidget);

    // Navega para Empresas via bottom navigation bar
    await tester.tap(find.text('Empresas'));
    await tester.pumpAndSettle();

    // Valida que estamos na tela de Empresas
    expect(find.text('Empresas'), findsWidgets);
    expect(find.text('Alpha Tech'), findsOneWidget);

    // Navega para Responsáveis
    await tester.tap(find.text('Responsáveis'));
    await tester.pumpAndSettle();

    // Valida que estamos na tela de Responsáveis
    expect(find.text('Responsáveis'), findsWidgets);
    expect(find.text('Carlos Contador'), findsOneWidget);
  });
}
