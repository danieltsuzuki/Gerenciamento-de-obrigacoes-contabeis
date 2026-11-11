import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/cnpj_validator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../../auth/presentation/widgets/auth_guard.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import 'company_form_page.dart';

class CompanyDetailPage extends StatefulWidget {
  final CompanyRepository repository;
  final int companyId;
  final Company? initialCompany;
  final AuthSessionController? authController;

  const CompanyDetailPage({
    super.key,
    required this.repository,
    required this.companyId,
    this.initialCompany,
    this.authController,
  });

  @override
  State<CompanyDetailPage> createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage> {
  Company? _company;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMutated = false;

  bool get _isAuthenticated => widget.authController?.isAuthenticated ?? false;

  @override
  void initState() {
    super.initState();
    _company = widget.initialCompany;
    widget.authController?.addListener(_onAuthChanged);
    if (_company == null) {
      _loadCompany();
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

  Future<void> _loadCompany() async {
    if (_company == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final comp = await widget.repository.getCompanyById(widget.companyId);
      if (!mounted) return;
      setState(() {
        _company = comp;
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
        _errorMessage = 'Falha ao carregar detalhes da empresa: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openEdit() async {
    if (_company == null) return;

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
          company: _company,
        ),
      ),
    );

    if (updated == true && mounted) {
      _hasMutated = true;
      _loadCompany();
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
          title: const Text('Detalhes da Empresa'),
          actions: [
            if (_company != null && _isAuthenticated)
              IconButton(
                key: const Key('company-detail-edit-button'),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar empresa',
                onPressed: _openEdit,
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recarregar',
              onPressed: _loadCompany,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _company == null) {
      return const LoadingStateView(message: 'Carregando detalhes da empresa...');
    }

    if (_errorMessage != null && _company == null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadCompany,
      );
    }

    final company = _company;
    if (company == null) {
      return const Center(child: Text('Empresa não encontrada.'));
    }

    final formattedCnpj = CnpjValidator.format(company.cnpj);

    return RefreshIndicator(
      onRefresh: _loadCompany,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(company),
                const SizedBox(height: 16),
                _buildDetailsCard(company, formattedCnpj),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const Key('company-view-obligations-button'),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.obligations,
                      arguments: {'companyId': company.id},
                    );
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Ver Obrigações desta Empresa'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                if (_isAuthenticated) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    key: const Key('company-detail-edit-action'),
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar Empresa'),
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

  Widget _buildHeaderCard(Company company) {
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
              backgroundColor: company.active
                  ? const Color(0xFFDBEAFE)
                  : const Color(0xFFF1F5F9),
              child: Icon(
                Icons.business,
                size: 36,
                color: company.active
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (company.tradeName != null &&
                      company.tradeName!.isNotEmpty &&
                      company.tradeName != company.legalName) ...[
                    const SizedBox(height: 4),
                    Text(
                      company.legalName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      company.active ? 'Ativa' : 'Inativa',
                      style: TextStyle(
                        color: company.active
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: company.active
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

  Widget _buildDetailsCard(Company company, String formattedCnpj) {
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
              value: '#${company.id}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.business,
              label: 'Razão Social',
              value: company.legalName,
            ),
            if (company.tradeName != null && company.tradeName!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailRow(
                icon: Icons.storefront_outlined,
                label: 'Nome Fantasia',
                value: company.tradeName!,
              ),
            ],
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.badge_outlined,
              label: 'CNPJ',
              value: formattedCnpj,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: company.active
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              label: 'Situação Operacional',
              value: company.active
                  ? 'Ativa — Pode ser vinculada a novas obrigações fiscais'
                  : 'Inativa — Não recebe novas obrigações fiscais (RN-006)',
              valueColor: company.active
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

