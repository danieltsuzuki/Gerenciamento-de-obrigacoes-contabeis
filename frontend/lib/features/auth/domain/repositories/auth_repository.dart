import '../../../responsible/domain/entities/responsible.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<Responsible> register({
    required String name,
    required String email,
    required String password,
    bool active = true,
  });

  Future<void> logout();

  bool get isAuthenticated;
  String? get currentToken;
}

