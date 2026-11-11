import '../../../../core/network/page_response.dart';
import '../../domain/entities/responsible.dart';
import '../../domain/repositories/responsible_repository.dart';
import '../datasources/responsible_remote_datasource.dart';
import '../models/create_responsible_request.dart';
import '../models/update_responsible_request.dart';

class ResponsibleRepositoryImpl implements ResponsibleRepository {
  final ResponsibleRemoteDataSource _remoteDataSource;

  ResponsibleRepositoryImpl(this._remoteDataSource);

  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    String? q,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) {
    return _remoteDataSource.getResponsibles(
      active: active,
      q: q,
      page: page,
      size: size,
      sort: sort,
    );
  }

  @override
  Future<Responsible> getResponsibleById(int id) {
    return _remoteDataSource.getResponsibleById(id);
  }

  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) {
    return _remoteDataSource.createResponsible(request);
  }

  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) {
    return _remoteDataSource.updateResponsible(id, request);
  }
}
