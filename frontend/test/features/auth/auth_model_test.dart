import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/features/auth/data/models/login_request.dart';
import 'package:player_contabilidade_front/features/auth/data/models/login_response.dart';
import 'package:player_contabilidade_front/features/auth/data/models/register_request.dart';
import 'package:player_contabilidade_front/features/auth/domain/entities/auth_session.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';

void main() {
  group('Auth Models and Entities - SPEC-023', () {
    test('LoginRequest.toJson deve gerar corpo JSON com email e password', () {
      const request = LoginRequest(
        email: 'user@empresa.com',
        password: 'Password123!',
      );

      final json = request.toJson();

      expect(json['email'], 'user@empresa.com');
      expect(json['password'], 'Password123!');
    });

    test('RegisterRequest.toJson deve gerar corpo JSON completo', () {
      const request = RegisterRequest(
        name: 'Maria Contadora',
        email: 'maria@empresa.com',
        password: 'Password123!',
        active: true,
      );

      final json = request.toJson();

      expect(json['name'], 'Maria Contadora');
      expect(json['email'], 'maria@empresa.com');
      expect(json['password'], 'Password123!');
      expect(json['active'], isTrue);
    });

    test('LoginResponse.fromJson e toEntity devem processar token e dados do usuário', () {
      final json = {
        'token': 'jwt-super-token-123',
        'tokenType': 'Bearer',
        'expiresIn': 86400,
        'user': {
          'id': 7,
          'name': 'Lucas Santos',
          'email': 'lucas@empresa.com',
          'active': true,
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'jwt-super-token-123');
      expect(response.tokenType, 'Bearer');
      expect(response.expiresIn, 86400);
      expect(response.responsible.id, 7);
      expect(response.responsible.name, 'Lucas Santos');

      final session = response.toEntity();
      expect(session.token, 'jwt-super-token-123');
      expect(session.responsible.id, 7);
    });

    test('AuthSession deve encapsular token e entidade Responsible', () {
      const session = AuthSession(
        token: 'token-abc',
        responsible: Responsible(
          id: 99,
          name: 'Teste',
          email: 'teste@teste.com',
          active: true,
        ),
      );

      expect(session.token, 'token-abc');
      expect(session.responsible.name, 'Teste');
    });
  });
}

