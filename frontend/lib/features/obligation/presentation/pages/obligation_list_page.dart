import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../../company/domain/entities/company.dart';
import '../../../company/domain/repositories/company_repository.dart';
import '../../../responsible/domain/entities/responsible.dart';
import '../../../responsible/domain/repositories/responsible_repository.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';
import 'obligation_form_page.dart';

class ObligationListPage extends StatefulWidget {
  final ObligationRepository repository;
  final CompanyRepository? companyRepository;
  final ResponsibleRepository? responsibleRepository;
  final void Function(Obligation obligation)? onObligationTap;
  final AuthSessionController? authController;
  final ThemeController? themeController;
  final int? initialCompanyId;
  final int? initialResponsibleId;

  const ObligationListPage({
    super.key,
    required this.repository,
    this.companyRepository,
    this.responsibleRepository,
    this.onObligationTap,
    this.authController,
    this.themeController,
    this.initialCompanyId,
    this.initialResponsibleId,
  });

  @override
  State<ObligationListPage> createState() => _ObligationListPageState();
}

class _ObligationListPageState extends State<ObligationListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Obligation> _obligations = [];

  // Filtros
  ObligationStatus? _selectedStatusFilter;
  int? _selectedCompanyId;
  int? _selectedResponsibleId;
  DateTime? _dueFrom;
  DateTime? _dueTo;
  bool _filterOverdue = false;

  // Listas de apoio para filtros
  List<Company> _availableCompanies = [];
  List<Responsible> _availableResponsibles = [];

  // Busca e ordenação
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedSort = 'dueDate,asc';

  // Paginação
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  final int _pageSize = 10;

  bool get _isAuthenticated => widget.authController?.isAuthenticated ?? false;

  @override
  void initState() {
    super.initState();
    _selectedCompanyId = widget.initialCompanyId;
    _selectedResponsibleId = widget.initialResponsibleId;
    widget.authController?.addListener(_onAuthChanged);
    _loadSupportingData();
    _loadObligations();
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

  Future<void> _loadSupportingData() async {
    if (widget.companyRepository != null) {
      try {
        final compPage = await widget.companyRepository!.getCompanies(size: 100);
        if (mounted) setState(() => _availableCompanies = compPage.content);
      } catch (_) {}
    }
    if (widget.responsibleRepository != null) {
      try {
        final respPage = await widget.responsibleRepository!.getResponsibles(size: 100);
        if (mounted) setState(() => _availableResponsibles = respPage.content);
      } catch (_) {}
    }
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadObligations({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final query = _searchController.text.trim();

    String? dueFromStr = _dueFrom != null ? _toIsoDate(_dueFrom!) : null;
    String? dueToStr;

    if (_filterOverdue) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      dueToStr = _toIsoDate(yesterday);
    } else if (_dueTo != null) {
      dueToStr = _toIsoDate(_dueTo!);
    }

    try {
      final result = await widget.repository.getObligations(
        companyId: _selectedCompanyId,
        responsibleId: _selectedResponsibleId,
        status: _selectedStatusFilter,
        dueFrom: dueFromStr,
        dueTo: dueToStr,
        q: query.isNotEmpty ? query : null,
        page: page,
        size: _pageSize,
        sort: _selectedSort,
      );
      if (!mounted) return;
      setState(() {
        _obligations = result.content;
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
      _loadObligations(page: 0);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _loadObligations(page: 0);
  }

  void _onStatusFilterSelected(ObligationStatus? status) {
    if (_selectedStatusFilter == status) return;
    setState(() {
      _selectedStatusFilter = status;
    });
    _loadObligations(page: 0);
  }

  void _toggleOverdueFilter() {
    setState(() {
      _filterOverdue = !_filterOverdue;
      if (_filterOverdue) {
        _dueTo = null; // Sobrescreve data final com ontem
        if (_selectedStatusFilter == ObligationStatus.completed) {
          _selectedStatusFilter = null;
        }
      }
    });
    _loadObligations(page: 0);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatusFilter = null;
      _selectedCompanyId = null;
      _selectedResponsibleId = null;
      _dueFrom = null;
      _dueTo = null;
      _filterOverdue = false;
      _searchController.clear();
    });
    _loadObligations(page: 0);
  }

  bool get _hasActiveFilters =>
      _selectedStatusFilter != null ||
      _selectedCompanyId != null ||
      _selectedResponsibleId != null ||
      _dueFrom != null ||
      _dueTo != null ||
      _filterOverdue ||
      _searchController.text.trim().isNotEmpty;

  Future<void> _openDetails(Obligation item) async {
    if (widget.onObligationTap != null) {
      widget.onObligationTap!(item);
      return;
    }

    final hasChanges = await Navigator.of(context).pushNamed(
      AppRoutes.obligationDetails,
      arguments: item,
    );

    if (hasChanges == true && mounted) {
      _loadObligations(page: _currentPage);
    }
  }

  Future<void> _openCreateForm() async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para cadastrar novas obrigações fiscais com segurança, acesse sua conta corporativa.',
      );
      if (!allowed || !mounted) return;
    }

    if (widget.companyRepository == null || widget.responsibleRepository == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repositórios de apoio não configurados.')),
      );
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ObligationFormPage(
          obligationRepository: widget.repository,
          companyRepository: widget.companyRepository!,
          responsibleRepository: widget.responsibleRepository!,
        ),
      ),
    );

    if (created == true && mounted) {
      _loadObligations(page: 0);
    }
  }

  Future<void> _openEditForm(Obligation obligation) async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para editar a obrigação fiscal com segurança, acesse sua conta corporativa.',
      );
      if (!allowed || !mounted) return;
    }

    if (widget.companyRepository == null || widget.responsibleRepository == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repositórios de apoio não configurados.')),
      );
      return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ObligationFormPage(
          obligationRepository: widget.repository,
          companyRepository: widget.companyRepository!,
          responsibleRepository: widget.responsibleRepository!,
          obligation: obligation,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadObligations(page: _currentPage);
    }
  }

  Future<void> _openAdvancedFiltersModal() async {
    int? tempCompanyId = _selectedCompanyId;
    int? tempResponsibleId = _selectedResponsibleId;
    DateTime? tempDueFrom = _dueFrom;
    DateTime? tempDueTo = _dueTo;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  String dateRangeText = 'Não definido';
                  if (tempDueFrom != null && tempDueTo != null) {
                    dateRangeText = '${_formatDate(tempDueFrom)} até ${_formatDate(tempDueTo)}';
                  } else if (tempDueFrom != null) {
                    dateRangeText = 'A partir de ${_formatDate(tempDueFrom)}';
                  } else if (tempDueTo != null) {
                    dateRangeText = 'Até ${_formatDate(tempDueTo)}';
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filtros Avançados',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Empresa
                        DropdownButtonFormField<int?>(
                          key: const Key('filter-company-dropdown'),
                          decoration: const InputDecoration(
                            labelText: 'Empresa',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          value: tempCompanyId,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Todas as empresas'),
                            ),
                            ..._availableCompanies.map((c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.displayName, overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (val) {
                            setModalState(() => tempCompanyId = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Responsável
                        DropdownButtonFormField<int?>(
                          key: const Key('filter-responsible-dropdown'),
                          decoration: const InputDecoration(
                            labelText: 'Responsável',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          value: tempResponsibleId,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Todos os responsáveis'),
                            ),
                            ..._availableResponsibles.map((r) => DropdownMenuItem<int?>(
                                  value: r.id,
                                  child: Text(r.name, overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (val) {
                            setModalState(() => tempResponsibleId = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Intervalo de Prazo
                        ListTile(
                          key: const Key('filter-date-range-tile'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Intervalo de Vencimento', style: TextStyle(fontSize: 14)),
                          subtitle: Text(dateRangeText, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.calendar_today, size: 20),
                                tooltip: 'Selecionar período',
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    initialDateRange: (tempDueFrom != null && tempDueTo != null)
                                        ? DateTimeRange(start: tempDueFrom!, end: tempDueTo!)
                                        : null,
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      tempDueFrom = picked.start;
                                      tempDueTo = picked.end;
                                    });
                                  }
                                },
                              ),
                              if (tempDueFrom != null || tempDueTo != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  tooltip: 'Limpar datas',
                                  onPressed: () {
                                    setModalState(() {
                                      tempDueFrom = null;
                                      tempDueTo = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botões de Ação
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempCompanyId = null;
                                    tempResponsibleId = null;
                                    tempDueFrom = null;
                                    tempDueTo = null;
                                  });
                                },
                                child: const Text('Redefinir'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                key: const Key('filter-apply-button'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF17152F),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedCompanyId = tempCompanyId;
                                    _selectedResponsibleId = tempResponsibleId;
                                    _dueFrom = tempDueFrom;
                                    _dueTo = tempDueTo;
                                    if (_dueFrom != null || _dueTo != null) {
                                      _filterOverdue = false;
                                    }
                                  });
                                  Navigator.of(context).pop();
                                  _loadObligations(page: 0);
                                },
                                child: const Text('Aplicar Filtros'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ObligationStatus status) {
    switch (status) {
      case ObligationStatus.pending:
        return const Color(0xFFD97706);
      case ObligationStatus.inProgress:
        return const Color(0xFF2563EB);
      case ObligationStatus.completed:
        return const Color(0xFF16A34A);
    }
  }

  Color _getStatusBgColor(ObligationStatus status) {
    switch (status) {
      case ObligationStatus.pending:
        return const Color(0xFFFEF3C7);
      case ObligationStatus.inProgress:
        return const Color(0xFFDBEAFE);
      case ObligationStatus.completed:
        return const Color(0xFFDCFCE7);
    }
  }

  IconData _getStatusIcon(ObligationStatus status) {
    switch (status) {
      case ObligationStatus.pending:
        return Icons.pending_outlined;
      case ObligationStatus.inProgress:
        return Icons.autorenew;
      case ObligationStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSearchBar() {
    final activeFiltersCount = (_selectedCompanyId != null ? 1 : 0) +
        (_selectedResponsibleId != null ? 1 : 0) +
        (_dueFrom != null || _dueTo != null ? 1 : 0) +
        (_filterOverdue ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('obligation-search-field'),
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _loadObligations(page: 0),
              decoration: InputDecoration(
                hintText: 'Pesquisar obrigações...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        key: const Key('obligation-search-clear'),
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
            key: const Key('open-filters-modal-button'),
            icon: Badge(
              isLabelVisible: activeFiltersCount > 0,
              label: Text('$activeFiltersCount'),
              child: const Icon(Icons.tune),
            ),
            tooltip: 'Filtros avançados',
            onPressed: _openAdvancedFiltersModal,
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            key: const Key('obligation-sort-menu'),
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            initialValue: _selectedSort,
            onSelected: (val) {
              setState(() => _selectedSort = val);
              _loadObligations(page: 0);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'dueDate,asc', child: Text('Prazo (Mais próximo)')),
              PopupMenuItem(value: 'dueDate,desc', child: Text('Prazo (Mais distante)')),
              PopupMenuItem(value: 'id,desc', child: Text('Mais recentes')),
              PopupMenuItem(value: 'title,asc', child: Text('Título (A-Z)')),
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
            key: const Key('filter-all'),
            label: const Text('Todas'),
            selected: _selectedStatusFilter == null && !_filterOverdue,
            onSelected: (_) {
              setState(() {
                _selectedStatusFilter = null;
                _filterOverdue = false;
              });
              _loadObligations(page: 0);
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('filter-pending'),
            label: const Text('Pendentes'),
            selected: _selectedStatusFilter == ObligationStatus.pending,
            onSelected: (_) => _onStatusFilterSelected(ObligationStatus.pending),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('filter-in-progress'),
            label: const Text('Em Andamento'),
            selected: _selectedStatusFilter == ObligationStatus.inProgress,
            onSelected: (_) => _onStatusFilterSelected(ObligationStatus.inProgress),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('filter-completed'),
            label: const Text('Concluídas'),
            selected: _selectedStatusFilter == ObligationStatus.completed,
            onSelected: (_) => _onStatusFilterSelected(ObligationStatus.completed),
          ),
          const SizedBox(width: 8),
          FilterChip(
            key: const Key('filter-overdue-chip'),
            label: const Text('Apenas Atrasadas'),
            selected: _filterOverdue,
            selectedColor: const Color(0xFFFEE2E2),
            checkmarkColor: const Color(0xFFDC2626),
            labelStyle: TextStyle(
              color: _filterOverdue ? const Color(0xFFDC2626) : Theme.of(context).colorScheme.onSurface,
              fontWeight: _filterOverdue ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) => _toggleOverdueFilter(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterBadges() {
    final company = _availableCompanies.where((c) => c.id == _selectedCompanyId).firstOrNull;
    final responsible = _availableResponsibles.where((r) => r.id == _selectedResponsibleId).firstOrNull;

    final badges = <Widget>[];

    if (_selectedCompanyId != null) {
      badges.add(Chip(
        avatar: const Icon(Icons.business, size: 16),
        label: Text('Empresa: ${company?.displayName ?? "ID $_selectedCompanyId"}'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() => _selectedCompanyId = null);
          _loadObligations(page: 0);
        },
      ));
    }

    if (_selectedResponsibleId != null) {
      badges.add(Chip(
        avatar: const Icon(Icons.person, size: 16),
        label: Text('Resp: ${responsible?.name ?? "ID $_selectedResponsibleId"}'),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() => _selectedResponsibleId = null);
          _loadObligations(page: 0);
        },
      ));
    }

    if (_dueFrom != null || _dueTo != null) {
      final text = 'Venc: ${_dueFrom != null ? _formatDate(_dueFrom) : "..."} até ${_dueTo != null ? _formatDate(_dueTo) : "..."}';
      badges.add(Chip(
        avatar: const Icon(Icons.calendar_today, size: 16),
        label: Text(text),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () {
          setState(() {
            _dueFrom = null;
            _dueTo = null;
          });
          _loadObligations(page: 0);
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
            key: const Key('clear-all-filters-button'),
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
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton.outlined(
            key: const Key('obligation-pagination-prev'),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
            onPressed: hasPrevious && !_isLoading
                ? () => _loadObligations(page: _currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            key: const Key('obligation-pagination-next'),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
            onPressed: hasNext && !_isLoading
                ? () => _loadObligations(page: _currentPage + 1)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Página ${_currentPage + 1} de ${_totalPages > 0 ? _totalPages : 1} ($_totalElements)',
            key: const Key('obligation-pagination-info'),
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const LoadingStateView(message: 'Carregando obrigações fiscais...');
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: () => _loadObligations(page: _currentPage),
      );
    }

    final query = _searchController.text.trim();

    if (_obligations.isEmpty) {
      if (query.isNotEmpty) {
        return EmptyStateView(
          icon: Icons.search_off_outlined,
          title: "Nenhum resultado para '$query'",
          message: 'Nenhuma obrigação fiscal corresponde aos termos pesquisados.',
          actionLabel: 'Limpar pesquisa',
          onAction: _clearSearch,
        );
      }

      if (_hasActiveFilters) {
        return EmptyStateView(
          icon: Icons.filter_alt_off_outlined,
          title: 'Nenhuma obrigação encontrada',
          message: 'Não há obrigações com os filtros selecionados.',
          actionLabel: 'Limpar filtros',
          onAction: _clearAllFilters,
        );
      }

      return EmptyStateView(
        icon: Icons.assignment_outlined,
        title: 'Nenhuma obrigação encontrada',
        message: 'Cadastre a primeira obrigação contábil para começar o acompanhamento.',
        actionLabel: 'Nova Obrigação',
        onAction: _openCreateForm,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadObligations(page: _currentPage),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        itemCount: _obligations.length,
        itemBuilder: (context, index) {
          final item = _obligations[index];
          final statusColor = _getStatusColor(item.status);
          final statusBgColor = _getStatusBgColor(item.status);
          final colorScheme = Theme.of(context).colorScheme;

          return Card(
            key: Key('obligation-card-${item.id}'),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: item.isOverdue
                    ? const Color(0xFFFCA5A5)
                    : Theme.of(context).dividerColor,
                width: item.isOverdue ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openDetails(item),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(item.status), size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                item.status.label,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isAuthenticated && item.status != ObligationStatus.completed) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            key: Key('obligation-edit-button-${item.id}'),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Editar obrigação',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _openEditForm(item),
                          ),
                        ],
                      ],
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      children: [
                        Icon(Icons.business_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.company.name,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          item.responsible.name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 15,
                              color: item.isOverdue
                                  ? const Color(0xFFDC2626)
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Vencimento: ${_formatDate(item.dueDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: item.isOverdue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: item.isOverdue
                                    ? const Color(0xFFDC2626)
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (item.isOverdue) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Atrasada',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_outlined, size: 15, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              'Criada em: ${_formatDate(item.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file, size: 15, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              '${item.attachmentCount} anexos',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
      title: 'Obrigações Fiscais',
      currentNavIndex: 0,
      authController: widget.authController,
      themeController: widget.themeController,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
          onPressed: () => _loadObligations(page: _currentPage),
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
              key: const Key('new-obligation-fab'),
              onPressed: _openCreateForm,
              icon: const Icon(Icons.add),
              label: const Text('Nova Obrigação'),
            )
          : null,
    );
  }
}
