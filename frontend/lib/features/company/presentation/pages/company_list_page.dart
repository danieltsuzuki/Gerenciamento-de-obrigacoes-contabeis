import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/cnpj_validator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import 'company_form_page.dart';

class CompanyListPage extends StatefulWidget {
  final CompanyRepository repository;
  final AuthSessionController? authController;

  const CompanyListPage({
    super.key,
    required this.repository,
    this.authController,
  });

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Company> _companies = [];
  bool? _selectedActiveFilter;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.getCompanies(
        active: _selectedActiveFilter,
      );
      if (!mounted) return;
      setState(() {
        _companies = result.content;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onActiveFilterSelected(bool? active) {
    if (_selectedActiveFilter == active) return;
    setState(() {
      _selectedActiveFilter = active;
    });
    _loadCompanies();
  }

  Future<void> _openCreateForm() async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para cadastrar uma nova empresa, realize o login.',
      );
      if (!allowed || !mounted) return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CompanyFormPage(repository: widget.repository),
      ),
    );
    if (created == true && mounted) {
      _loadCompanies();
    }
  }

  Future<void> _openEditForm(Company company) async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para editar os dados da empresa, realize o login.',
      );
      if (!allowed || !mounted) return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CompanyFormPage(
          repository: widget.repository,
          company: company,
        ),
      ),
    );
    if (updated == true && mounted) {
      _loadCompanies();
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ChoiceChip(
            key: const Key('company-filter-all'),
            label: const Text('Todas'),
            selected: _selectedActiveFilter == null,
            onSelected: (_) => _onActiveFilterSelected(null),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('company-filter-active'),
            label: const Text('Ativas'),
            selected: _selectedActiveFilter == true,
            onSelected: (_) => _onActiveFilterSelected(true),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('company-filter-inactive'),
            label: const Text('Inativas'),
            selected: _selectedActiveFilter == false,
            onSelected: (_) => _onActiveFilterSelected(false),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const LoadingStateView(message: 'Carregando empresas cadastradas...');
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadCompanies,
      );
    }

    if (_companies.isEmpty) {
      return EmptyStateView(
        icon: Icons.business_outlined,
        title: 'Nenhuma empresa encontrada',
        message: _selectedActiveFilter != null
            ? 'Não há empresas com o filtro selecionado.'
            : 'Cadastre sua primeira empresa para gerenciar suas obrigações fiscais.',
        actionLabel: 'Nova Empresa',
        onAction: _openCreateForm,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCompanies,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _companies.length,
        itemBuilder: (context, index) {
          final company = _companies[index];
          final formattedCnpj = CnpjValidator.format(company.cnpj);

          return Card(
            key: Key('company-card-${company.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => _openEditForm(company),
              leading: CircleAvatar(
                backgroundColor: company.active
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFFF1F5F9),
                child: Icon(
                  Icons.business,
                  color: company.active
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF94A3B8),
                ),
              ),
              title: Text(
                company.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (company.tradeName != null &&
                      company.tradeName!.isNotEmpty &&
                      company.tradeName != company.legalName)
                    Text(
                      company.legalName,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  const SizedBox(height: 2),
                  Text('CNPJ: $formattedCnpj'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      company.active ? 'Ativa' : 'Inativa',
                      style: TextStyle(
                        color: company.active
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: company.active
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                  ),
                  IconButton(
                    key: Key('company-edit-button-${company.id}'),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Editar empresa',
                    onPressed: () => _openEditForm(company),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Empresas',
      currentNavIndex: 1,
      authController: widget.authController,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
          onPressed: _loadCompanies,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterChips(),
          const Divider(height: 1),
          Expanded(child: _buildListContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new-company-fab'),
        onPressed: _openCreateForm,
        icon: const Icon(Icons.add),
        label: const Text('Nova Empresa'),
      ),
    );
  }
}
