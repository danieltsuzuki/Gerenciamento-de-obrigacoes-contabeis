import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
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

  const ResponsibleListPage({
    super.key,
    required this.repository,
    this.authController,
  });

  @override
  State<ResponsibleListPage> createState() => _ResponsibleListPageState();
}

class _ResponsibleListPageState extends State<ResponsibleListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Responsible> _responsibles = [];
  bool? _selectedActiveFilter;

  @override
  void initState() {
    super.initState();
    _loadResponsibles();
  }

  Future<void> _loadResponsibles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.getResponsibles(
        active: _selectedActiveFilter,
      );
      if (!mounted) return;
      setState(() {
        _responsibles = result.content;
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
    _loadResponsibles();
  }

  Future<void> _openCreateForm() async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para cadastrar um novo responsável, realize o login.',
      );
      if (!allowed || !mounted) return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResponsibleFormPage(repository: widget.repository),
      ),
    );
    if (created == true && mounted) {
      _loadResponsibles();
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
      _loadResponsibles();
    }
  }

  Future<void> _openEditForm(Responsible responsible) async {
    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para editar os dados do responsável, realize o login.',
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
      _loadResponsibles();
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildListContent() {
    if (_isLoading) {
      return const LoadingStateView(message: 'Carregando responsáveis contábeis...');
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadResponsibles,
      );
    }

    if (_responsibles.isEmpty) {
      return EmptyStateView(
        icon: Icons.people_outline,
        title: 'Nenhum responsável encontrado',
        message: _selectedActiveFilter != null
            ? 'Não há responsáveis com o filtro selecionado.'
            : 'Cadastre os contadores e analistas que serão responsáveis pelas obrigações fiscais.',
        actionLabel: 'Novo Responsável',
        onAction: _openCreateForm,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResponsibles,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _responsibles.length,
        itemBuilder: (context, index) {
          final responsible = _responsibles[index];

          return Card(
            key: Key('responsible-card-${responsible.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => _openDetails(responsible),
              leading: CircleAvatar(
                backgroundColor: responsible.active
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFFF1F5F9),
                child: Text(
                  responsible.name.isNotEmpty
                      ? responsible.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: responsible.active
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              title: Text(
                responsible.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                responsible.email,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      responsible.active ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        color: responsible.active
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: responsible.active
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                  ),
                  IconButton(
                    key: Key('responsible-edit-button-${responsible.id}'),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Editar responsável',
                    onPressed: () => _openEditForm(responsible),
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
      title: 'Responsáveis',
      currentNavIndex: 2,
      authController: widget.authController,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
          onPressed: _loadResponsibles,
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
        key: const Key('new-responsible-fab'),
        onPressed: _openCreateForm,
        icon: const Icon(Icons.add),
        label: const Text('Novo Responsável'),
      ),
    );
  }
}
