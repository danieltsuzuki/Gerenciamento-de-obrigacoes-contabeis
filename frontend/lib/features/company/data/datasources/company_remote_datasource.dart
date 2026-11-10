import '../../../../core/network/api_client.dart';
import '../../../../core/network/page_response.dart';
import '../../domain/entities/company.dart';
import '../models/create_company_request.dart';
import '../models/update_company_request.dart';

class CompanyRemoteDataSource {
  final ApiClient _apiClient;

  CompanyRemoteDataSource(this._apiClient);

  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
    };
    if (active != null) {
      queryParams['active'] = active;
    }

    final response = await _apiClient.get(
      '/api/companies',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      return PageResponse<Company>.fromJson(response, Company.fromJson);
    } else if (response is List) {
      final items = response
          .whereType<Map<String, dynamic>>()
          .map(Company.fromJson)
          .toList();
      return PageResponse<Company>(
        content: items,
        totalElements: items.length,
        totalPages: 1,
        size: items.length,
        number: 0,
        first: true,
        last: true,
        empty: items.isEmpty,
      );
    }
    return const PageResponse<Company>(
      content: [],
      totalElements: 0,
      totalPages: 0,
      size: 0,
      number: 0,
      first: true,
      last: true,
      empty: true,
    );
  }

  Future<Company> getCompanyById(int id) async {
    final response = await _apiClient.get('/api/companies/$id');
    return Company.fromJson(response as Map<String, dynamic>);
  }

  Future<Company> createCompany(CreateCompanyRequest request) async {
    final response = await _apiClient.post(
      '/api/companies',
      body: request.toJson(),
    );
    return Company.fromJson(response as Map<String, dynamic>);
  }

  Future<Company> updateCompany(int id, UpdateCompanyRequest request) async {
    final response = await _apiClient.put(
      '/api/companies/$id',
      body: request.toJson(),
    );
    return Company.fromJson(response as Map<String, dynamic>);
  }
}
