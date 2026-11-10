import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../responsible/domain/entities/responsible.dart';
import '../../domain/entities/auth_session.dart';

abstract class AuthSessionStorage {
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> readSession();
  Future<void> clearSession();
}

class SecureAuthSessionStorage implements AuthSessionStorage {
  static const _sessionKey = 'auth_session_data';
  final FlutterSecureStorage _storage;

  const SecureAuthSessionStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveSession(AuthSession session) async {
    try {
      final data = jsonEncode({
        'token': session.token,
        'responsible': session.responsible.toJson(),
      });
      await _storage.write(key: _sessionKey, value: data);
    } catch (_) {
      // Falha de gravação no armazenamento seguro não deve interromper a sessão em memória
    }
  }

  @override
  Future<AuthSession?> readSession() async {
    try {
      final data = await _storage.read(key: _sessionKey);
      if (data == null || data.isEmpty) return null;
      final json = jsonDecode(data) as Map<String, dynamic>;
      final token = json['token'] as String;
      final responsibleJson = json['responsible'] as Map<String, dynamic>;
      return AuthSession(
        token: token,
        responsible: Responsible.fromJson(responsibleJson),
      );
    } catch (_) {
      try {
        await clearSession();
      } catch (_) {}
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {}
  }
}

class InMemoryAuthSessionStorage implements AuthSessionStorage {
  AuthSession? _session;

  InMemoryAuthSessionStorage([AuthSession? initialSession])
      : _session = initialSession;

  @override
  Future<void> saveSession(AuthSession session) async {
    _session = session;
  }

  @override
  Future<AuthSession?> readSession() async {
    return _session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }
}
