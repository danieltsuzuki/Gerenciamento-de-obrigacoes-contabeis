import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/cnpj_validator.dart';
import '../../data/models/create_company_request.dart';
import '../../data/models/update_company_request.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyFormPage extends StatefulWidget {
  final CompanyRepository repository;
  final Company? company;

  const CompanyFormPage({
    super.key,
    required this.repository,
    this.company,
  });

  bool get isEditing => company != null;

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _legalNameController;
  late final TextEditingController _tradeNameController;
  late final TextEditingController _cnpjController;
  late bool _active;

  bool _isSubmitting = false;
  String? _serverErrorMessage;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _legalNameController = TextEditingController(text: c?.legalName ?? '');
    _tradeNameController = TextEditingController(text: c?.tradeName ?? '');
    _cnpjController = TextEditingController(
      text: c != null ? CnpjValidator.format(c.cnpj) : '',
    );
    _active = c?.active ?? true;
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _tradeNameController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _serverErrorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final strippedCnpj = CnpjValidator.strip(_cnpjController.text);
    final legalName = _legalNameController.text.trim();
    final tradeName = _tradeNameController.text.trim().isEmpty
        ? null
        : _tradeNameController.text.trim();

    try {
      if (widget.isEditing) {
        final request = UpdateCompanyRequest(
          legalName: legalName,
          tradeName: tradeName,
          cnpj: strippedCnpj,
          active: _active,
        );
        await widget.repository.updateCompany(widget.company!.id, request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empresa atualizada com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      } else {
        final request = CreateCompanyRequest(
          legalName: legalName,
          tradeName: tradeName,
          cnpj: strippedCnpj,
          active: _active,
        );
        await widget.repository.createCompany(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empresa cadastrada com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'DUPLICATE_CNPJ' || e.statusCode == 409) {
          _serverErrorMessage = 'Este CNPJ já está cadastrado para outra empresa (RN-002).';
        } else {
          _serverErrorMessage = e.message;
        }
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrorMessage = 'Ocorreu um erro ao salvar a empresa: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar Empresa' : 'Nova Empresa';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_serverErrorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _serverErrorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    key: const Key('company-legal-name-input'),
                    controller: _legalNameController,
                    decoration: const InputDecoration(
                      labelText: 'Razão Social *',
                      hintText: 'Ex.: Petróleo Brasileiro S.A.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A Razão Social é obrigatória.';
                      }
                      if (value.trim().length > 255) {
                        return 'A Razão Social não pode exceder 255 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('company-trade-name-input'),
                    controller: _tradeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Fantasia',
                      hintText: 'Ex.: Petrobras (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value != null && value.trim().length > 255) {
                        return 'O Nome Fantasia não pode exceder 255 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('company-cnpj-input'),
                    controller: _cnpjController,
                    decoration: const InputDecoration(
                      labelText: 'CNPJ *',
                      hintText: '00.000.000/0000-00 ou 12.ABC.345/01DE-35',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    validator: CnpjValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  if (widget.isEditing) ...[
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: SwitchListTile(
                        key: const Key('company-active-switch'),
                        title: const Text(
                          'Situação Cadastral',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _active
                              ? 'Empresa Ativa (pode ser vinculada a novas obrigações)'
                              : 'Empresa Inativa (não receberá novas obrigações — RN-006)',
                          style: TextStyle(
                            fontSize: 12,
                            color: _active
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        value: _active,
                        activeColor: const Color(0xFF1E3A8A),
                        onChanged: _isSubmitting
                            ? null
                            : (val) {
                                setState(() {
                                  _active = val;
                                });
                              },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('company-cancel-button'),
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          key: const Key('company-save-button'),
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(widget.isEditing ? 'Salvar Alterações' : 'Cadastrar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

