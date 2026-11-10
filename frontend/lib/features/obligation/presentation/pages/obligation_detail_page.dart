import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../attachment/domain/entities/attachment.dart';
import '../../../attachment/domain/repositories/attachment_repository.dart';
import '../../../attachment/domain/services/file_picker_service.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../../company/domain/repositories/company_repository.dart';
import '../../../responsible/domain/repositories/responsible_repository.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';
import 'obligation_form_page.dart';

class ObligationDetailPage extends StatefulWidget {
  final ObligationRepository repository;
  final AttachmentRepository? attachmentRepository;
  final FilePickerService? filePickerService;
  final CompanyRepository? companyRepository;
  final ResponsibleRepository? responsibleRepository;
  final int obligationId;
  final Obligation? initialObligation;
  final AuthSessionController? authController;

  const ObligationDetailPage({
    super.key,
    required this.repository,
    this.attachmentRepository,
    this.filePickerService,
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
  List<Attachment> _attachments = [];
  bool _isLoadingObligation = false;
  bool _isLoadingAttachments = false;
  bool _isUpdatingStatus = false;
  bool _isUploadingAttachment = false;
  String? _errorMessage;
  String? _attachmentErrorMessage;
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
    _loadInitialData();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
      if (_isAuthenticated && _attachments.isEmpty && !_isLoadingAttachments) {
        _loadAttachments();
      }
    }
  }

  @override
  void dispose() {
    widget.authController?.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_obligation == null) {
      await _loadObligation();
    } else if (_isAuthenticated && widget.attachmentRepository != null) {
      _loadAttachments();
    }
  }

  Future<void> _loadObligation() async {
    if (_obligation == null) {
      setState(() {
        _isLoadingObligation = true;
        _errorMessage = null;
      });
    }

    try {
      final ob = await widget.repository.getObligationById(widget.obligationId);
      if (!mounted) return;
      setState(() {
        _obligation = ob;
        _isLoadingObligation = false;
        _errorMessage = null;
      });

      if (_isAuthenticated && widget.attachmentRepository != null) {
        _loadAttachments();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoadingObligation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Falha ao carregar detalhes da obrigação: $e';
        _isLoadingObligation = false;
      });
    }
  }

  Future<void> _loadAttachments() async {
    if (widget.attachmentRepository == null) return;
    if (!_isAuthenticated) return;

    setState(() {
      _isLoadingAttachments = true;
      _attachmentErrorMessage = null;
    });

    try {
      final items = await widget.attachmentRepository!.getAttachments(widget.obligationId);
      if (!mounted) return;
      setState(() {
        _attachments = items;
        _isLoadingAttachments = false;
        _attachmentErrorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _attachmentErrorMessage = e.message;
        _isLoadingAttachments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _attachmentErrorMessage = 'Erro ao carregar anexos: $e';
        _isLoadingAttachments = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    await _loadObligation();
    if (_isAuthenticated && widget.attachmentRepository != null) {
      await _loadAttachments();
    }
  }

  Future<void> _handleStatusTransition(ObligationStatus nextStatus) async {
    if (_obligation == null || _isUpdatingStatus) return;

    if (widget.authController != null && !widget.authController!.isAuthenticated) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para alterar o status da obrigação, realize o login.',
      );
      if (!allowed || !mounted) return;
    }

    final isStarting = nextStatus == ObligationStatus.inProgress;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isStarting ? 'Iniciar Obrigação' : 'Concluir Obrigação'),
        content: Text(
          isStarting
              ? 'Confirma o início da obrigação? O status passará para "Em andamento".'
              : 'Atenção: ao concluir esta obrigação, ela não poderá mais retornar a nenhum status anterior nem ser editada. Confirma a conclusão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: Key(isStarting ? 'confirm-start-status' : 'confirm-complete-status'),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isStarting ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            child: Text(isStarting ? 'Iniciar' : 'Concluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final updated = await widget.repository.updateObligationStatus(
        _obligation!.id,
        nextStatus,
      );
      if (!mounted) return;
      setState(() {
        _obligation = updated;
        _isUpdatingStatus = false;
        _hasMutated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == ObligationStatus.completed
                ? 'Obrigação concluída com sucesso!'
                : 'Obrigação iniciada com sucesso!',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isUpdatingStatus = false);
      final errorMsg = e.code == 'INVALID_STATUS_TRANSITION'
          ? 'Transição de status não permitida pelas regras de negócio (RN-008).'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdatingStatus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar status: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _handleUploadAttachment() async {
    if (_obligation == null || _isUploadingAttachment) return;
    if (widget.attachmentRepository == null) return;

    if (widget.authController != null && !widget.authController!.isAuthenticated) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para anexar documentos, realize o login.',
      );
      if (!allowed || !mounted) return;
    }

    final picker = widget.filePickerService ?? DefaultFilePickerService();
    final selected = await picker.pickFile(context: context);
    if (selected == null || !mounted) return;

    // Validação de arquivo vazio
    if (selected.bytes.isEmpty || selected.size == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não é permitido enviar arquivo vazio (0 bytes).'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Validação de limite máximo de 10 MB (10 * 1024 * 1024 bytes)
    const maxSizeBytes = 10 * 1024 * 1024;
    if (selected.size > maxSizeBytes || selected.bytes.length > maxSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O arquivo excede o limite máximo permitido de 10 MB (${selected.size} bytes).'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isUploadingAttachment = true);

    try {
      final uploaded = await widget.attachmentRepository!.uploadAttachment(
        obligationId: _obligation!.id,
        filename: selected.filename,
        bytes: selected.bytes,
        contentType: selected.mimeType,
      );

      if (!mounted) return;

      setState(() {
        _attachments.insert(0, uploaded);
        _obligation = _obligation!.copyWith(
          attachmentCount: _attachments.length,
        );
        _isUploadingAttachment = false;
        _hasMutated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Documento "${uploaded.name}" anexado com sucesso!'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAttachment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao enviar anexo: ${e.message}'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAttachment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar anexo: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _handleDownloadAttachment(Attachment attachment) async {
    if (widget.attachmentRepository == null) return;

    if (widget.authController != null && !widget.authController!.isAuthenticated) {
      final allowed = await requireAuth(
        context,
        authController: widget.authController!,
        reason: 'Para baixar anexos, realize o login.',
      );
      if (!allowed || !mounted) return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Baixando "${attachment.name}"...')),
      );

      final file = await widget.attachmentRepository!.downloadAttachment(attachment.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Arquivo "${file.filename.isNotEmpty ? file.filename : attachment.name}" baixado com sucesso (${file.bytes.length} bytes)!',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar anexo: ${e.message}'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar anexo: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
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
      _refreshAll();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '—';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
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

  IconData _getAttachmentIcon(String contentType) {
    if (contentType.contains('pdf')) {
      return Icons.picture_as_pdf_outlined;
    } else if (contentType.contains('image')) {
      return Icons.image_outlined;
    } else if (contentType.contains('sheet') || contentType.contains('excel')) {
      return Icons.table_chart_outlined;
    } else if (contentType.contains('xml')) {
      return Icons.code_outlined;
    }
    return Icons.insert_drive_file_outlined;
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
              onPressed: _refreshAll,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingObligation && _obligation == null) {
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
      onRefresh: _refreshAll,
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
                if (_isAuthenticated || obligation.status == ObligationStatus.completed) ...[
                  const SizedBox(height: 16),
                  _buildStatusTransitionSection(obligation),
                ],
                const SizedBox(height: 16),
                _buildDetailsCard(obligation),
                if (_isAuthenticated) ...[
                  const SizedBox(height: 16),
                  _buildAttachmentsCard(obligation),
                ],
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

  Widget _buildStatusTransitionSection(Obligation obligation) {
    if (!_isAuthenticated && obligation.status != ObligationStatus.completed) {
      return const SizedBox.shrink();
    }

    if (_isUpdatingStatus) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Atualizando status da obrigação...'),
            ],
          ),
        ),
      );
    }

    if (obligation.status == ObligationStatus.pending) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDBEAFE)),
        ),
        color: const Color(0xFFEFF6FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Esta obrigação está pendente de início.',
                  style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              if (_isAuthenticated)
                ElevatedButton.icon(
                  key: const Key('obligation-detail-start-action'),
                  onPressed: () => _handleStatusTransition(ObligationStatus.inProgress),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (obligation.status == ObligationStatus.inProgress) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDCFCE7)),
        ),
        color: const Color(0xFFF0FDF4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.autorenew, color: Color(0xFF16A34A)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Obrigação em andamento.',
                  style: TextStyle(color: Color(0xFF14532D), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              if (_isAuthenticated)
                ElevatedButton.icon(
                  key: const Key('obligation-detail-complete-action'),
                  onPressed: () => _handleStatusTransition(ObligationStatus.completed),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Concluir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Status COMPLETED (RN-009)
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF86EFAC)),
      ),
      color: const Color(0xFFF0FDF4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF16A34A), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Obrigação Concluída com Sucesso',
                    style: TextStyle(
                      color: Color(0xFF14532D),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    obligation.completedAt != null
                        ? 'Finalizada em ${_formatDateTime(obligation.completedAt)}. Obrigações concluídas são permanentes e não aceitam novas alterações.'
                        : 'Obrigações concluídas são permanentes e não aceitam novas alterações (RN-009).',
                    style: const TextStyle(color: Color(0xFF166534), fontSize: 12),
                  ),
                ],
              ),
            ),
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
              value: _formatDateTime(obligation.createdAt),
            ),
            if (obligation.completedAt != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                icon: Icons.check_circle_outline,
                label: 'Data de Conclusão',
                value: _formatDateTime(obligation.completedAt),
                valueColor: const Color(0xFF16A34A),
              ),
            ],
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.attach_file,
              label: 'Total de Anexos',
              value: '${obligation.attachmentCount} anexos registrados no servidor',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsCard(Obligation obligation) {
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
            Row(
              children: [
                const Icon(Icons.attach_file, size: 20, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Documentos Anexados (${_isAuthenticated ? _attachments.length : obligation.attachmentCount})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (_isAuthenticated && widget.attachmentRepository != null)
                  ElevatedButton.icon(
                    key: const Key('obligation-detail-add-attachment-button'),
                    onPressed: _isUploadingAttachment ? null : _handleUploadAttachment,
                    icon: _isUploadingAttachment
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload_file, size: 16),
                    label: Text(_isUploadingAttachment ? 'Enviando...' : 'Anexar Arquivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isAuthenticated) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Faça login para listar, baixar ou anexar novos documentos.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.authController != null) {
                          requireAuth(
                            context,
                            authController: widget.authController!,
                            reason: 'Para acessar documentos, realize o login.',
                          );
                        }
                      },
                      child: const Text('Fazer Login'),
                    ),
                  ],
                ),
              ),
            ] else if (_isLoadingAttachments) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_attachmentErrorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _attachmentErrorMessage!,
                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadAttachments,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ] else if (_attachments.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_outlined, size: 40, color: Color(0xFF94A3B8)),
                      SizedBox(height: 8),
                      Text(
                        'Nenhum documento anexado a esta obrigação.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attachments.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final att = _attachments[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAttachmentIcon(att.contentType),
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      att.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      '${att.formattedSize} • Enviado em ${_formatDateTime(att.uploadedAt)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download_rounded, color: Color(0xFF2563EB)),
                      tooltip: 'Baixar arquivo',
                      onPressed: () => _handleDownloadAttachment(att),
                    ),
                  );
                },
              ),
            ],
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
