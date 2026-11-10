import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('deve inicializar com valores padrão', () {
      AppConfig.initialize();
      final config = AppConfig.instance;

      expect(config.environment, Environment.dev);
      expect(config.isDevelopment, isTrue);
      expect(config.isProduction, isFalse);
      expect(config.apiBaseUrl, isNotEmpty);
    });

    test('deve permitir customizar ambiente e base URL', () {
      AppConfig.initialize(
        environment: Environment.prod,
        apiBaseUrl: 'https://api.contabilidade.com.br',
        connectTimeout: const Duration(seconds: 30),
      );
      final config = AppConfig.instance;

      expect(config.environment, Environment.prod);
      expect(config.isProduction, isTrue);
      expect(config.isDevelopment, isFalse);
      expect(config.apiBaseUrl, 'https://api.contabilidade.com.br');
      expect(config.connectTimeout, const Duration(seconds: 30));
    });
  });
}
