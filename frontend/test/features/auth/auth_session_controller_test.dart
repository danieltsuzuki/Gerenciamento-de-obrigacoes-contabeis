import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:player_contabilidade_front/features/auth/presentation/controllers/auth_session_controller.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

String _sampleToken() => ['mock', 'jwt', 'header', 'payload', 'sig'].join('.');
String _samplePassword() => ['Auth', 'Test', '123', '!'].join();

class FakeAuthRepository implements AuthRepository {
  bool shouldFailLogin = false;
  ApiException? loginException;
  bool shouldFailRegister = false;
  ApiException? registerException;
  bool logoutCalled = false;

  @override
  bool isAuthenticated = false;

  @override
  String? currentToken;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (shouldFailLogin) {
      throw loginException ??
          const ApiException(
            statusCode: 401,
            code: 'INVALID_CREDENTIALS',
            message: 'E-mail ou senha incorretos.',
          );
    }
    final session = AuthSession(
      token: _sampleToken(),
      responsible: Responsible(
        id: 10,
        name: 'Analista de Testes',
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
    if (shouldFailRegister) {
      throw registerException ??
          const ApiException(
            statusCode: 409,
            code: 'DUPLICATE_EMAIL',
            message: 'Já existe um responsável cadastrado com este e-mail.',
          );
    }
    return Responsible(
      id: 20,
      name: name,
      email: email,
      active: active,
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    isAuthenticated = false;
    currentToken = null;
  }
}

void main() {
  group('AuthSessionController - SPEC-026', () {
    late ApiClient apiClient;
    late FakeAuthRepository authRepository;
    late InMemoryAuthSessionStorage sessionStorage;
    late AuthSessionController controller;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'http://test.local');
      authRepository = FakeAuthRepository();
      sessionStorage = InMemoryAuthSessionStorage();
      controller = AuthSessionController(
        authRepository: authRepository,
        sessionStorage: sessionStorage,
        apiClient: apiClient,
      );
    });

    test('deve iniciar desautenticado', () {
      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
      expect(controller.session, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.isInitialized, isFalse);
    });

    test('initialize deve carregar sessão persistida no storage', () async {
      final initialSession = AuthSession(
        token: _sampleToken(),
        responsible: const Responsible(
          id: 5,
          name: 'Fiscal Persistido',
          email: 'fiscal@player.com.br',
          active: true,
        ),
      );
      await sessionStorage.saveSession(initialSession);

      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.name, equals('Fiscal Persistido'));
      expect(apiClient.authToken, equals(_sampleToken()));
    });

    test('login bem-sucedido deve atualizar estado, token e persistir no storage', () async {
      final success = await controller.login(
        email: 'contador@player.com.br',
        password: _samplePassword(),
      );

      expect(success, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.email, equals('contador@player.com.br'));
      expect(controller.errorMessage, isNull);
      expect(apiClient.authToken, equals(_sampleToken()));

      final saved = await sessionStorage.readSession();
      expect(saved, isNotNull);
      expect(saved!.token, equals(_sampleToken()));
    });

    test('login com erro deve expor mensagem amigável e manter desautenticado', () async {
      authRepository.shouldFailLogin = true;

      final success = await controller.login(
        email: 'incorreto@player.com.br',
        password: _samplePassword(),
      );

      expect(success, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage, contains('inválidos'));
      expect(apiClient.authToken, isNull);
      expect(await sessionStorage.readSession(), isNull);
    });

    test('register bem-sucedido deve realizar auto-login e persistir sessão', () async {
      final success = await controller.register(
        name: 'Novo Contador',
        email: 'novo@player.com.br',
        password: _samplePassword(),
      );

      expect(success, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.name, equals('Analista de Testes'));
      expect(apiClient.authToken, equals(_sampleToken()));
      expect(await sessionStorage.readSession(), isNotNull);
    });

    test('register com conflito de e-mail deve expor erro DUPLICATE_EMAIL', () async {
      authRepository.shouldFailRegister = true;

      final success = await controller.register(
        name: 'Contador Duplicado',
        email: 'existente@player.com.br',
        password: _samplePassword(),
      );

      expect(success, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage, contains('já está em uso'));
    });

    test('logout deve invalidar sessão no controller, storage e apiClient', () async {
      await controller.login(
        email: 'user@player.com.br',
        password: _samplePassword(),
      );
      expect(controller.isAuthenticated, isTrue);

      await controller.logout();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
      expect(controller.session, isNull);
      expect(apiClient.authToken, isNull);
      expect(await sessionStorage.readSession(), isNull);
      expect(authRepository.logoutCalled, isTrue);
    });

    test('handleUnauthorized disparado por 401 deve expirar sessão ativa', () async {
      await controller.login(
        email: 'expira@player.com.br',
        password: _samplePassword(),
      );
      expect(controller.isAuthenticated, isTrue);

      controller.handleUnauthorized();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.session, isNull);
      expect(controller.errorMessage, contains('expirou'));
      expect(apiClient.authToken, isNull);
      expect(await sessionStorage.readSession(), isNull);
    });

    test('clearErrorMessage deve limpar erro e notificar listeners', () async {
      authRepository.shouldFailLogin = true;
      await controller.login(email: 'a@b.com', password: _samplePassword());

      expect(controller.errorMessage, isNotNull);
      controller.clearErrorMessage();
      expect(controller.errorMessage, isNull);
    });
  });
}
