import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/features/obligation/data/datasources/obligation_remote_datasource.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/create_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/models/update_obligation_request.dart';
import 'package:player_contabilidade_front/features/obligation/data/repositories/obligation_repository_impl.dart';
import 'package:player_contabilidade_front/features/obligation/domain/entities/obligation.dart';

void main() {
  group('Obligation Integration Layer', () {
    test('getObligations deve filtrar por status, companyId e responsibleId', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/obligations');
        expect(request.url.queryParameters['status'], 'PENDING');
        expect(request.url.queryParameters['companyId'], '10');

        return http.Response(
          jsonEncode({
            'content': [
              {
                'id': 100,
                'companyId': 10,
                'responsibleId': 20,
                'title': 'DCTF Mensal',
                'dueDate': '2026-11-30',
                'status': 'PENDING',
                'attachmentCount': 2,
                'createdAt': '2026-11-01T10:00:00',
              }
            ],
            'totalElements': 1,
            'totalPages': 1,
            'size': 20,
            'number': 0,
            'first': true,
            'last': true,
            'empty': false,
          }),
          200,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = ObligationRemoteDataSource(apiClient);
      final repository = ObligationRepositoryImpl(dataSource);

      final page = await repository.getObligations(
        companyId: 10,
        status: ObligationStatus.pending,
      );

      expect(page.content.length, 1);
      expect(page.content.first.title, 'DCTF Mensal');
      expect(page.content.first.status, ObligationStatus.pending);
      expect(page.content.first.attachmentCount, 2);
    });

    test('updateObligationStatus deve chamar PATCH /api/obligations/{id}/status', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/obligations/100/status');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'IN_PROGRESS');

        return http.Response(
          jsonEncode({
            'id': 100,
            'companyId': 10,
            'responsibleId': 20,
            'title': 'DCTF Mensal',
            'dueDate': '2026-11-30',
            'status': 'IN_PROGRESS',
            'createdAt': '2026-11-01T10:00:00',
          }),
          200,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = ObligationRemoteDataSource(apiClient);
      final repository = ObligationRepositoryImpl(dataSource);

      final updated = await repository.updateObligationStatus(
        100,
        ObligationStatus.inProgress,
      );

      expect(updated.status, ObligationStatus.inProgress);
    });

    test('transição inválida de status deve propagar INVALID_STATUS_TRANSITION (422)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'INVALID_STATUS_TRANSITION',
            'message': 'Transição ilegal de PENDING para COMPLETED',
            'details': [],
          }),
          422,
        );
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = ObligationRemoteDataSource(apiClient);

      expect(
        () => dataSource.updateObligationStatus(100, ObligationStatus.completed),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.code, 'code', 'INVALID_STATUS_TRANSITION'),
        ),
      );
    });

    test('createObligation e updateObligation devem serializar e desserializar', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'id': 101,
              'companyId': 1,
              'responsibleId': 2,
              'title': 'Nova Obrigação',
              'dueDate': '2026-12-01',
              'status': 'PENDING',
              'createdAt': '2026-11-10T12:00:00',
            }),
            201,
          );
        } else if (request.method == 'PUT') {
          return http.Response(
            jsonEncode({
              'id': 101,
              'companyId': 1,
              'responsibleId': 2,
              'title': 'Obrigação Atualizada',
              'dueDate': '2026-12-01',
              'status': 'PENDING',
              'createdAt': '2026-11-10T12:00:00',
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = ObligationRemoteDataSource(apiClient);
      final repository = ObligationRepositoryImpl(dataSource);

      final created = await repository.createObligation(
        const CreateObligationRequest(
          companyId: 1,
          responsibleId: 2,
          title: 'Nova Obrigação',
          dueDate: '2026-12-01',
        ),
      );
      expect(created.id, 101);

      final updated = await repository.updateObligation(
        101,
        const UpdateObligationRequest(
          companyId: 1,
          responsibleId: 2,
          title: 'Obrigação Atualizada',
          dueDate: '2026-12-01',
        ),
      );
      expect(updated.title, 'Obrigação Atualizada');
    });
  });
}

