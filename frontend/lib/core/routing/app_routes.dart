import 'package:flutter/material.dart';
import '../../features/attachment/data/datasources/attachment_remote_datasource.dart';
import '../../features/attachment/data/repositories/attachment_repository_impl.dart';
import '../../features/attachment/domain/repositories/attachment_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/company/data/datasources/company_remote_datasource.dart';
import '../../features/company/data/repositories/company_repository_impl.dart';
import '../../features/company/domain/entities/company.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/presentation/pages/company_form_page.dart';
import '../../features/company/presentation/pages/company_list_page.dart';
import '../../features/obligation/data/datasources/obligation_remote_datasource.dart';
import '../../features/obligation/data/repositories/obligation_repository_impl.dart';
import '../../features/obligation/domain/entities/obligation.dart';
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
  static const String obligationDetails = '/obligations/details';
  static const String companies = '/companies';
  static const String companyCreate = '/companies/create';
  static const String companyEdit = '/companies/edit';
  static const String responsibles = '/responsibles';

  static AuthRepository createAuthRepository(ApiClient apiClient) {
    return AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient),
      apiClient: apiClient,
    );
  }

  static AttachmentRepository createAttachmentRepository(ApiClient apiClient) {
    return AttachmentRepositoryImpl(
      AttachmentRemoteDataSourceImpl(apiClient),
    );
  }

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
      case companyCreate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompanyFormPage(repository: effectiveCompanyRepo),
        );
      case companyEdit:
        final company = settings.arguments is Company
            ? settings.arguments as Company
            : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompanyFormPage(
            repository: effectiveCompanyRepo,
            company: company,
          ),
        );
      case responsibles:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResponsibleListPage(repository: effectiveResponsibleRepo),
        );
      case obligationDetails:
        final obligation = settings.arguments is Obligation
            ? settings.arguments as Obligation
            : null;
        final obligationId = settings.arguments is int
            ? settings.arguments as int
            : obligation?.id;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(obligation?.title ?? 'Detalhes da Obrigação'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identificador: #${obligationId ?? "—"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (obligation != null) ...[
                    const SizedBox(height: 8),
                    Text('Status: ${obligation.status.label}'),
                    Text('Empresa: ${obligation.company.name}'),
                    Text('Responsável: ${obligation.responsible.name}'),
                    Text('Anexos: ${obligation.attachmentCount}'),
                  ],
                ],
              ),
            ),
          ),
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
