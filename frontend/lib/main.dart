import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa configuração de ambiente (permite sobrescrita via --dart-define=API_URL=...)
  AppConfig.initialize();

  final apiClient = ApiClient();

  runApp(PlayerContabilidadeApp(apiClient: apiClient));
}

class PlayerContabilidadeApp extends StatelessWidget {
  final ApiClient apiClient;

  const PlayerContabilidadeApp({
    super.key,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player Contabilidade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings,
        apiClient: apiClient,
      ),
    );
  }
}
