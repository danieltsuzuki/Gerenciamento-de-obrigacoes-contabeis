import '../../../../core/network/page_response.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';
import '../datasources/obligation_remote_datasource.dart';
import '../models/create_obligation_request.dart';
import '../models/update_obligation_request.dart';

class ObligationRepositoryImpl implements ObligationRepository {
  final ObligationRemoteDataSource _remoteDataSource;

  ObligationRepositoryImpl(this._remoteDataSource);

  @override
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
  }) {
    return _remoteDataSource.getObligations(
      companyId: companyId,
      responsibleId: responsibleId,
      status: status,
      dueFrom: dueFrom,
      dueTo: dueTo,
      q: q,
      page: page,
      size: size,
      sort: sort,
    );
  }

  @override
  Future<Obligation> getObligationById(int id) {
    return _remoteDataSource.getObligationById(id);
  }

  @override
  Future<Obligation> createObligation(CreateObligationRequest request) {
    return _remoteDataSource.createObligation(request);
  }

  @override
  Future<Obligation> updateObligation(int id, UpdateObligationRequest request) {
    return _remoteDataSource.updateObligation(id, request);
  }

  @override
  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus) {
    return _remoteDataSource.updateObligationStatus(id, newStatus);
  }
}
