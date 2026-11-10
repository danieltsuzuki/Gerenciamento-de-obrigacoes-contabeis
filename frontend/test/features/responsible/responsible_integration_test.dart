import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/features/responsible/data/datasources/responsible_remote_datasource.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/repositories/responsible_repository_impl.dart';

void main() {
  group('Responsible Integration Layer', () {
    test('getResponsibles deve retornar PageResponse<Responsible>', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/responsibles');

        return http.Response(
          jsonEncode({
            'content': [
              {
                'id': 1,
                'name': 'Ana Silva',
                'email': 'ana@empresa.com',
                'active': true,
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
      final dataSource = ResponsibleRemoteDataSource(apiClient);
      final repository = ResponsibleRepositoryImpl(dataSource);

      final page = await repository.getResponsibles();

      expect(page.content.length, 1);
      expect(page.content.first.name, 'Ana Silva');
    });

    test('getResponsibleById, createResponsible e updateResponsible devem funcionar', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({'id': 1, 'name': 'Ana Silva', 'email': 'ana@empresa.com', 'active': true}),
            200,
          );
        } else if (request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 3, 'name': 'Roberto', 'email': 'roberto@empresa.com', 'active': true}),
            201,
          );
        } else if (request.method == 'PUT') {
          return http.Response(
            jsonEncode({'id': 3, 'name': 'Roberto Santos', 'email': 'roberto@empresa.com', 'active': false}),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = ResponsibleRemoteDataSource(apiClient);
      final repository = ResponsibleRepositoryImpl(dataSource);

      final resp = await repository.getResponsibleById(1);
      expect(resp.name, 'Ana Silva');

      final created = await repository.createResponsible(
        const CreateResponsibleRequest(
          name: 'Roberto',
          email: 'roberto@empresa.com',
          password: 'senhaSegura123',
        ),
      );
      expect(created.id, 3);

      final updated = await repository.updateResponsible(
        3,
        const UpdateResponsibleRequest(
          name: 'Roberto Santos',
          email: 'roberto@empresa.com',
          active: false,
        ),
      );
      expect(updated.active, isFalse);
    });
  });
}

