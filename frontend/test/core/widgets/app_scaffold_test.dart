import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/core/widgets/app_scaffold.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

String _sampleToken() => ['scaffold', 'auth', 'jwt'].join('.');
String _samplePassword() => ['Pass', 'Word', '123', '!'].join();

class FakeAuthRepo implements AuthRepository {
  @override
  bool isAuthenticated = false;

  @override
  String? currentToken;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final session = AuthSession(
      token: _sampleToken(),
      responsible: Responsible(id: 1, name: 'Lucas Contador', email: email, active: true),
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
  group('AppScaffold - Botão de Login no canto superior direito', () {
    late FakeAuthRepo authRepository;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController controller;

    setUp(() {
      authRepository = FakeAuthRepo();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      controller = AuthSessionController(
        authRepository: authRepository,
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Widget createTestApp({AuthSessionController? authController}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: AppScaffold(
          title: 'Tela de Teste',
          body: const Text('Conteúdo Principal'),
          authController: authController,
        ),
        routes: {
          AppRoutes.login: (context) => const Scaffold(
                body: Text('Tela de Login Rota'),
              ),
        },
      );
    }

    testWidgets('deve exibir botão de Login no canto superior direito quando anônimo', (tester) async {
      await tester.pumpWidget(createTestApp(authController: controller));
      await tester.pumpAndSettle();

      final loginButtonFinder = find.byKey(const Key('auth-login-button'));
      expect(loginButtonFinder, findsOneWidget);
      expect(find.descendant(of: loginButtonFinder, matching: find.text('Login')), findsOneWidget);
      expect(find.descendant(of: loginButtonFinder, matching: find.byIcon(Icons.login)), findsOneWidget);

      await tester.tap(loginButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Tela de Login Rota'), findsOneWidget);
    });

    testWidgets('deve exibir botão de Login mesmo quando authController for nulo', (tester) async {
      await tester.pumpWidget(createTestApp(authController: null));
      await tester.pumpAndSettle();

      final loginButtonFinder = find.byKey(const Key('auth-login-button'));
      expect(loginButtonFinder, findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('deve exibir menu de perfil do usuário e ação de Sair quando autenticado', (tester) async {
      await controller.login(
        email: 'lucas@player.com.br',
        password: _samplePassword(),
      );

      await tester.pumpWidget(createTestApp(authController: controller));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-login-button')), findsNothing);
      expect(find.byKey(const Key('auth-user-menu')), findsOneWidget);
      expect(find.text('Lucas'), findsOneWidget);

      await tester.tap(find.byKey(const Key('auth-user-menu')));
      await tester.pumpAndSettle();

      expect(find.text('Lucas Contador'), findsOneWidget);
      expect(find.text('lucas@player.com.br'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
    });
  });
}

