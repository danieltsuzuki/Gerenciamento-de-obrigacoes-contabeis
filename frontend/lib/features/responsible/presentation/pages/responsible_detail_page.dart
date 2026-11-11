import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../domain/entities/responsible.dart';
import '../../domain/repositories/responsible_repository.dart';
import 'responsible_form_page.dart';

class ResponsibleDetailPage extends StatefulWidget {
  final ResponsibleRepository repository;
  final int responsibleId;
  final Responsible? initialResponsible;
  final AuthSessionController? authController;

  const ResponsibleDetailPage({
    super.key,
    required this.repository,
    required this.responsibleId,
    this.initialResponsible,
    this.authController,
  });

  @override
  State<ResponsibleDetailPage> createState() => _ResponsibleDetailPageState();
}

class _ResponsibleDetailPageState extends State<ResponsibleDetailPage> {
  Responsible? _responsible;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMutated = false;

  bool get _isAuthenticated => widget.authController?.isAuthenticated ?? false;

  @override
  void initState() {
    super.initState();
    _responsible = widget.initialResponsible;
    widget.authController?.addListener(_onAuthChanged);
    if (_responsible == null) {
      _loadResponsible();
    }
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.authController?.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _loadResponsible() async {
    if (_responsible == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final resp = await widget.repository.getResponsibleById(widget.responsibleId);
      if (!mounted) return;
      setState(() {
        _responsible = resp;
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
        _errorMessage = 'Falha ao carregar detalhes do responsável: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openEdit() async {
    if (_responsible == null) return;

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
          responsible: _responsible,
        ),
      ),
    );

    if (updated == true && mounted) {
      _hasMutated = true;
      _loadResponsible();
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
          title: const Text('Detalhes do Responsável'),
          actions: [
            if (_responsible != null && _isAuthenticated)
              IconButton(
                key: const Key('responsible-detail-edit-button'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar responsável',
                onPressed: _openEdit,
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recarregar',
              onPressed: _loadResponsible,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _responsible == null) {
      return const LoadingStateView(message: 'Carregando detalhes do responsável...');
    }

    if (_errorMessage != null && _responsible == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadResponsible,
      );
    }

    final responsible = _responsible;
    if (responsible == null) {
      return const Center(child: Text('Responsável não encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: _loadResponsible,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(responsible),
                const SizedBox(height: 16),
                _buildDetailsCard(responsible),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const Key('responsible-view-obligations-button'),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.obligations,
                      arguments: {'responsibleId': responsible.id},
                    );
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Ver Obrigações deste Responsável'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (_isAuthenticated) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    key: const Key('responsible-detail-edit-action'),
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar Responsável'),
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

  Widget _buildHeaderCard(Responsible responsible) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: responsible.active
                  ? const Color(0xFFDBEAFE)
                  : const Color(0xFFF1F5F9),
              child: Text(
                responsible.name.isNotEmpty ? responsible.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: responsible.active
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    responsible.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    responsible.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      responsible.active ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        color: responsible.active
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: responsible.active
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Responsible responsible) {
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
              'Informações Cadastrais',
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
              value: '#${responsible.id}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Nome Completo',
              value: responsible.name,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'E-mail Corporativo',
              value: responsible.email,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: responsible.active
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              label: 'Situação Operacional',
              value: responsible.active
                  ? 'Ativo — Pode ser vinculado a novas obrigações'
                  : 'Inativo — Não recebe novas obrigações (RN-005)',
              valueColor: responsible.active
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF64748B),
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
