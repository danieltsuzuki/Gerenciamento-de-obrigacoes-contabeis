import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_session_controller.dart';
import '../pages/login_page.dart';

Future<bool> requireAuth(
  BuildContext context, {
  required AuthSessionController authController,
  String reason = 'Para realizar alterações cadastrais com segurança, conecte-se com sua conta corporativa.',
}) async {
  if (authController.isAuthenticated) {
    return true;
  }

  final shouldProceedToLogin = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      key: const Key('auth-guard-dialog'),
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.brandYellow.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_person_outlined,
          size: 32,
          color: AppTheme.brandYellow,
        ),
      ),
      title: const Text(
        'Autenticação Necessária',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        reason,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          key: const Key('auth-guard-cancel-button'),
          onPressed: () => Navigator.of(dialogCtx).pop(false),
          child: const Text('Continuar navegando'),
        ),
        ElevatedButton.icon(
          key: const Key('auth-guard-login-button'),
          onPressed: () => Navigator.of(dialogCtx).pop(true),
          icon: const Icon(Icons.login, size: 18),
          label: const Text('Fazer Login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.brandYellow,
            foregroundColor: AppTheme.primaryNavy,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  if (shouldProceedToLogin != true || !context.mounted) {
    return false;
  }

  final loggedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      settings: const RouteSettings(name: AppRoutes.login),
      builder: (_) => LoginPage(controller: authController),
    ),
  );

  return loggedIn == true || authController.isAuthenticated;
}
