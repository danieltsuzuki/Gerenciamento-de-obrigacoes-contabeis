import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../responsible/domain/entities/responsible.dart';
import '../../data/datasources/auth_session_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthSessionController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AuthSessionStorage _sessionStorage;
  final ApiClient _apiClient;

  AuthSession? _currentSession;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthSessionController({
    required AuthRepository authRepository,
    required AuthSessionStorage sessionStorage,
    required ApiClient apiClient,
  })  : _authRepository = authRepository,
        _sessionStorage = sessionStorage,
        _apiClient = apiClient {
    _apiClient.onUnauthorized = handleUnauthorized;
  }

  bool get isAuthenticated => _currentSession != null;
  AuthSession? get session => _currentSession;
  Responsible? get currentUser => _currentSession?.responsible;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final storedSession = await _sessionStorage.readSession();
      if (storedSession != null && storedSession.token.isNotEmpty) {
        _currentSession = storedSession;
        _apiClient.setAuthToken(storedSession.token);
      }
    } catch (_) {
      await _sessionStorage.clearSession();
      _currentSession = null;
      _apiClient.clearAuthToken();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _authRepository.login(
        email: email.trim(),
        password: password,
      );
      _currentSession = session;
      _apiClient.setAuthToken(session.token);
      await _sessionStorage.saveSession(session);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
      if (e.code == 'BAD_CREDENTIALS' || e.statusCode == 401) {
        _errorMessage = 'E-mail ou senha inválidos.';
      } else {
        _errorMessage = e.message;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Falha ao autenticar. Verifique sua conexão.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    bool active = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
        active: active,
      );

      // Decisão do projeto: Login automático com as mesmas credenciais
      try {
        final session = await _authRepository.login(
          email: email.trim(),
          password: password,
        );
        _currentSession = session;
        _apiClient.setAuthToken(session.token);
        await _sessionStorage.saveSession(session);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (_) {
        // Se o cadastro foi salvo mas o login automático falhou, não sinaliza erro de registro
        _isLoading = false;
        _errorMessage = 'Cadastro realizado com sucesso! Faça login com suas credenciais.';
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _isLoading = false;
      if (e.code == 'DUPLICATE_EMAIL' || e.statusCode == 409 || e.statusCode == 422) {
        _errorMessage = 'Este e-mail já está em uso por outro usuário.';
      } else {
        _errorMessage = e.message;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Falha ao registrar usuário. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentSession = null;
    _apiClient.clearAuthToken();
    await _sessionStorage.clearSession();
    await _authRepository.logout();
    notifyListeners();
  }

  void handleUnauthorized() {
    if (_currentSession != null) {
      _currentSession = null;
      _sessionStorage.clearSession();
      _apiClient.clearAuthToken();
      _errorMessage = 'Sua sessão expirou. Faça login novamente para continuar.';
      notifyListeners();
    }
  }
}

