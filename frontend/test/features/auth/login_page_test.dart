import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/routing/app_routes.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/auth/presentation/pages/login_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

String _sampleToken() => ['sample', 'token', 'jwt'].join('.');
String _samplePassword() => ['Secret', 'Pass', '123', '!'].join();

class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  String? lastEmail;
  String? lastPassword;

  @override
  bool isAuthenticated = false;

  @override
  String? currentToken;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;

    if (shouldFail) {
      throw const ApiException(
        statusCode: 401,
        code: 'INVALID_CREDENTIALS',
        message: 'E-mail ou senha inválidos.',
      );
    }

    final session = AuthSession(
      token: _sampleToken(),
      responsible: Responsible(
        id: 1,
        name: 'Carlos Contador',
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
  group('LoginPage - SPEC-026', () {
    late MockAuthRepository mockAuthRepository;
    late InMemoryAuthSessionStorage sessionStorage;
    late ApiClient apiClient;
    late AuthSessionController controller;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      sessionStorage = InMemoryAuthSessionStorage();
      apiClient = ApiClient(baseUrl: 'http://test.local');
      controller = AuthSessionController(
        authRepository: mockAuthRepository,
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginPage(controller: controller),
        routes: {
          AppRoutes.register: (context) => Scaffold(
                appBar: AppBar(title: const Text('Cadastro Mock')),
                body: const Text('Tela de Cadastro'),
              ),
        },
      );
    }

    testWidgets('deve renderizar campos de e-mail, senha e botões', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Identificação de Acesso'), findsOneWidget);
      expect(find.byKey(const Key('login-email-input')), findsOneWidget);
      expect(find.byKey(const Key('login-password-input')), findsOneWidget);
      expect(find.byKey(const Key('login-submit-button')), findsOneWidget);
      expect(find.byKey(const Key('login-to-register-button')), findsOneWidget);
    });

    testWidgets('deve exibir mensagens de validação ao submeter formulário vazio', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('O e-mail é obrigatório.'), findsOneWidget);
      expect(find.text('A senha é obrigatória.'), findsOneWidget);
    });

    testWidgets('deve validar formato inválido de e-mail e tamanho mínimo de senha', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login-email-input')), 'emailinvalido');
      await tester.enterText(find.byKey(const Key('login-password-input')), '123');
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('A senha deve possuir no mínimo 6 caracteres.'), findsOneWidget);
    });

    testWidgets('deve alternar visibilidade da senha ao clicar no ícone de olho', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byKey(const Key('login-toggle-password-button')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('deve submeter credenciais e autenticar com sucesso', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login-email-input')), 'carlos@player.com.br');
      await tester.enterText(find.byKey(const Key('login-password-input')), _samplePassword());
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(mockAuthRepository.lastEmail, equals('carlos@player.com.br'));
      expect(mockAuthRepository.lastPassword, equals(_samplePassword()));
      expect(controller.isAuthenticated, isTrue);
    });

    testWidgets('deve exibir banner de erro quando a API retornar 401', (tester) async {
      mockAuthRepository.shouldFail = true;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login-email-input')), 'errado@player.com.br');
      await tester.enterText(find.byKey(const Key('login-password-input')), _samplePassword());
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
      expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
      expect(controller.isAuthenticated, isFalse);
    });

    testWidgets('deve navegar para a tela de cadastro ao tocar no link', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login-to-register-button')));
      await tester.pumpAndSettle();

      expect(find.text('Tela de Cadastro'), findsOneWidget);
    });
  });
}
