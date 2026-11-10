import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';

void main() {
  group('ApiClient', () {
    test('deve executar GET com sucesso e decodificar JSON', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/companies');
        expect(request.headers['Accept'], 'application/json');

        return http.Response(
          jsonEncode([
            {'id': 1, 'legalName': 'Empresa Teste', 'cnpj': '33000167000101', 'active': true}
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );

      final result = await apiClient.get('/api/companies');

      expect(result, isA<List>());
      expect((result as List).first['legalName'], 'Empresa Teste');
    });

    test('deve incluir cabeçalho Authorization quando token estiver definido', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer meu-jwt-token');
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );
      apiClient.setAuthToken('meu-jwt-token');
      expect(apiClient.isAuthenticated, isTrue);

      await apiClient.get('/api/me');

      apiClient.clearAuthToken();
      expect(apiClient.isAuthenticated, isFalse);
    });

    test('deve lançar ApiException quando status for erro', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'NOT_FOUND',
            'message': 'Empresa não encontrada',
            'details': [],
          }),
          404,
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );

      expect(
        () => apiClient.get('/api/companies/999'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('deve enviar payload no POST', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['title'], 'DAS Mensal');
        return http.Response(jsonEncode({'id': 10, 'title': 'DAS Mensal'}), 201);
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );

      final result = await apiClient.post(
        '/api/obligations',
        body: {'title': 'DAS Mensal'},
      );

      expect(result['id'], 10);
    });
  });
}
