import '../../../../core/network/page_response.dart';
import '../../data/models/create_obligation_request.dart';
import '../../data/models/update_obligation_request.dart';
import '../entities/obligation.dart';

abstract class ObligationRepository {
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
  });

  Future<Obligation> getObligationById(int id);

  Future<Obligation> createObligation(CreateObligationRequest request);

  Future<Obligation> updateObligation(int id, UpdateObligationRequest request);

  Future<Obligation> updateObligationStatus(int id, ObligationStatus newStatus);
}
