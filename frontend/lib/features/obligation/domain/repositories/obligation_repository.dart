import '../entities/obligation.dart';

abstract class ObligationRepository {
  Future<List<Obligation>> getObligations({
    int? companyId,
    int? responsibleId,
    ObligationStatus? status,
    DateTime? dueFrom,
    DateTime? dueTo,
    int page = 0,
    int size = 20,
  });

  Future<Obligation> getObligationById(int id);

  Future<Obligation> createObligation({
    required int companyId,
    required int responsibleId,
    required String title,
    String? description,
    required DateTime dueDate,
  });

  Future<Obligation> updateStatus(int id, ObligationStatus newStatus);

  Future<Obligation> updateObligation({
    required int id,
    required int companyId,
    required int responsibleId,
    required String title,
    String? description,
    required DateTime dueDate,
  });
}
