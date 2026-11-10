import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';

class ObligationListPage extends StatefulWidget {
  final ObligationRepository repository;
  final void Function(Obligation obligation)? onObligationTap;
  final AuthSessionController? authController;

  const ObligationListPage({
    super.key,
    required this.repository,
    this.onObligationTap,
    this.authController,
  });

  @override
  State<ObligationListPage> createState() => _ObligationListPageState();
}

class _ObligationListPageState extends State<ObligationListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Obligation> _obligations = [];
  ObligationStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadObligations();
  }

  Future<void> _loadObligations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.getObligations(
        status: _selectedStatusFilter,
      );
      if (!mounted) return;
      setState(() {
        _obligations = result.content;
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

  void _onStatusFilterSelected(ObligationStatus? status) {
    if (_selectedStatusFilter == status) return;
    setState(() {
      _selectedStatusFilter = status;
    });
    _loadObligations();
  }

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
      _loadObligations();
    }
  }

  Color _getStatusColor(ObligationStatus status) {
    switch (status) {
      case ObligationStatus.pending:
        return const Color(0xFFD97706); // Amber
      case ObligationStatus.inProgress:
        return const Color(0xFF2563EB); // Blue
      case ObligationStatus.completed:
        return const Color(0xFF16A34A); // Green
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ChoiceChip(
            key: const Key('filter-all'),
            label: const Text('Todas'),
            selected: _selectedStatusFilter == null,
            onSelected: (_) => _onStatusFilterSelected(null),
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
        onRetry: _loadObligations,
      );
    }

    if (_obligations.isEmpty) {
      return EmptyStateView(
        icon: Icons.assignment_outlined,
        title: 'Nenhuma obrigação encontrada',
        message: _selectedStatusFilter != null
            ? 'Não há obrigações com o filtro selecionado.'
            : 'Cadastre a primeira obrigação contábil para começar o acompanhamento.',
        actionLabel: 'Nova Obrigação',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro em desenvolvimento.')),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadObligations,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 4),
        itemCount: _obligations.length,
        itemBuilder: (context, index) {
          final item = _obligations[index];
          final statusColor = _getStatusColor(item.status);
          final statusBgColor = _getStatusBgColor(item.status);

          return Card(
            key: Key('obligation-card-${item.id}'),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: item.isOverdue
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFE2E8F0),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
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
                      ],
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.company.name,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.person_outline, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          item.responsible.name,
                          style: const TextStyle(
                            color: Color(0xFF334155),
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
                                  : const Color(0xFF64748B),
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
                                    : const Color(0xFF64748B),
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
                            const Icon(Icons.schedule_outlined, size: 15, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              'Criada em: ${_formatDate(item.createdAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_file, size: 15, color: Color(0xFF64748B)),
                            const SizedBox(width: 2),
                            Text(
                              '${item.attachmentCount} anexos',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
          onPressed: _loadObligations,
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
        onPressed: () async {
          if (widget.authController != null) {
            final allowed = await requireAuth(
              context,
              authController: widget.authController!,
              reason: 'Para cadastrar uma obrigação, realize o login.',
            );
            if (!allowed) return;
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro em desenvolvimento.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Obrigação'),
      ),
    );
  }
}
