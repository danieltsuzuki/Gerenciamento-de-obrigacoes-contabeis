import '../../../../core/network/api_client.dart';
import '../../../responsible/domain/entities/responsible.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final ApiClient _apiClient;
  AuthSession? _currentSession;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required ApiClient apiClient,
  })  : _remoteDataSource = remoteDataSource,
        _apiClient = apiClient;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
    final session = response.toEntity();
    _currentSession = session;
    _apiClient.setAuthToken(session.token);
    return session;
  }

  @override
  Future<Responsible> register({
    required String name,
    required String email,
    required String password,
    bool active = true,
  }) {
    return _remoteDataSource.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        active: active,
      ),
    );
  }

  @override
  Future<void> logout() async {
    _currentSession = null;
    _apiClient.clearAuthToken();
  }

  @override
  bool get isAuthenticated => _currentSession != null && _apiClient.isAuthenticated;

  @override
  String? get currentToken => _currentSession?.token;
}

