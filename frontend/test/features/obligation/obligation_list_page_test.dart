import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';
import 'package:player_contabilidade_front/features/obligation/domain/repositories/obligation_repository.dart';
import 'package:player_contabilidade_front/features/obligation/presentation/pages/obligation_list_page.dart';

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
    int page = 0,
    int size = 20,
    String sort = 'dueDate,asc',
  }) async {
    callCount++;
    lastFilterStatus = status;

    if (shouldThrow) {
      throw ApiException(statusCode: 500, code: 'SERVER_ERROR', message: errorMessage);
    }

    final filtered = status != null
        ? items.where((o) => o.status == status).toList()
        : items;

    return PageResponse<Obligation>(
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
  Future<Obligation> getObligationById(int id) async => throw UnimplementedError();

  @override
  Future<Obligation> createObligation(CreateObligationRequest request) async => throw UnimplementedError();

  @override
  Future<Obligation> updateObligation(int id, UpdateObligationRequest request) async => throw UnimplementedError();

  @override
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async => throw UnimplementedError();
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
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ObligationListPage(
        repository: repository,
        onObligationTap: onObligationTap,
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
  });
}
