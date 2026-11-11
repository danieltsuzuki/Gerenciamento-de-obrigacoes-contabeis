import '../../../../core/network/api_client.dart';
import '../../../../core/network/page_response.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/entities/obligation_status_history.dart';
import '../models/create_obligation_request.dart';
import '../models/update_obligation_request.dart';
import '../models/update_obligation_status_request.dart';

class ObligationRemoteDataSource {
  final ApiClient _apiClient;

  ObligationRemoteDataSource(this._apiClient);

  Future<PageResponse<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    String? dueFrom,
    String? dueTo,
    String? q,
    int page = 0,
    int size = 20,
    String sort = 'dueDate,asc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
    };
    if (companyId != null) queryParams['companyId'] = companyId;
    if (responsibleId != null) queryParams['responsibleId'] = responsibleId;
    if (status != null) queryParams['status'] = status.code;
    if (dueFrom != null && dueFrom.isNotEmpty) queryParams['dueFrom'] = dueFrom;
    if (dueTo != null && dueTo.isNotEmpty) queryParams['dueTo'] = dueTo;
    if (q != null && q.trim().isNotEmpty) queryParams['q'] = q.trim();

    final response = await _apiClient.get(
      '/api/obligations',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      return PageResponse<Obligation>.fromJson(response, Obligation.fromJson);
    } else if (response is List) {
      final items = response
          .whereType<Map<String, dynamic>>()
          .map(Obligation.fromJson)
          .toList();
      return PageResponse<Obligation>(
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
    return const PageResponse<Obligation>(
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

  Future<Obligation> getObligationById(int id) async {
    final response = await _apiClient.get('/api/obligations/$id');
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<Obligation> createObligation(CreateObligationRequest request) async {
    final response = await _apiClient.post(
      '/api/obligations',
      body: request.toJson(),
    );
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<Obligation> updateObligation(int id, UpdateObligationRequest request) async {
    final response = await _apiClient.put(
      '/api/obligations/$id',
      body: request.toJson(),
    );
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) async {
    final request = UpdateObligationStatusRequest(newStatus);
    final response = await _apiClient.patch(
      '/api/obligations/$id/status',
      body: request.toJson(),
    );
    return Obligation.fromJson(response as Map<String, dynamic>);
  }

  Future<List<ObligationStatusHistory>> getObligationHistory(int id) async {
    final response = await _apiClient.get('/api/obligations/$id/history');
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(ObligationStatusHistory.fromJson)
          .toList();
    }
    return [];
  }
}
