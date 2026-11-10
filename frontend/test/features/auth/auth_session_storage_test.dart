import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_session_storage.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

String _sampleToken() => ['mock', 'jwt', 'token', 'xyz'].join('.');

void main() {
  group('AuthSessionStorage - InMemoryAuthSessionStorage', () {
    late InMemoryAuthSessionStorage storage;

    setUp(() {
      storage = InMemoryAuthSessionStorage();
    });

    test('deve iniciar sem sessão persistida', () async {
      final session = await storage.readSession();
      expect(session, isNull);
    });

    test('deve persistir e recuperar sessão de autenticação com dados do usuário', () async {
      const user = Responsible(
        id: 42,
        name: 'Maria Analista',
        email: 'maria@player.com.br',
        active: true,
      );
      final sessionToSave = AuthSession(
        token: _sampleToken(),
        responsible: user,
      );

      await storage.saveSession(sessionToSave);
      final loaded = await storage.readSession();

      expect(loaded, isNotNull);
      expect(loaded!.token, equals(_sampleToken()));
      expect(loaded.responsible.id, equals(42));
      expect(loaded.responsible.name, equals('Maria Analista'));
      expect(loaded.responsible.email, equals('maria@player.com.br'));
      expect(loaded.responsible.active, isTrue);
    });

    test('deve remover sessão ao executar clearSession', () async {
      const user = Responsible(
        id: 1,
        name: 'Contador Teste',
        email: 'contador@player.com.br',
        active: true,
      );
      final sessionToSave = AuthSession(
        token: _sampleToken(),
        responsible: user,
      );

      await storage.saveSession(sessionToSave);
      expect(await storage.readSession(), isNotNull);

      await storage.clearSession();
      expect(await storage.readSession(), isNull);
    });
  });
}

