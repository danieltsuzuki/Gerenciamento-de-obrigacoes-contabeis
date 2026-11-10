import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../controllers/auth_session_controller.dart';
import '../pages/login_page.dart';

Future<bool> requireAuth(
  BuildContext context, {
  required AuthSessionController authController,
  String reason = 'Esta operação requer autenticação prévia.',
}) async {
  if (authController.isAuthenticated) {
    return true;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(reason),
      duration: const Duration(seconds: 2),
    ),
  );

  final loggedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      settings: const RouteSettings(name: AppRoutes.login),
      builder: (_) => LoginPage(controller: authController),
    ),
  );

  return loggedIn == true || authController.isAuthenticated;
}

