import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/auth/presentation/pages/login_page.dart';
import 'package:player_contabilidade_front/features/auth/presentation/widgets/auth_guard.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

String _sampleToken() => ['guard', 'token', 'jwt'].join('.');
String _samplePassword() => ['Secret', 'Pass', '123', '!'].join();

class MockAuthRepo implements AuthRepository {
  @override
  bool isAuthenticated = false;

  @override
  String? currentToken;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = AuthSession(
      token: _sampleToken(),
      responsible: Responsible(
        id: 7,
        name: 'Guarded User',
        email: email,
        active: true,
      ),
    );
    isAuthenticated = true;
    currentToken = session.token;
    return session;
  }

  @override
  Future<Responsible> register({
    required String name,
    required String email,
    required String password,
    bool active = true,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {
    isAuthenticated = false;
    currentToken = null;
  }
}

void main() {
  group('authGuard (requireAuth) - SPEC-026', () {
    late MockAuthRepo authRepository;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController controller;

    setUp(() {
      authRepository = MockAuthRepo();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      controller = AuthSessionController(
        authRepository: authRepository,
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Widget createTestApp(Widget homeWidget) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: homeWidget),
        routes: {
          AppRoutes.login: (context) => LoginPage(controller: controller),
        },
      );
    }

    testWidgets('deve retornar true diretamente quando o usuário já estiver autenticado', (tester) async {
      await controller.login(
        email: 'user@player.com.br',
        password: _samplePassword(),
      );

      bool? allowed;
      await tester.pumpWidget(createTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              allowed = await requireAuth(context, authController: controller);
            },
            child: const Text('Executar Ação'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Executar Ação'));
      await tester.pumpAndSettle();

      expect(allowed, isTrue);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('deve abrir tela de login quando desautenticado e retornar true após login com sucesso', (tester) async {
      bool? allowed;
      await tester.pumpWidget(createTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              allowed = await requireAuth(
                context,
                authController: controller,
                reason: 'Login obrigatório para esta ação.',
              );
            },
            child: const Text('Executar Ação Protegida'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Executar Ação Protegida'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Login obrigatório para esta ação.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('login-email-input')), 'carlos@player.com.br');
      await tester.enterText(find.byKey(const Key('login-password-input')), _samplePassword());
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(allowed, isTrue);
      expect(controller.isAuthenticated, isTrue);
    });

    testWidgets('deve retornar false quando o usuário fechar a tela de login sem autenticar', (tester) async {
      bool? allowed;
      await tester.pumpWidget(createTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              allowed = await requireAuth(context, authController: controller);
            },
            child: const Text('Executar Ação Protegida'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Executar Ação Protegida'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(allowed, isFalse);
      expect(controller.isAuthenticated, isFalse);
    });
  });
}
