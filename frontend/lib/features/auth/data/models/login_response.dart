import '../../../responsible/domain/entities/responsible.dart';
import '../../domain/entities/auth_session.dart';

class LoginResponse {
  final String token;
  final String? tokenType;
  final int? expiresIn;
  final Responsible responsible;

  const LoginResponse({
    required this.token,
    this.tokenType,
    this.expiresIn,
    required this.responsible,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? json['accessToken']) as String;
    final userJson = (json['user'] ?? json['responsible']) as Map<String, dynamic>?;

    final responsible = userJson != null
        ? Responsible.fromJson(userJson)
        : Responsible.fromJson(json);

    return LoginResponse(
      token: token,
      tokenType: json['tokenType'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      responsible: responsible,
    );
  }

  AuthSession toEntity() => AuthSession(
        token: token,
        responsible: responsible,
      );
}

