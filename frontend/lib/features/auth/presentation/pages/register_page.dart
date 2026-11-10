import 'package:flutter/material.dart';
import '../controllers/auth_session_controller.dart';

class RegisterPage extends StatefulWidget {
  final AuthSessionController controller;

  const RegisterPage({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.controller.clearErrorMessage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta cadastrada e autenticada com sucesso!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isLoading = widget.controller.isLoading;
        final errorMessage = widget.controller.errorMessage;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cadastro de Responsável'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'Criar Nova Conta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Preencha os dados do responsável contábil.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (errorMessage != null) ...[
                        Container(
                          key: const Key('register-error-banner'),
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
                                  errorMessage,
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
                        key: const Key('register-name-input'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo *',
                          hintText: 'Ex.: Carlos Silva',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O nome é obrigatório.';
                          }
                          if (value.trim().length > 255) {
                            return 'O nome não pode exceder 255 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('register-email-input'),
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-mail *',
                          hintText: 'carlos@empresa.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O e-mail é obrigatório.';
                          }
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Informe um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('register-password-input'),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha (mínimo 6 caracteres) *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
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
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'A senha é obrigatória.';
                          }
                          if (value.length < 6) {
                            return 'A senha deve possuir no mínimo 6 caracteres.';
                          }
                          if (value.length > 100) {
                            return 'A senha não pode exceder 100 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('register-confirm-password-input'),
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Senha *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_reset),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'A confirmação de senha é obrigatória.';
                          }
                          if (value != _passwordController.text) {
                            return 'As senhas informadas não conferem.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        key: const Key('register-submit-button'),
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Cadastrar e Entrar'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        key: const Key('register-back-to-login-button'),
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Já possui conta? Voltar ao login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
