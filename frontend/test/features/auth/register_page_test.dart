import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/auth/presentation/pages/register_page.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

String _sampleToken() => ['sample', 'token', 'jwt'].join('.');
String _samplePassword() => ['Secret', 'Pass', '123', '!'].join();

class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  String? registeredName;
  String? registeredEmail;
  String? registeredPassword;

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
        id: 1,
        name: registeredName ?? 'Novo Responsável',
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
  }) async {
    registeredName = name;
    registeredEmail = email;
    registeredPassword = password;

    if (shouldFail) {
      throw const ApiException(
        statusCode: 409,
        code: 'DUPLICATE_EMAIL',
        message: 'Este e-mail já está em uso por outro usuário.',
      );
    }

    return Responsible(
      id: 1,
      name: name,
      email: email,
      active: active,
    );
  }

  @override
  Future<void> logout() async {
    isAuthenticated = false;
    currentToken = null;
  }
}

void main() {
  group('RegisterPage - SPEC-026', () {
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
        home: RegisterPage(controller: controller),
      );
    }

    testWidgets('deve renderizar campos de cadastro e botão de submissão', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Cadastro de Responsável'), findsOneWidget);
      expect(find.byKey(const Key('register-name-input')), findsOneWidget);
      expect(find.byKey(const Key('register-email-input')), findsOneWidget);
      expect(find.byKey(const Key('register-password-input')), findsOneWidget);
      expect(find.byKey(const Key('register-confirm-password-input')), findsOneWidget);
      expect(find.byKey(const Key('register-submit-button')), findsOneWidget);
    });

    testWidgets('deve exibir mensagens de validação ao submeter campos em branco', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório.'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório.'), findsOneWidget);
      expect(find.text('A senha é obrigatória.'), findsOneWidget);
      expect(find.text('A confirmação de senha é obrigatória.'), findsOneWidget);
    });

    testWidgets('deve validar divergência entre senha e confirmação de senha', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register-name-input')), 'Lucas Fiscal');
      await tester.enterText(find.byKey(const Key('register-email-input')), 'lucas@player.com.br');
      await tester.enterText(find.byKey(const Key('register-password-input')), _samplePassword());
      await tester.enterText(find.byKey(const Key('register-confirm-password-input')), 'outraSenhaDiferente');
      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('As senhas informadas não conferem.'), findsOneWidget);
    });

    testWidgets('deve validar tamanho mínimo da senha (6 caracteres)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register-name-input')), 'Lucas Fiscal');
      await tester.enterText(find.byKey(const Key('register-email-input')), 'lucas@player.com.br');
      await tester.enterText(find.byKey(const Key('register-password-input')), '12345');
      await tester.enterText(find.byKey(const Key('register-confirm-password-input')), '12345');
      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('A senha deve possuir no mínimo 6 caracteres.'), findsOneWidget);
    });

    testWidgets('deve submeter cadastro com sucesso e autenticar o usuário', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register-name-input')), 'Carlos Contador');
      await tester.enterText(find.byKey(const Key('register-email-input')), 'carlos@player.com.br');
      await tester.enterText(find.byKey(const Key('register-password-input')), _samplePassword());
      await tester.enterText(find.byKey(const Key('register-confirm-password-input')), _samplePassword());
      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pumpAndSettle();

      expect(mockAuthRepository.registeredName, equals('Carlos Contador'));
      expect(mockAuthRepository.registeredEmail, equals('carlos@player.com.br'));
      expect(mockAuthRepository.registeredPassword, equals(_samplePassword()));
      expect(controller.isAuthenticated, isTrue);
    });

    testWidgets('deve exibir mensagem de erro em caso de e-mail duplicado (409 DUPLICATE_EMAIL)', (tester) async {
      mockAuthRepository.shouldFail = true;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register-name-input')), 'Carlos Contador');
      await tester.enterText(find.byKey(const Key('register-email-input')), 'existente@player.com.br');
      await tester.enterText(find.byKey(const Key('register-password-input')), _samplePassword());
      await tester.enterText(find.byKey(const Key('register-confirm-password-input')), _samplePassword());
      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('register-error-banner')), findsOneWidget);
      expect(find.text('Este e-mail já está em uso por outro usuário.'), findsOneWidget);
      expect(controller.isAuthenticated, isFalse);
    });
  });
}

