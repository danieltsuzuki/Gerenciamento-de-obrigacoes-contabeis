import 'package:flutter/material.dart';
import '../../features/attachment/data/datasources/attachment_remote_datasource.dart';
import '../../features/attachment/data/repositories/attachment_repository_impl.dart';
import '../../features/attachment/domain/repositories/attachment_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_session_storage.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_session_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/company/data/datasources/company_remote_datasource.dart';
import '../../features/company/data/repositories/company_repository_impl.dart';
import '../../features/company/domain/entities/company.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/presentation/pages/company_detail_page.dart';
import '../../features/company/presentation/pages/company_form_page.dart';
import '../../features/company/presentation/pages/company_list_page.dart';
import '../../features/obligation/data/datasources/obligation_remote_datasource.dart';
import '../../features/obligation/data/repositories/obligation_repository_impl.dart';
import '../../features/obligation/domain/entities/obligation.dart';
import '../../features/obligation/domain/repositories/obligation_repository.dart';
import '../../features/obligation/presentation/pages/obligation_detail_page.dart';
import '../../features/obligation/presentation/pages/obligation_form_page.dart';
import '../../features/obligation/presentation/pages/obligation_list_page.dart';
import '../../features/responsible/data/datasources/responsible_remote_datasource.dart';
import '../../features/responsible/data/repositories/responsible_repository_impl.dart';
import '../../features/responsible/domain/entities/responsible.dart';
import '../../features/responsible/domain/repositories/responsible_repository.dart';
import '../../features/responsible/presentation/pages/responsible_detail_page.dart';
import '../../features/responsible/presentation/pages/responsible_form_page.dart';
import '../../features/responsible/presentation/pages/responsible_list_page.dart';
import '../network/api_client.dart';

class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String obligations = '/obligations';
  static const String obligationDetails = '/obligations/details';
  static const String obligationCreate = '/obligations/create';
  static const String obligationEdit = '/obligations/edit';
  static const String companies = '/companies';
  static const String companyDetails = '/companies/details';
  static const String companyCreate = '/companies/create';
  static const String companyEdit = '/companies/edit';
  static const String responsibles = '/responsibles';
  static const String responsibleDetails = '/responsibles/details';
  static const String responsibleCreate = '/responsibles/create';
  static const String responsibleEdit = '/responsibles/edit';
  static const String login = '/login';
  static const String register = '/register';

  static AuthRepository createAuthRepository(ApiClient apiClient) {
    return AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient),
      apiClient: apiClient,
    );
  }

  static AuthSessionController createAuthSessionController(
    ApiClient apiClient, {
    AuthRepository? repository,
    AuthSessionStorage? storage,
  }) {
    final effectiveRepo = repository ?? createAuthRepository(apiClient);
    final effectiveStorage = storage ?? SecureAuthSessionStorage();
    return AuthSessionController(
      authRepository: effectiveRepo,
      sessionStorage: effectiveStorage,
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
    AuthSessionController? authController,
    AuthRepository? authRepository,
    CompanyRepository? companyRepository,
    ResponsibleRepository? responsibleRepository,
    ObligationRepository? obligationRepository,
    AttachmentRepository? attachmentRepository,
  }) {
    final effectiveAuthRepo = authRepository ?? createAuthRepository(apiClient);
    final effectiveAuthController = authController ??
        createAuthSessionController(
          apiClient,
          repository: effectiveAuthRepo,
        );
    final effectiveCompanyRepo = companyRepository ??
        CompanyRepositoryImpl(CompanyRemoteDataSource(apiClient));
    final effectiveResponsibleRepo = responsibleRepository ??
        ResponsibleRepositoryImpl(ResponsibleRemoteDataSource(apiClient));
    final effectiveObligationRepo = obligationRepository ??
        ObligationRepositoryImpl(ObligationRemoteDataSource(apiClient));
    final effectiveAttachmentRepo = attachmentRepository ??
        createAttachmentRepository(apiClient);

    switch (settings.name) {
      case initial:
      case obligations:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ObligationListPage(
            repository: effectiveObligationRepo,
            companyRepository: effectiveCompanyRepo,
            responsibleRepository: effectiveResponsibleRepo,
            authController: effectiveAuthController,
          ),
        );
      case companies:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompanyListPage(
            repository: effectiveCompanyRepo,
            authController: effectiveAuthController,
          ),
        );
      case companyDetails:
        final company = settings.arguments is Company
            ? settings.arguments as Company
            : null;
        final id = settings.arguments is int
            ? settings.arguments as int
            : (company?.id ?? 0);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CompanyDetailPage(
            repository: effectiveCompanyRepo,
            companyId: id,
            initialCompany: company,
            authController: effectiveAuthController,
          ),
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
          builder: (_) => ResponsibleListPage(
            repository: effectiveResponsibleRepo,
            authController: effectiveAuthController,
          ),
        );
      case responsibleDetails:
        final responsible = settings.arguments is Responsible
            ? settings.arguments as Responsible
            : null;
        final id = settings.arguments is int
            ? settings.arguments as int
            : (responsible?.id ?? 0);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResponsibleDetailPage(
            repository: effectiveResponsibleRepo,
            responsibleId: id,
            initialResponsible: responsible,
            authController: effectiveAuthController,
          ),
        );
      case responsibleCreate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResponsibleFormPage(repository: effectiveResponsibleRepo),
        );
      case responsibleEdit:
        final responsible = settings.arguments is Responsible
            ? settings.arguments as Responsible
            : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResponsibleFormPage(
            repository: effectiveResponsibleRepo,
            responsible: responsible,
          ),
        );
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LoginPage(controller: effectiveAuthController),
        );
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RegisterPage(controller: effectiveAuthController),
        );
      case obligationDetails:
        final obligation = settings.arguments is Obligation
            ? settings.arguments as Obligation
            : null;
        final obligationId = settings.arguments is int
            ? settings.arguments as int
            : (obligation?.id ?? 0);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ObligationDetailPage(
            repository: effectiveObligationRepo,
            attachmentRepository: effectiveAttachmentRepo,
            companyRepository: effectiveCompanyRepo,
            responsibleRepository: effectiveResponsibleRepo,
            obligationId: obligationId,
            initialObligation: obligation,
            authController: effectiveAuthController,
          ),
        );
      case obligationCreate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ObligationFormPage(
            obligationRepository: effectiveObligationRepo,
            companyRepository: effectiveCompanyRepo,
            responsibleRepository: effectiveResponsibleRepo,
          ),
        );
      case obligationEdit:
        final obligation = settings.arguments is Obligation
            ? settings.arguments as Obligation
            : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ObligationFormPage(
            obligationRepository: effectiveObligationRepo,
            companyRepository: effectiveCompanyRepo,
            responsibleRepository: effectiveResponsibleRepo,
            obligation: obligation,
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
