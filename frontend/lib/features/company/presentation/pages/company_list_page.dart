import 'dart:async';
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
import 'company_detail_page.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  final int _pageSize = 10;

  bool get _isAuthenticated => widget.authController?.isAuthenticated ?? false;

  @override
  void initState() {
    super.initState();
    widget.authController?.addListener(_onAuthChanged);
    _loadCompanies();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.authController?.removeListener(_onAuthChanged);
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final query = _searchController.text.trim();

    try {
      final result = await widget.repository.getCompanies(
        active: _selectedActiveFilter,
        page: page,
        size: _pageSize,
        q: query.isNotEmpty ? query : null,
      );
      if (!mounted) return;
      setState(() {
        _companies = result.content;
        _currentPage = result.number;
        _totalPages = result.totalPages;
        _totalElements = result.totalElements;
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

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _loadCompanies(page: 0);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _loadCompanies(page: 0);
  }

  void _onActiveFilterSelected(bool? active) {
    if (_selectedActiveFilter == active) return;
    setState(() {
      _selectedActiveFilter = active;
    });
    _loadCompanies(page: 0);
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
      _loadCompanies(page: 0);
    }
  }

  Future<void> _openDetails(Company company) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CompanyDetailPage(
          repository: widget.repository,
          companyId: company.id,
          initialCompany: company,
          authController: widget.authController,
        ),
      ),
    );
    if (changed == true && mounted) {
      _loadCompanies(page: _currentPage);
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
      _loadCompanies(page: _currentPage);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        key: const Key('company-search-field'),
        controller: _searchController,
        onChanged: _onSearchChanged,
        onSubmitted: (_) => _loadCompanies(page: 0),
        decoration: InputDecoration(
          hintText: 'Pesquisar por razão, fantasia ou CNPJ...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  key: const Key('company-search-clear'),
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildPaginationBar() {
    if (_totalElements == 0) return const SizedBox.shrink();

    final hasPrevious = _currentPage > 0;
    final hasNext = _currentPage < _totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton.outlined(
            key: const Key('company-pagination-prev'),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
            onPressed: hasPrevious && !_isLoading
                ? () => _loadCompanies(page: _currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            key: const Key('company-pagination-next'),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
            onPressed: hasNext && !_isLoading
                ? () => _loadCompanies(page: _currentPage + 1)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Página ${_currentPage + 1} de ${_totalPages > 0 ? _totalPages : 1} ($_totalElements)',
            key: const Key('company-pagination-info'),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
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
        onRetry: () => _loadCompanies(page: _currentPage),
      );
    }

    final query = _searchController.text.trim();

    if (_companies.isEmpty) {
      if (query.isNotEmpty) {
        return EmptyStateView(
          icon: Icons.search_off_outlined,
          title: "Nenhum resultado para '$query'",
          message: 'Nenhuma empresa corresponde aos termos pesquisados.',
          actionLabel: 'Limpar pesquisa',
          onAction: _clearSearch,
        );
      }

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
      onRefresh: () => _loadCompanies(page: _currentPage),
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
              onTap: () => _openDetails(company),
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
                  if (_isAuthenticated)
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
          onPressed: () => _loadCompanies(page: _currentPage),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(height: 1),
          Expanded(child: _buildListContent()),
          _buildPaginationBar(),
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
