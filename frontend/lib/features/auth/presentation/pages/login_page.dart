import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../controllers/auth_session_controller.dart';

class LoginPage extends StatefulWidget {
  final AuthSessionController controller;

  const LoginPage({
    super.key,
    required this.controller,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.controller.clearErrorMessage();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bem-vindo, ${widget.controller.currentUser?.name ?? "Usuário"}!',
          ),
          backgroundColor: const Color(0xFF16A34A),
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
            title: const Text('Identificação de Acesso'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.account_balance,
                          size: 48,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Player Contabilidade',
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
                          'Acesse sua conta para executar operações protegidas.',
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
                          key: const Key('login-error-banner'),
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
                        key: const Key('login-email-input'),
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-mail *',
                          hintText: 'exemplo@empresa.com',
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
                        key: const Key('login-password-input'),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            key: const Key('login-toggle-password-button'),
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'A senha é obrigatória.';
                          }
                          if (value.length < 6) {
                            return 'A senha deve possuir no mínimo 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        key: const Key('login-submit-button'),
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
                            : const Text('Entrar'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        key: const Key('login-to-register-button'),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final registered = await navigator.pushNamed(
                                  AppRoutes.register,
                                );
                                if (registered == true) {
                                  navigator.pop(true);
                                }
                              },
                        child: const Text('Não possui uma conta? Cadastre-se aqui'),
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
