import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';
import '../datasources/obligation_remote_datasource.dart';

class ObligationRepositoryImpl implements ObligationRepository {
  final ObligationRemoteDataSource _remoteDataSource;

  ObligationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    DateTime? dueFrom,
    DateTime? dueTo,
    int page = 0,
    int size = 20,
  }) {
    return _remoteDataSource.getObligations(
      companyId: companyId,
      responsibleId: responsibleId,
      status: status,
      dueFrom: dueFrom,
      dueTo: dueTo,
      page: page,
      size: size,
    );
  }

  @override
  Future<Obligation> getObligationById(int id) {
    return _remoteDataSource.getObligationById(id);
  }

  @override
  Future<Obligation> createObligation({
    required int companyId,
    required int responsibleId,
    required String title,
    String? description,
    required DateTime dueDate,
  }) {
    return _remoteDataSource.createObligation({
      'companyId': companyId,
      'responsibleId': responsibleId,
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'dueDate': dueDate.toIso8601String().split('T').first,
    });
  }

  @override
  Future<Obligation> updateStatus(int id, ObligationStatus newStatus) {
    return _remoteDataSource.updateStatus(id, newStatus);
  }

  @override
  Future<Obligation> updateObligation({
    required int id,
    required int companyId,
    required int responsibleId,
    required String title,
    String? description,
    required DateTime dueDate,
  }) {
    return _remoteDataSource.updateObligation(id, {
      'companyId': companyId,
      'responsibleId': responsibleId,
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'dueDate': dueDate.toIso8601String().split('T').first,
    });
  }
}
