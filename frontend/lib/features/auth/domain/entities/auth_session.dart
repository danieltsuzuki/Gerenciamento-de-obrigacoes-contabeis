import '../../../responsible/domain/entities/responsible.dart';

class AuthSession {
  final String token;
  final Responsible responsible;

  const AuthSession({
    required this.token,
    required this.responsible,
  });
}

