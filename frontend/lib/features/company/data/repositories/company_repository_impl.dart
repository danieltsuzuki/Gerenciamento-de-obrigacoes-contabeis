import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource _remoteDataSource;

  CompanyRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Company>> getCompanies({bool? active, int page = 0, int size = 20}) {
    return _remoteDataSource.getCompanies(active: active, page: page, size: size);
  }

  @override
  Future<Company> getCompanyById(int id) {
    return _remoteDataSource.getCompanyById(id);
  }

  @override
  Future<Company> createCompany({
    required String legalName,
    String? tradeName,
    required String cnpj,
    bool active = true,
  }) {
    return _remoteDataSource.createCompany({
      'legalName': legalName,
      if (tradeName != null && tradeName.isNotEmpty) 'tradeName': tradeName,
      'cnpj': cnpj,
      'active': active,
    });
  }

  @override
  Future<Company> updateCompany({
    required int id,
    required String legalName,
    String? tradeName,
    required String cnpj,
    required bool active,
  }) {
    return _remoteDataSource.updateCompany(id, {
      'legalName': legalName,
      if (tradeName != null && tradeName.isNotEmpty) 'tradeName': tradeName,
      'cnpj': cnpj,
      'active': active,
    });
  }
}
