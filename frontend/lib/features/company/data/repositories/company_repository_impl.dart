import '../../../../core/network/page_response.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';
import '../models/create_company_request.dart';
import '../models/update_company_request.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource _remoteDataSource;

  CompanyRepositoryImpl(this._remoteDataSource);

  @override
  Future<PageResponse<Company>> getCompanies({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
  }) {
    return _remoteDataSource.getCompanies(
      active: active,
      page: page,
      size: size,
      sort: sort,
    );
  }

  @override
  Future<Company> getCompanyById(int id) {
    return _remoteDataSource.getCompanyById(id);
  }

  @override
  Future<Company> createCompany(CreateCompanyRequest request) {
    return _remoteDataSource.createCompany(request);
  }

  @override
  Future<Company> updateCompany(int id, UpdateCompanyRequest request) {
    return _remoteDataSource.updateCompany(id, request);
  }
}
