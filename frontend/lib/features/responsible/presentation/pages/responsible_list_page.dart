import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../domain/entities/responsible.dart';
import '../../domain/repositories/responsible_repository.dart';
import 'responsible_detail_page.dart';
import 'responsible_form_page.dart';

class ResponsibleListPage extends StatefulWidget {
  final ResponsibleRepository repository;
  final AuthSessionController? authController;
  final ThemeController? themeController;

  const ResponsibleListPage({
    super.key,
    required this.repository,
    this.authController,
    this.themeController,
  });

  @override
  State<ResponsibleListPage> createState() => _ResponsibleListPageState();
}

class _ResponsibleListPageState extends State<ResponsibleListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Responsible> _responsibles = [];
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
    _loadResponsibles();
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

  Future<void> _loadResponsibles({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final query = _searchController.text.trim();

    try {
      final result = await widget.repository.getResponsibles(
        active: _selectedActiveFilter,
        page: page,
        size: _pageSize,
        sort: _selectedSort,
        q: query.isNotEmpty ? query : null,
      );
      if (!mounted) return;
      setState(() {
        _responsibles = result.content;
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
      _loadResponsibles(page: 0);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _loadResponsibles(page: 0);
  }

  void _onActiveFilterSelected(bool? active) {
    if (_selectedActiveFilter == active) return;
    setState(() {
      _selectedActiveFilter = active;
    });
    _loadResponsibles(page: 0);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedActiveFilter = null;
      _selectedSort = 'id,asc';
      _searchController.clear();
    });
    _loadResponsibles(page: 0);
  }

  bool get _hasActiveFilters =>
      _selectedActiveFilter != null ||
      _selectedSort != 'id,asc' ||
      _searchController.text.trim().isNotEmpty;

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'name,asc':
        return 'Nome (A-Z)';
      case 'name,desc':
        return 'Nome (Z-A)';
      case 'email,asc':
        return 'E-mail';
      case 'id,desc':
        return 'Mais recentes';
      case 'id,asc':
      default:
        return 'Mais antigos';
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
                                    'Filtros de Responsáveis',
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
                            key: const Key('responsible-filter-active-chip-all'),
                            label: const Text('Todos'),
                            selected: tempActive == null,
                            onSelected: (_) => setModalState(() => tempActive = null),
                          ),
                          ChoiceChip(
                            key: const Key('responsible-filter-active-chip-true'),
                            label: const Text('Ativos'),
                            selected: tempActive == true,
                            onSelected: (_) => setModalState(() => tempActive = true),
                          ),
                          ChoiceChip(
                            key: const Key('responsible-filter-active-chip-false'),
                            label: const Text('Inativos'),
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
                        key: const Key('responsible-filter-sort-dropdown'),
                        value: tempSort,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'id,asc', child: Text('Mais antigos primeiro')),
                          DropdownMenuItem(value: 'id,desc', child: Text('Mais recentes primeiro')),
                          DropdownMenuItem(value: 'name,asc', child: Text('Nome (A-Z)')),
                          DropdownMenuItem(value: 'name,desc', child: Text('Nome (Z-A)')),
                          DropdownMenuItem(value: 'email,asc', child: Text('E-mail (Crescente)')),
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
                              key: const Key('apply-responsible-filters-button'),
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
                                _loadResponsibles(page: 0);
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
        reason: 'Para cadastrar novos colaboradores responsáveis com segurança, acesse sua conta corporativa.',
      );
      if (!allowed || !mounted) return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResponsibleFormPage(repository: widget.repository),
      ),
    );
    if (created == true && mounted) {
      _loadResponsibles(page: 0);
    }
  }

  Future<void> _openDetails(Responsible responsible) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResponsibleDetailPage(
          repository: widget.repository,
          responsibleId: responsible.id,
          initialResponsible: responsible,
          authController: widget.authController,
        ),
      ),
    );
    if (changed == true && mounted) {
      _loadResponsibles(page: _currentPage);
    }
  }

  Future<void> _openEditForm(Responsible responsible) async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para editar os dados do colaborador responsável, realize o login corporativo.',
      );
      if (!allowed || !mounted) return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResponsibleFormPage(
          repository: widget.repository,
          responsible: responsible,
        ),
      ),
    );
    if (updated == true && mounted) {
      _loadResponsibles(page: _currentPage);
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
              key: const Key('responsible-search-field'),
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _loadResponsibles(page: 0),
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou e-mail...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        key: const Key('responsible-search-clear'),
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
            key: const Key('open-responsible-filters-button'),
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
            key: const Key('responsible-sort-menu'),
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar responsáveis',
            initialValue: _selectedSort,
            onSelected: (val) {
              setState(() => _selectedSort = val);
              _loadResponsibles(page: 0);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'name,asc', child: Text('Nome (A-Z)')),
              PopupMenuItem(value: 'name,desc', child: Text('Nome (Z-A)')),
              PopupMenuItem(value: 'email,asc', child: Text('E-mail (Crescente)')),
              PopupMenuItem(value: 'id,desc', child: Text('Mais recentes')),
              PopupMenuItem(value: 'id,asc', child: Text('Mais antigos')),
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
            key: const Key('responsible-filter-all'),
            label: const Text('Todos'),
            selected: _selectedActiveFilter == null,
            onSelected: (_) => _onActiveFilterSelected(null),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('responsible-filter-active'),
            label: const Text('Ativos'),
            selected: _selectedActiveFilter == true,
            onSelected: (_) => _onActiveFilterSelected(true),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('responsible-filter-inactive'),
            label: const Text('Inativos'),
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
        label: Text(_selectedActiveFilter! ? 'Situação: Ativos' : 'Situação: Inativos'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() => _selectedActiveFilter = null);
          _loadResponsibles(page: 0);
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
          _loadResponsibles(page: 0);
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
            key: const Key('responsible-clear-all-filters-button'),
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
            key: const Key('responsible-pagination-prev'),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
            onPressed: hasPrevious && !_isLoading
                ? () => _loadResponsibles(page: _currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            key: const Key('responsible-pagination-next'),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
            onPressed: hasNext && !_isLoading
                ? () => _loadResponsibles(page: _currentPage + 1)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Página ${_currentPage + 1} de ${_totalPages > 0 ? _totalPages : 1} ($_totalElements)',
            key: const Key('responsible-pagination-info'),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const LoadingStateView(message: 'Carregando colaboradores responsáveis...');
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: () => _loadResponsibles(page: _currentPage),
      );
    }

    final query = _searchController.text.trim();

    if (_responsibles.isEmpty) {
      if (query.isNotEmpty) {
        return EmptyStateView(
          icon: Icons.search_off_outlined,
          title: "Nenhum resultado para '$query'",
          message: 'Nenhum responsável corresponde aos termos pesquisados.',
          actionLabel: 'Limpar pesquisa',
          onAction: _clearSearch,
        );
      }

      if (_hasActiveFilters) {
        return EmptyStateView(
          icon: Icons.filter_alt_off_outlined,
          title: 'Nenhum responsável encontrado',
          message: 'Não há responsáveis correspondentes aos filtros selecionados.',
          actionLabel: 'Limpar filtros',
          onAction: _clearAllFilters,
        );
      }

      return EmptyStateView(
        icon: Icons.people_outline,
        title: 'Nenhum responsável encontrado',
        message: 'Cadastre seu primeiro colaborador responsável para acompanhar obrigações.',
        actionLabel: _isAuthenticated ? 'Novo Responsável' : null,
        onAction: _isAuthenticated ? _openCreateForm : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadResponsibles(page: _currentPage),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _responsibles.length,
        itemBuilder: (context, index) {
          final resp = _responsibles[index];

          return Card(
            key: Key('responsible-card-${resp.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => _openDetails(resp),
              leading: CircleAvatar(
                backgroundColor: resp.active
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF1F5F9),
                child: Text(
                  resp.name.isNotEmpty ? resp.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: resp.active ? AppTheme.primaryNavy : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              title: Text(
                resp.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                resp.email,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    padding: EdgeInsets.zero,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: resp.active
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                    backgroundColor: resp.active
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    label: Text(resp.active ? 'Ativo' : 'Inativo'),
                  ),
                  if (_isAuthenticated) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      key: Key('responsible-edit-button-${resp.id}'),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Editar responsável',
                      onPressed: () => _openEditForm(resp),
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
      title: 'Responsáveis',
      currentNavIndex: 2,
      authController: widget.authController,
      themeController: widget.themeController,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
          onPressed: () => _loadResponsibles(page: _currentPage),
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
              key: const Key('new-responsible-fab'),
              onPressed: _openCreateForm,
              icon: const Icon(Icons.add),
              label: const Text('Novo Responsável'),
            )
          : null,
    );
  }
}
