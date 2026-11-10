import '../../../../core/network/page_response.dart';
import '../../data/models/create_responsible_request.dart';
import '../../data/models/update_responsible_request.dart';
import '../entities/responsible.dart';

abstract class ResponsibleRepository {
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  });

  Future<Responsible> getResponsibleById(int id);

  Future<Responsible> createResponsible(CreateResponsibleRequest request);

  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request);
}
