import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../../company/domain/repositories/company_repository.dart';
import '../../../responsible/domain/repositories/responsible_repository.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';
import 'obligation_form_page.dart';

class ObligationDetailPage extends StatefulWidget {
  final ObligationRepository repository;
  final CompanyRepository? companyRepository;
  final ResponsibleRepository? responsibleRepository;
  final int obligationId;
  final Obligation? initialObligation;
  final AuthSessionController? authController;

  const ObligationDetailPage({
    super.key,
    required this.repository,
    this.companyRepository,
    this.responsibleRepository,
    required this.obligationId,
    this.initialObligation,
    this.authController,
  });

  @override
  State<ObligationDetailPage> createState() => _ObligationDetailPageState();
}

class _ObligationDetailPageState extends State<ObligationDetailPage> {
  Obligation? _obligation;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMutated = false;

  bool get _isAuthenticated => widget.authController?.isAuthenticated ?? false;
  bool get _canEdit =>
      _isAuthenticated &&
      _obligation != null &&
      _obligation!.status != ObligationStatus.completed;

  @override
  void initState() {
    super.initState();
    _obligation = widget.initialObligation;
    widget.authController?.addListener(_onAuthChanged);
    if (_obligation == null) {
      _loadObligation();
    }
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.authController?.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _loadObligation() async {
    if (_obligation == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final ob = await widget.repository.getObligationById(widget.obligationId);
      if (!mounted) return;
      setState(() {
        _obligation = ob;
        _isLoading = false;
        _errorMessage = null;
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
        _errorMessage = 'Falha ao carregar detalhes da obrigação: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openEdit() async {
    if (_obligation == null || !_canEdit) return;

    if (widget.authController != null) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para editar a obrigação, realize o login.',
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
          obligation: _obligation,
        ),
      ),
    );

    if (updated == true && mounted) {
      _hasMutated = true;
      _loadObligation();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_hasMutated);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes da Obrigação'),
          actions: [
            if (_canEdit)
              IconButton(
                key: const Key('obligation-detail-edit-button'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar obrigação',
                onPressed: _openEdit,
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recarregar',
              onPressed: _loadObligation,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _obligation == null) {
      return const LoadingStateView(message: 'Carregando detalhes da obrigação...');
    }

    if (_errorMessage != null && _obligation == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadObligation,
      );
    }

    final obligation = _obligation;
    if (obligation == null) {
      return const Center(child: Text('Obrigação não encontrada.'));
    }

    return RefreshIndicator(
      onRefresh: _loadObligation,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(obligation),
                const SizedBox(height: 16),
                _buildDetailsCard(obligation),
                if (_canEdit) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    key: const Key('obligation-detail-edit-action'),
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar Obrigação'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Obligation obligation) {
    final statusColor = _getStatusColor(obligation.status);
    final statusBgColor = _getStatusBgColor(obligation.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: obligation.isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: obligation.isOverdue ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    obligation.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      Icon(_getStatusIcon(obligation.status), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        obligation.status.label,
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
            if (obligation.description != null && obligation.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                obligation.description!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
            ],
            if (obligation.isOverdue) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text(
                      'Prazo de entrega expirado (Atrasada)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Obligation obligation) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações e Vínculos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.tag,
              label: 'Identificador (ID)',
              value: '#${obligation.id}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.business_outlined,
              label: 'Empresa Vinculada',
              value: obligation.company.name,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Responsável Atribuído',
              value: obligation.responsible.name,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.event_outlined,
              label: 'Prazo Limite (Vencimento)',
              value: _formatDate(obligation.dueDate),
              valueColor: obligation.isOverdue ? const Color(0xFFDC2626) : null,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.schedule_outlined,
              label: 'Data de Criação',
              value: _formatDate(obligation.createdAt),
            ),
            if (obligation.completedAt != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                icon: Icons.check_circle_outline,
                label: 'Data de Conclusão',
                value: _formatDate(obligation.completedAt),
                valueColor: const Color(0xFF16A34A),
              ),
            ],
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.attach_file,
              label: 'Documentos Anexados',
              value: '${obligation.attachmentCount} anexos registrados',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

