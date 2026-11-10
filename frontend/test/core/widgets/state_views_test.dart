import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/widgets/empty_state_view.dart';
import 'package:player_contabilidade_front/core/widgets/error_state_view.dart';
import 'package:player_contabilidade_front/core/widgets/loading_state_view.dart';

void main() {
  group('Componentes de Estado Compartilhados', () {
    testWidgets('LoadingStateView exibe spinner e mensagem', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingStateView(message: 'Aguarde um momento...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Aguarde um momento...'), findsOneWidget);
    });

    testWidgets('ErrorStateView exibe mensagem e aciona callback de retry', (tester) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView(
              message: 'Falha ao buscar empresas',
              onRetry: () => retryClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Ops, algo deu errado'), findsOneWidget);
      expect(find.text('Falha ao buscar empresas'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      expect(retryClicked, isTrue);
    });

    testWidgets('EmptyStateView exibe mensagem e aciona botão de ação', (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'Nenhum registro',
              message: 'Não há itens para exibir.',
              actionLabel: 'Cadastrar Item',
              onAction: () => actionClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Nenhum registro'), findsOneWidget);
      expect(find.text('Não há itens para exibir.'), findsOneWidget);
      expect(find.text('Cadastrar Item'), findsOneWidget);

      await tester.tap(find.text('Cadastrar Item'));
      expect(actionClicked, isTrue);
    });
  });
}
