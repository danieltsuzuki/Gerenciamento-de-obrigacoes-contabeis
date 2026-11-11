import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/create_responsible_request.dart';
import '../../data/models/update_responsible_request.dart';
import '../../domain/entities/responsible.dart';
import '../../domain/repositories/responsible_repository.dart';

class ResponsibleFormPage extends StatefulWidget {
  final ResponsibleRepository repository;
  final Responsible? responsible;

  const ResponsibleFormPage({
    super.key,
    required this.repository,
    this.responsible,
  });

  bool get isEditing => responsible != null;

  @override
  State<ResponsibleFormPage> createState() => _ResponsibleFormPageState();
}

class _ResponsibleFormPageState extends State<ResponsibleFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late bool _active;

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _serverErrorMessage;

  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  @override
  void initState() {
    super.initState();
    final r = widget.responsible;
    _nameController = TextEditingController(text: r?.name ?? '');
    _emailController = TextEditingController(text: r?.email ?? '');
    _passwordController = TextEditingController();
    _active = r?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    try {
      if (widget.isEditing) {
        final request = UpdateResponsibleRequest(
          name: name,
          email: email,
          active: _active,
        );
        await widget.repository.updateResponsible(widget.responsible!.id, request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Responsável atualizado com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      } else {
        final request = CreateResponsibleRequest(
          name: name,
          email: email,
          password: _passwordController.text,
          active: _active,
        );
        await widget.repository.createResponsible(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Responsável cadastrado com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'DUPLICATE_EMAIL' || e.statusCode == 409) {
          _serverErrorMessage = 'Este e-mail já está em uso por outro responsável (RN-003).';
        } else {
          _serverErrorMessage = e.message;
        }
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrorMessage = 'Ocorreu um erro ao salvar o responsável: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar Responsável' : 'Novo Responsável';

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
                    key: const Key('responsible-name-input'),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo *',
                      hintText: 'Ex.: Carlos Eduardo Silva',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O nome completo é obrigatório.';
                      }
                      if (value.trim().length > 255) {
                        return 'O nome não pode exceder 255 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('responsible-email-input'),
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail Corporativo *',
                      hintText: 'exemplo@empresa.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: widget.isEditing
                        ? TextInputAction.done
                        : TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O e-mail é obrigatório.';
                      }
                      if (!_emailRegExp.hasMatch(value.trim())) {
                        return 'Informe um e-mail válido (ex.: usuario@empresa.com).';
                      }
                      if (value.trim().length > 255) {
                        return 'O e-mail não pode exceder 255 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!widget.isEditing) ...[
                    TextFormField(
                      key: const Key('responsible-password-input'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha Inicial *',
                        hintText: 'Mínimo de 6 caracteres',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          key: const Key('responsible-password-toggle'),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'A senha inicial é obrigatória para cadastro.';
                        }
                        if (value.length < 6) {
                          return 'A senha deve possuir no mínimo 6 caracteres.';
                        }
                        if (value.length > 100) {
                          return 'A senha deve possuir no máximo 100 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
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
                              'A senha deste responsável é confidencial e não pode ser visualizada ou alterada neste formulário.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.isEditing) ...[
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: SwitchListTile(
                        key: const Key('responsible-active-switch'),
                        title: const Text(
                          'Situação Cadastral',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _active
                              ? 'Responsável Ativo (pode ser atribuído a novas obrigações)'
                              : 'Responsável Inativo (não poderá ser atribuído a novas obrigações — RN-005)',
                          style: TextStyle(
                            fontSize: 12,
                            color: _active
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        value: _active,
                        activeColor: const Color(0xFF16A34A),
                        onChanged: (val) {
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
                          key: const Key('responsible-cancel-button'),
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
                          key: const Key('responsible-submit-button'),
                          onPressed: _isSubmitting ? null : _submit,
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
                                      : 'Cadastrar Responsável',
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

