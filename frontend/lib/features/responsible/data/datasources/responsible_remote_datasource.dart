import '../../../../core/network/api_client.dart';
import '../../../../core/network/page_response.dart';
import '../../domain/entities/responsible.dart';
import '../models/create_responsible_request.dart';
import '../models/update_responsible_request.dart';

class ResponsibleRemoteDataSource {
  final ApiClient _apiClient;

  ResponsibleRemoteDataSource(this._apiClient);

  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    String? q,
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
    if (q != null && q.trim().isNotEmpty) {
      queryParams['q'] = q.trim();
    }

    final response = await _apiClient.get(
      '/api/responsibles',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      return PageResponse<Responsible>.fromJson(response, Responsible.fromJson);
    } else if (response is List) {
      final items = response
          .whereType<Map<String, dynamic>>()
          .map(Responsible.fromJson)
          .toList();
      return PageResponse<Responsible>(
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
    return const PageResponse<Responsible>(
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

  Future<Responsible> getResponsibleById(int id) async {
    final response = await _apiClient.get('/api/responsibles/$id');
    return Responsible.fromJson(response as Map<String, dynamic>);
  }

  Future<Responsible> createResponsible(CreateResponsibleRequest request) async {
    final response = await _apiClient.post(
      '/api/responsibles',
      body: request.toJson(),
    );
    return Responsible.fromJson(response as Map<String, dynamic>);
  }

  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async {
    final response = await _apiClient.put(
      '/api/responsibles/$id',
      body: request.toJson(),
    );
    return Responsible.fromJson(response as Map<String, dynamic>);
  }
}
