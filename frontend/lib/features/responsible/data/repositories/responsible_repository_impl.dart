import '../../domain/entities/responsible.dart';
import '../../domain/repositories/responsible_repository.dart';
import '../datasources/responsible_remote_datasource.dart';

class ResponsibleRepositoryImpl implements ResponsibleRepository {
  final ResponsibleRemoteDataSource _remoteDataSource;

  ResponsibleRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Responsible>> getResponsibles({bool? active, int page = 0, int size = 20}) {
    return _remoteDataSource.getResponsibles(active: active, page: page, size: size);
  }

  @override
  Future<Responsible> getResponsibleById(int id) {
    return _remoteDataSource.getResponsibleById(id);
  }

  @override
  Future<Responsible> createResponsible({
    required String name,
    required String email,
    required String password,
    bool active = true,
  }) {
    return _remoteDataSource.createResponsible({
      'name': name,
      'email': email,
      'password': password,
      'active': active,
    });
  }

  @override
  Future<Responsible> updateResponsible({
    required int id,
    required String name,
    required String email,
    required bool active,
  }) {
    return _remoteDataSource.updateResponsible(id, {
      'name': name,
      'email': email,
      'active': active,
    });
  }
}
