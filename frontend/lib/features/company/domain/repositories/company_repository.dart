import '../../../../core/network/page_response.dart';
import '../../data/models/create_company_request.dart';
import '../../data/models/update_company_request.dart';
import '../entities/company.dart';

abstract class CompanyRepository {
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  });

  Future<Company> getCompanyById(int id);

  Future<Company> createCompany(CreateCompanyRequest request);

  Future<Company> updateCompany(int id, UpdateCompanyRequest request);
}
