import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';

class ObligationListPage extends StatefulWidget {
  final ObligationRepository repository;

  const ObligationListPage({
    super.key,
    required this.repository,
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
      setState(() {
        _obligations = result.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const LoadingStateView(message: 'Carregando obrigações fiscais...');
    } else if (_errorMessage != null) {
      content = ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadObligations,
      );
    } else if (_obligations.isEmpty) {
      content = EmptyStateView(
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
    } else {
      content = RefreshIndicator(
        onRefresh: _loadObligations,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _obligations.length,
          itemBuilder: (context, index) {
            final item = _obligations[index];
            final statusColor = _getStatusColor(item.status);
            final statusBgColor = _getStatusBgColor(item.status);
            final formattedDueDate =
                '${item.dueDate.day.toString().padLeft(2, '0')}/${item.dueDate.month.toString().padLeft(2, '0')}/${item.dueDate.year}';

            return Card(
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
                          ),
                          child: Text(
                            item.status.label,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.company.name,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.person, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          item.responsible.name,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: item.isOverdue
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Vencimento: $formattedDueDate',
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
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.attach_file, size: 14, color: Color(0xFF64748B)),
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
            );
          },
        ),
      );
    }

    return AppScaffold(
      title: 'Obrigações Fiscais',
      currentNavIndex: 0,
      actions: [
        PopupMenuButton<ObligationStatus?>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtrar por Status',
          initialValue: _selectedStatusFilter,
          onSelected: (status) {
            setState(() {
              _selectedStatusFilter = status;
            });
            _loadObligations();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: null,
              child: Text('Todos os Status'),
            ),
            const PopupMenuItem(
              value: ObligationStatus.pending,
              child: Text('Pendentes'),
            ),
            const PopupMenuItem(
              value: ObligationStatus.inProgress,
              child: Text('Em Andamento'),
            ),
            const PopupMenuItem(
              value: ObligationStatus.completed,
              child: Text('Concluídas'),
            ),
          ],
        ),
      ],
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro de obrigações em breve.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Obrigação'),
      ),
    );
  }
}
