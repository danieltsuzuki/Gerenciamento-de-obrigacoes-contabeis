import '../../../../core/network/api_client.dart';
import '../../domain/entities/obligation.dart';

class ObligationRemoteDataSource {
  final ApiClient _apiClient;

  ObligationRemoteDataSource(this._apiClient);

  Future<List<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    DateTime? dueFrom,
    DateTime? dueTo,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (companyId != null) queryParams['companyId'] = companyId;
    if (responsibleId != null) queryParams['responsibleId'] = responsibleId;
    if (status != null) queryParams['status'] = status.code;
    if (dueFrom != null) {
      queryParams['dueFrom'] = dueFrom.toIso8601String().split('T').first;
    }
    if (dueTo != null) {
      queryParams['dueTo'] = dueTo.toIso8601String().split('T').first;
    }

    final response = await _apiClient.get(
      '/api/obligations',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['content'] is List) {
      final list = response['content'] as List;
      return list.map((item) => Obligation.fromJson(item as Map<String, dynamic>)).toList();
    } else if (response is List) {
      return response.map((item) => Obligation.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Obligation> getObligationById(int id) async {
    final response = await _apiClient.get('/api/obligations/$id');
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<Obligation> createObligation(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/api/obligations', body: payload);
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<Obligation> updateStatus(int id, ObligationStatus newStatus) async {
    final response = await _apiClient.patch(
      '/api/obligations/$id/status',
      body: {'status': newStatus.code},
    );
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<Obligation> updateObligation(int id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put('/api/obligations/$id', body: payload);
    return Obligation.fromJson(response as Map<String, dynamic>);
  }
}
