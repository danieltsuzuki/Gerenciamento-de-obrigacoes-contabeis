import '../entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> getCompanies({bool? active, int page = 0, int size = 20});
  Future<Company> getCompanyById(int id);
  Future<Company> createCompany({
    required String legalName,
    String? tradeName,
    required String cnpj,
    bool active = true,
  });
  Future<Company> updateCompany({
    required int id,
    required String legalName,
    String? tradeName,
    required String cnpj,
    required bool active,
  });
}
