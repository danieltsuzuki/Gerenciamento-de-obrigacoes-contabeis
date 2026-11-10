import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';

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
      expect(apiClient.authToken, 'meu-jwt-token');

      await apiClient.get('/api/me');

      apiClient.clearAuthToken();
      expect(apiClient.isAuthenticated, isFalse);
      expect(apiClient.authToken, isNull);
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

    test('deve enviar payload no POST, PUT e PATCH', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['title'], 'DAS Mensal');
          return http.Response(jsonEncode({'id': 10, 'title': 'DAS Mensal'}), 201);
        } else if (request.method == 'PUT') {
          return http.Response(jsonEncode({'id': 10, 'title': 'DAS Atualizado'}), 200);
        } else if (request.method == 'PATCH') {
          return http.Response(jsonEncode({'id': 10, 'status': 'IN_PROGRESS'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );

      final postResult = await apiClient.post(
        '/api/obligations',
        body: {'title': 'DAS Mensal'},
      );
      expect(postResult['id'], 10);

      final putResult = await apiClient.put(
        '/api/obligations/10',
        body: {'title': 'DAS Atualizado'},
      );
      expect(putResult['title'], 'DAS Atualizado');

      final patchResult = await apiClient.patch(
        '/api/obligations/10/status',
        body: {'status': 'IN_PROGRESS'},
      );
      expect(patchResult['status'], 'IN_PROGRESS');
    });

    test('deve executar multipartRequest e enviar arquivo binário com Bearer', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/obligations/1/attachments');
        expect(request.headers['Authorization'], 'Bearer token-anexo');

        return http.Response(
          jsonEncode({
            'id': 100,
            'obligationId': 1,
            'name': 'comprovante.pdf',
            'contentType': 'application/pdf',
            'size': 1024,
            'uploadedAt': '2026-11-10T12:00:00',
          }),
          201,
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );
      apiClient.setAuthToken('token-anexo');

      final result = await apiClient.multipartRequest(
        '/api/obligations/1/attachments',
        fieldName: 'file',
        filename: 'comprovante.pdf',
        bytes: utf8.encode('%PDF-1.4 mock content'),
        contentType: 'application/pdf',
      );

      expect(result['id'], 100);
      expect(result['name'], 'comprovante.pdf');
    });

    test('deve executar download de arquivo e extrair Content-Disposition', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/attachments/5/download');

        return http.Response.bytes(
          Uint8List.fromList([1, 2, 3, 4, 5]),
          200,
          headers: {
            'content-type': 'application/pdf',
            'content-disposition': 'attachment; filename="documento_fiscal.pdf"',
          },
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'http://api.local',
      );

      final downloaded = await apiClient.download('/api/attachments/5/download');

      expect(downloaded.filename, 'documento_fiscal.pdf');
      expect(downloaded.contentType, 'application/pdf');
      expect(downloaded.bytes.length, 5);
    });

    test('deve processar PageResponse com paginação do Spring Data', () {
      final json = {
        'content': [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
        'totalElements': 20,
        'totalPages': 10,
        'size': 2,
        'number': 0,
        'first': true,
        'last': false,
        'empty': false,
      };

      final page = PageResponse<String>.fromJson(
        json,
        (item) => item['name'] as String,
      );

      expect(page.content, ['Item 1', 'Item 2']);
      expect(page.totalElements, 20);
      expect(page.totalPages, 10);
      expect(page.size, 2);
      expect(page.number, 0);
      expect(page.first, isTrue);
      expect(page.last, isFalse);
      expect(page.empty, isFalse);
    });
  });
}
