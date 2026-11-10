import '../entities/responsible.dart';

abstract class ResponsibleRepository {
  Future<List<Responsible>> getResponsibles({bool? active, int page = 0, int size = 20});
  Future<Responsible> getResponsibleById(int id);
  Future<Responsible> createResponsible({
    required String name,
    required String email,
    required String password,
    bool active = true,
  });
  Future<Responsible> updateResponsible({
    required int id,
    required String name,
    required String email,
    required bool active,
  });
}
