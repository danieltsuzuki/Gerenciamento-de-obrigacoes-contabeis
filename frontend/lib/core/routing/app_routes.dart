import 'package:flutter/material.dart';
import '../../features/company/data/datasources/company_remote_datasource.dart';
import '../../features/company/data/repositories/company_repository_impl.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/presentation/pages/company_list_page.dart';
import '../../features/obligation/data/datasources/obligation_remote_datasource.dart';
import '../../features/obligation/data/repositories/obligation_repository_impl.dart';
import '../../features/obligation/domain/repositories/obligation_repository.dart';
import '../../features/obligation/presentation/pages/obligation_list_page.dart';
import '../../features/responsible/data/datasources/responsible_remote_datasource.dart';
import '../../features/responsible/data/repositories/responsible_repository_impl.dart';
import '../../features/responsible/domain/repositories/responsible_repository.dart';
import '../../features/responsible/presentation/pages/responsible_list_page.dart';
import '../network/api_client.dart';

class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String obligations = '/obligations';
  static const String companies = '/companies';
  static const String responsibles = '/responsibles';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required ApiClient apiClient,
    CompanyRepository? companyRepository,
    ResponsibleRepository? responsibleRepository,
    ObligationRepository? obligationRepository,
  }) {
    final effectiveCompanyRepo = companyRepository ??
        CompanyRepositoryImpl(CompanyRemoteDataSource(apiClient));
    final effectiveResponsibleRepo = responsibleRepository ??
        ResponsibleRepositoryImpl(ResponsibleRemoteDataSource(apiClient));
    final effectiveObligationRepo = obligationRepository ??
        ObligationRepositoryImpl(ObligationRemoteDataSource(apiClient));

    switch (settings.name) {
      case initial:
      case obligations:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ObligationListPage(repository: effectiveObligationRepo),
        );
      case companies:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompanyListPage(repository: effectiveCompanyRepo),
        );
      case responsibles:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResponsibleListPage(repository: effectiveResponsibleRepo),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Página não encontrada')),
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
