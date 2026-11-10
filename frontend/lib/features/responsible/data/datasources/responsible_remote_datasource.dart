import '../../../../core/network/api_client.dart';
import '../../domain/entities/responsible.dart';

class ResponsibleRemoteDataSource {
  final ApiClient _apiClient;

  ResponsibleRemoteDataSource(this._apiClient);

  Future<List<Responsible>> getResponsibles({bool? active, int page = 0, int size = 20}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (active != null) {
      queryParams['active'] = active;
    }

    final response = await _apiClient.get(
      '/api/responsibles',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['content'] is List) {
      final list = response['content'] as List;
      return list.map((item) => Responsible.fromJson(item as Map<String, dynamic>)).toList();
    } else if (response is List) {
      return response.map((item) => Responsible.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Responsible> getResponsibleById(int id) async {
    final response = await _apiClient.get('/api/responsibles/$id');
    return Responsible.fromJson(response as Map<String, dynamic>);
  }

  Future<Responsible> createResponsible(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/api/responsibles', body: payload);
    return Responsible.fromJson(response as Map<String, dynamic>);
  }

  Future<Responsible> updateResponsible(int id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put('/api/responsibles/$id', body: payload);
    return Responsible.fromJson(response as Map<String, dynamic>);
  }
}
