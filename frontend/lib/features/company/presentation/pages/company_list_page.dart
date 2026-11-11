import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
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
  final ThemeController? themeController;

  const CompanyListPage({
    super.key,
    required this.repository,
    this.authController,
    this.themeController,
  });

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Company> _companies = [];
  bool? _selectedActiveFilter;
  String _selectedSort = 'id,asc';
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
        sort: _selectedSort,
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

  void _clearAllFilters() {
    setState(() {
      _selectedActiveFilter = null;
      _selectedSort = 'id,asc';
      _searchController.clear();
    });
    _loadCompanies(page: 0);
  }

  bool get _hasActiveFilters =>
      _selectedActiveFilter != null ||
      _selectedSort != 'id,asc' ||
      _searchController.text.trim().isNotEmpty;

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'legalName,asc':
        return 'Razão Social (A-Z)';
      case 'legalName,desc':
        return 'Razão Social (Z-A)';
      case 'cnpj,asc':
        return 'CNPJ';
      case 'id,desc':
        return 'Mais recentes';
      case 'id,asc':
      default:
        return 'Mais antigas';
    }
  }

  Future<void> _openAdvancedFiltersModal() async {
    bool? tempActive = _selectedActiveFilter;
    String tempSort = _selectedSort;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              alignment: Alignment.center,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.tune, color: AppTheme.brandYellow),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Filtros de Empresas',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Situação Cadastral',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            key: const Key('company-filter-active-chip-all'),
                            label: const Text('Todas'),
                            selected: tempActive == null,
                            onSelected: (_) => setModalState(() => tempActive = null),
                          ),
                          ChoiceChip(
                            key: const Key('company-filter-active-chip-true'),
                            label: const Text('Ativas'),
                            selected: tempActive == true,
                            onSelected: (_) => setModalState(() => tempActive = true),
                          ),
                          ChoiceChip(
                            key: const Key('company-filter-active-chip-false'),
                            label: const Text('Inativas'),
                            selected: tempActive == false,
                            onSelected: (_) => setModalState(() => tempActive = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ordenação dos Resultados',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: const Key('company-filter-sort-dropdown'),
                        value: tempSort,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'id,asc', child: Text('Mais antigas primeiro')),
                          DropdownMenuItem(value: 'id,desc', child: Text('Mais recentes primeiro')),
                          DropdownMenuItem(value: 'legalName,asc', child: Text('Razão Social (A-Z)')),
                          DropdownMenuItem(value: 'legalName,desc', child: Text('Razão Social (Z-A)')),
                          DropdownMenuItem(value: 'cnpj,asc', child: Text('CNPJ (Crescente)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => tempSort = val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempActive = null;
                                  tempSort = 'id,asc';
                                });
                              },
                              child: const Text('Limpar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              key: const Key('apply-company-filters-button'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.brandYellow,
                                foregroundColor: AppTheme.primaryNavy,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedActiveFilter = tempActive;
                                  _selectedSort = tempSort;
                                });
                                Navigator.of(dialogCtx).pop();
                                _loadCompanies(page: 0);
                              },
                              child: const Text('Aplicar Filtros'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCreateForm() async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para cadastrar novas empresas clientes com segurança, acesse sua conta corporativa.',
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
        reason: 'Para editar os dados da empresa cliente, realize o login corporativo.',
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
    final hasActiveFilterCount = (_selectedActiveFilter != null ? 1 : 0) + (_selectedSort != 'id,asc' ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const Key('open-company-filters-button'),
            icon: Badge(
              isLabelVisible: hasActiveFilterCount > 0,
              label: Text('$hasActiveFilterCount'),
              child: const Icon(Icons.tune),
            ),
            tooltip: 'Filtros avançados',
            onPressed: _openAdvancedFiltersModal,
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            key: const Key('company-sort-menu'),
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar empresas',
            initialValue: _selectedSort,
            onSelected: (val) {
              setState(() => _selectedSort = val);
              _loadCompanies(page: 0);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'legalName,asc', child: Text('Razão Social (A-Z)')),
              PopupMenuItem(value: 'legalName,desc', child: Text('Razão Social (Z-A)')),
              PopupMenuItem(value: 'cnpj,asc', child: Text('CNPJ (Crescente)')),
              PopupMenuItem(value: 'id,desc', child: Text('Mais recentes')),
              PopupMenuItem(value: 'id,asc', child: Text('Mais antigas')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

  Widget _buildActiveFilterBadges() {
    final badges = <Widget>[];

    if (_selectedActiveFilter != null) {
      badges.add(Chip(
        avatar: Icon(_selectedActiveFilter! ? Icons.check_circle_outline : Icons.block, size: 16),
        label: Text(_selectedActiveFilter! ? 'Situação: Ativas' : 'Situação: Inativas'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() => _selectedActiveFilter = null);
          _loadCompanies(page: 0);
        },
      ));
    }

    if (_selectedSort != 'id,asc') {
      badges.add(Chip(
        avatar: const Icon(Icons.sort, size: 16),
        label: Text('Ordem: ${_getSortLabel(_selectedSort)}'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() => _selectedSort = 'id,asc');
          _loadCompanies(page: 0);
        },
      ));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...badges,
          TextButton(
            key: const Key('company-clear-all-filters-button'),
            onPressed: _clearAllFilters,
            child: const Text('Limpar todos', style: TextStyle(fontSize: 12)),
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
            style: const TextStyle(fontSize: 13),
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

      if (_hasActiveFilters) {
        return EmptyStateView(
          icon: Icons.filter_alt_off_outlined,
          title: 'Nenhuma empresa encontrada',
          message: 'Não há empresas correspondentes aos filtros selecionados.',
          actionLabel: 'Limpar filtros',
          onAction: _clearAllFilters,
        );
      }

      return EmptyStateView(
        icon: Icons.business_outlined,
        title: 'Nenhuma empresa encontrada',
        message: 'Cadastre sua primeira empresa para gerenciar suas obrigações fiscais.',
        actionLabel: _isAuthenticated ? 'Nova Empresa' : null,
        onAction: _isAuthenticated ? _openCreateForm : null,
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
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF1F5F9),
                child: Icon(
                  Icons.business,
                  color: company.active ? AppTheme.primaryNavy : const Color(0xFF94A3B8),
                ),
              ),
              title: Text(
                company.legalName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (company.tradeName != null && company.tradeName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      company.tradeName!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'CNPJ: $formattedCnpj',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    padding: EdgeInsets.zero,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: company.active
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                    backgroundColor: company.active
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    label: Text(company.active ? 'Ativa' : 'Inativa'),
                  ),
                  if (_isAuthenticated) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      key: Key('company-edit-button-${company.id}'),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Editar empresa',
                      onPressed: () => _openEditForm(company),
                    ),
                  ],
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
      themeController: widget.themeController,
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
          _buildActiveFilterBadges(),
          const Divider(height: 1),
          Expanded(child: _buildListContent()),
          _buildPaginationBar(),
        ],
      ),
      floatingActionButton: _isAuthenticated
          ? FloatingActionButton.extended(
              key: const Key('new-company-fab'),
              onPressed: _openCreateForm,
              icon: const Icon(Icons.add),
              label: const Text('Nova Empresa'),
            )
          : null,
    );
  }
}
