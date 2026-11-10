import '../../../../core/network/api_client.dart';
import '../../domain/entities/company.dart';

class CompanyRemoteDataSource {
  final ApiClient _apiClient;

  CompanyRemoteDataSource(this._apiClient);

  Future<List<Company>> getCompanies({bool? active, int page = 0, int size = 20}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (active != null) {
      queryParams['active'] = active;
    }

    final response = await _apiClient.get(
      '/api/companies',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['content'] is List) {
      final list = response['content'] as List;
      return list.map((item) => Company.fromJson(item as Map<String, dynamic>)).toList();
    } else if (response is List) {
      return response.map((item) => Company.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Company> getCompanyById(int id) async {
    final response = await _apiClient.get('/api/companies/$id');
    return Company.fromJson(response as Map<String, dynamic>);
  }

  Future<Company> createCompany(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/api/companies', body: payload);
    return Company.fromJson(response as Map<String, dynamic>);
  }

  Future<Company> updateCompany(int id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put('/api/companies/$id', body: payload);
    return Company.fromJson(response as Map<String, dynamic>);
  }
}
