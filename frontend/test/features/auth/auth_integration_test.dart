import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:player_contabilidade_front/features/auth/data/models/login_request.dart';
import 'package:player_contabilidade_front/features/auth/data/models/register_request.dart';
import 'package:player_contabilidade_front/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('Auth Integration Layer', () {
    test('login deve autenticar com sucesso e salvar token no ApiClient', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/auth/login');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'carlos@empresa.com');

        return http.Response(
          jsonEncode({
            'token': 'jwt-super-seguro-123',
            'responsible': {
              'id': 1,
              'name': 'Carlos Silva',
              'email': 'carlos@empresa.com',
              'active': true,
              'createdAt': '2026-11-10T10:00:00',
              'updatedAt': '2026-11-10T10:00:00',
            }
          }),
          200,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AuthRemoteDataSourceImpl(apiClient);
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource, apiClient: apiClient);

      final session = await repository.login(
        email: 'carlos@empresa.com',
        password: 'senhaSegura123',
      );

      expect(session.token, 'jwt-super-seguro-123');
      expect(session.responsible.name, 'Carlos Silva');
      expect(repository.isAuthenticated, isTrue);
      expect(repository.currentToken, 'jwt-super-seguro-123');
      expect(apiClient.isAuthenticated, isTrue);

      await repository.logout();
      expect(repository.isAuthenticated, isFalse);
      expect(repository.currentToken, isNull);
      expect(apiClient.isAuthenticated, isFalse);
    });

    test('register deve cadastrar novo usuário público com sucesso', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/auth/register');

        return http.Response(
          jsonEncode({
            'id': 2,
            'name': 'Novo Usuário',
            'email': 'novo@empresa.com',
            'active': true,
            'createdAt': '2026-11-10T11:00:00',
            'updatedAt': '2026-11-10T11:00:00',
          }),
          201,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AuthRemoteDataSourceImpl(apiClient);
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource, apiClient: apiClient);

      final user = await repository.register(
        name: 'Novo Usuário',
        email: 'novo@empresa.com',
        password: 'senhaSegura123',
      );

      expect(user.id, 2);
      expect(user.name, 'Novo Usuário');
      expect(user.email, 'novo@empresa.com');
    });

    test('RegisterRequest toJson deve serializar campos corretamente', () {
      const request = RegisterRequest(
        name: 'Maria',
        email: 'maria@empresa.com',
        password: 'password123',
        active: true,
      );
      final json = request.toJson();
      expect(json['name'], 'Maria');
      expect(json['email'], 'maria@empresa.com');
      expect(json['password'], 'password123');
      expect(json['active'], isTrue);
    });

    test('login com credenciais incorretas deve lançar BAD_CREDENTIALS', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'BAD_CREDENTIALS',
            'message': 'E-mail ou senha inválidos',
            'details': [],
          }),
          401,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      expect(
        () => dataSource.login(
          const LoginRequest(email: 'errado@empresa.com', password: 'errado'),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
              .having((e) => e.code, 'code', 'BAD_CREDENTIALS'),
        ),
      );
    });
  });
}
