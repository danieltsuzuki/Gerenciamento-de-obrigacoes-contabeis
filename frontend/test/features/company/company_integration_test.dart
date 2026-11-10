import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player_contabilidade_front/core/network/api_client.dart';
import 'package:player_contabilidade_front/features/company/data/datasources/company_remote_datasource.dart';
import 'package:player_contabilidade_front/features/company/data/models/create_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/models/update_company_request.dart';
import 'package:player_contabilidade_front/features/company/data/repositories/company_repository_impl.dart';

void main() {
  group('Company Integration Layer', () {
    test('getCompanies deve retornar PageResponse<Company> paginado', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/companies');
        expect(request.url.queryParameters['active'], 'true');
        expect(request.url.queryParameters['page'], '0');
        expect(request.url.queryParameters['size'], '20');

        return http.Response(
          jsonEncode({
            'content': [
              {
                'id': 1,
                'legalName': 'Petrobras S.A.',
                'tradeName': 'Petrobras',
                'cnpj': '33000167000101',
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
      final dataSource = CompanyRemoteDataSource(apiClient);
      final repository = CompanyRepositoryImpl(dataSource);

      final page = await repository.getCompanies(active: true);

      expect(page.content.length, 1);
      expect(page.content.first.legalName, 'Petrobras S.A.');
      expect(page.totalElements, 1);
    });

    test('getCompanyById, createCompany e updateCompany devem funcionar corretamente', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/companies/1') {
          return http.Response(
            jsonEncode({
              'id': 1,
              'legalName': 'Petrobras S.A.',
              'cnpj': '33000167000101',
              'active': true,
            }),
            200,
          );
        } else if (request.method == 'POST' && request.url.path == '/api/companies') {
          return http.Response(
            jsonEncode({
              'id': 2,
              'legalName': 'Vale S.A.',
              'cnpj': '33592510000154',
              'active': true,
            }),
            201,
          );
        } else if (request.method == 'PUT' && request.url.path == '/api/companies/2') {
          return http.Response(
            jsonEncode({
              'id': 2,
              'legalName': 'Vale S.A. Atualizada',
              'cnpj': '33592510000154',
              'active': false,
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient, baseUrl: 'http://api.local');
      final dataSource = CompanyRemoteDataSource(apiClient);
      final repository = CompanyRepositoryImpl(dataSource);

      final company = await repository.getCompanyById(1);
      expect(company.legalName, 'Petrobras S.A.');

      final created = await repository.createCompany(
        const CreateCompanyRequest(
          legalName: 'Vale S.A.',
          cnpj: '33592510000154',
        ),
      );
      expect(created.id, 2);
      expect(created.legalName, 'Vale S.A.');

      final updated = await repository.updateCompany(
        2,
        const UpdateCompanyRequest(
          legalName: 'Vale S.A. Atualizada',
          cnpj: '33592510000154',
          active: false,
        ),
      );
      expect(updated.active, isFalse);
    });
  });
}

