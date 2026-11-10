enum Environment { dev, staging, prod }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final Duration connectTimeout;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
  });

  static AppConfig _instance = const AppConfig(
    environment: Environment.dev,
    apiBaseUrl: String.fromEnvironment(
      'API_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );

  static AppConfig get instance => _instance;

  static void initialize({
    Environment environment = Environment.dev,
    String? apiBaseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
  }) {
    _instance = AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl ??
          const String.fromEnvironment(
            'API_URL',
            defaultValue: 'http://localhost:8080',
          ),
      connectTimeout: connectTimeout,
    );
  }

  bool get isProduction => environment == Environment.prod;
  bool get isDevelopment => environment == Environment.dev;
}
