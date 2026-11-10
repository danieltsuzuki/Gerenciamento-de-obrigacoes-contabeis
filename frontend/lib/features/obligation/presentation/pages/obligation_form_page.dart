import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../company/domain/entities/company.dart';
import '../../../company/domain/repositories/company_repository.dart';
import '../../../responsible/domain/entities/responsible.dart';
import '../../../responsible/domain/repositories/responsible_repository.dart';
import '../../data/models/create_obligation_request.dart';
import '../../data/models/update_obligation_request.dart';
import '../../domain/entities/obligation.dart';
import '../../domain/repositories/obligation_repository.dart';

class ObligationFormPage extends StatefulWidget {
  final ObligationRepository obligationRepository;
  final CompanyRepository companyRepository;
  final ResponsibleRepository responsibleRepository;
  final Obligation? obligation;

  const ObligationFormPage({
    super.key,
    required this.obligationRepository,
    required this.companyRepository,
    required this.responsibleRepository,
    this.obligation,
  });

  bool get isEditing => obligation != null;

  @override
  State<ObligationFormPage> createState() => _ObligationFormPageState();
}

class _ObligationFormPageState extends State<ObligationFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dueDateController;

  int? _selectedCompanyId;
  int? _selectedResponsibleId;
  DateTime? _selectedDueDate;

  List<Company> _availableCompanies = [];
  List<Responsible> _availableResponsibles = [];

  bool _isLoadingParticipants = false;
  bool _isSubmitting = false;
  String? _serverErrorMessage;

  bool get _isCompleted =>
      widget.isEditing && widget.obligation!.status == ObligationStatus.completed;

  @override
  void initState() {
    super.initState();
    final ob = widget.obligation;
    _titleController = TextEditingController(text: ob?.title ?? '');
    _descriptionController = TextEditingController(text: ob?.description ?? '');

    if (ob != null) {
      _selectedCompanyId = ob.company.id;
      _selectedResponsibleId = ob.responsible.id;
      _selectedDueDate = ob.dueDate;
      _dueDateController = TextEditingController(text: _formatDate(ob.dueDate));
    } else {
      _dueDateController = TextEditingController();
    }

    _loadActiveParticipants();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadActiveParticipants() async {
    setState(() {
      _isLoadingParticipants = true;
    });

    try {
      final companiesFuture = widget.companyRepository.getCompanies(active: true);
      final responsiblesFuture = widget.responsibleRepository.getResponsibles(active: true);

      final results = await Future.wait([companiesFuture, responsiblesFuture]);
      final companiesPage = results[0] as dynamic;
      final responsiblesPage = results[1] as dynamic;

      if (!mounted) return;

      setState(() {
        _availableCompanies = List<Company>.from(companiesPage.content);
        _availableResponsibles = List<Responsible>.from(responsiblesPage.content);

        // Se estiver editando e a empresa/responsável atual não estiver na lista de ativas, inclui para não quebrar a UI
        if (widget.obligation != null) {
          final ob = widget.obligation!;
          if (!_availableCompanies.any((c) => c.id == ob.company.id)) {
            _availableCompanies.add(Company(
              id: ob.company.id,
              legalName: ob.company.name,
              cnpj: '',
              active: false,
            ));
          }
          if (!_availableResponsibles.any((r) => r.id == ob.responsible.id)) {
            _availableResponsibles.add(Responsible(
              id: ob.responsible.id,
              name: ob.responsible.name,
              email: '',
              active: false,
            ));
          }
        }

        _isLoadingParticipants = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingParticipants = false;
        _serverErrorMessage = 'Não foi possível carregar empresas ou responsáveis ativos: $e';
      });
    }
  }

  Future<void> _selectDueDate() async {
    if (_isCompleted) return;

    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      helpText: 'Selecione a data de vencimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_isCompleted) return;

    setState(() {
      _serverErrorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCompanyId == null) {
      setState(() {
        _serverErrorMessage = 'Por favor, selecione a empresa cliente.';
      });
      return;
    }

    if (_selectedResponsibleId == null) {
      setState(() {
        _serverErrorMessage = 'Por favor, selecione o usuário responsável.';
      });
      return;
    }

    if (_selectedDueDate == null) {
      setState(() {
        _serverErrorMessage = 'Por favor, informe a data de vencimento da obrigação.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    final dueDateStr = _formatApiDate(_selectedDueDate!);

    try {
      if (widget.isEditing) {
        final request = UpdateObligationRequest(
          companyId: _selectedCompanyId!,
          responsibleId: _selectedResponsibleId!,
          title: title,
          description: description,
          dueDate: dueDateStr,
        );
        await widget.obligationRepository.updateObligation(widget.obligation!.id, request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigação atualizada com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      } else {
        final request = CreateObligationRequest(
          companyId: _selectedCompanyId!,
          responsibleId: _selectedResponsibleId!,
          title: title,
          description: description,
          dueDate: dueDateStr,
        );
        await widget.obligationRepository.createObligation(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigação cadastrada com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'COMPANY_INACTIVE') {
          _serverErrorMessage = 'A empresa selecionada está inativa e não pode receber novas obrigações (RN-006).';
        } else if (e.code == 'USER_INACTIVE') {
          _serverErrorMessage = 'O responsável selecionado está inativo e não pode ser atribuído (RN-007).';
        } else if (e.code == 'INVALID_STATUS_TRANSITION') {
          _serverErrorMessage = 'Esta obrigação não pode ser alterada porque já foi concluída (RN-009).';
        } else {
          _serverErrorMessage = e.message;
        }
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrorMessage = 'Ocorreu um erro ao salvar a obrigação: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar Obrigação' : 'Nova Obrigação';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoadingParticipants) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                  ],
                  if (_isCompleted) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, color: Color(0xFFB45309)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Esta obrigação está concluída (COMPLETED) e não permite alterações ou reabertura (RN-009).',
                              style: TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
                    key: const Key('obligation-title-input'),
                    controller: _titleController,
                    enabled: !_isCompleted,
                    decoration: const InputDecoration(
                      labelText: 'Título da Obrigação *',
                      hintText: 'Ex.: Declaração de Débitos e Créditos (DCTF)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O título da obrigação é obrigatório.';
                      }
                      if (value.trim().length > 255) {
                        return 'O título não pode exceder 255 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('obligation-description-input'),
                    controller: _descriptionController,
                    enabled: !_isCompleted,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição ou Instruções',
                      hintText: 'Detalhes complementares para execução (opcional)...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const Key('obligation-company-select'),
                    value: _selectedCompanyId,
                    decoration: const InputDecoration(
                      labelText: 'Empresa Cliente *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    items: _availableCompanies.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(
                          c.displayName + (!c.active ? ' (Inativa)' : ''),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _isCompleted
                        ? null
                        : (val) {
                            setState(() {
                              _selectedCompanyId = val;
                            });
                          },
                    validator: (val) {
                      if (val == null) {
                        return 'Selecione a empresa vinculada.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const Key('obligation-responsible-select'),
                    value: _selectedResponsibleId,
                    decoration: const InputDecoration(
                      labelText: 'Responsável Atribuído *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: _availableResponsibles.map((r) {
                      return DropdownMenuItem<int>(
                        value: r.id,
                        child: Text(
                          r.name + (!r.active ? ' (Inativo)' : ''),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _isCompleted
                        ? null
                        : (val) {
                            setState(() {
                              _selectedResponsibleId = val;
                            });
                          },
                    validator: (val) {
                      if (val == null) {
                        return 'Selecione o responsável atribuído.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('obligation-due-date-input'),
                    controller: _dueDateController,
                    readOnly: true,
                    enabled: !_isCompleted,
                    onTap: _selectDueDate,
                    decoration: InputDecoration(
                      labelText: 'Data de Vencimento *',
                      hintText: 'dd/mm/aaaa',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.event_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: _isCompleted ? null : _selectDueDate,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'A data de vencimento é obrigatória.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!widget.isEditing) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Color(0xFF475569)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Toda obrigação recém-cadastrada inicia automaticamente com status Pendente no servidor (RN-008).',
                              style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('obligation-cancel-button'),
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          key: const Key('obligation-submit-button'),
                          onPressed: (_isSubmitting || _isCompleted) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.isEditing
                                      ? 'Salvar Alterações'
                                      : 'Cadastrar Obrigação',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
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
