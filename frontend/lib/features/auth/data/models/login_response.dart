import '../../../responsible/domain/entities/responsible.dart';
import '../../domain/entities/auth_session.dart';

class LoginResponse {
  final String token;
  final Responsible responsible;

  const LoginResponse({
    required this.token,
    required this.responsible,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      responsible: Responsible.fromJson(json['responsible'] as Map<String, dynamic>),
    );
  }

  AuthSession toEntity() => AuthSession(
        token: token,
        responsible: responsible,
      );
}

