/// Configurações do ambiente da aplicação.
class AppConfig {
  const AppConfig({required this.appName, required this.baseUrl});

  final String appName;
  final String baseUrl;

  static const development = AppConfig(
    appName: 'NatyApp',
    baseUrl: String.fromEnvironment(
      'API_BASE_URL',
      // No aparelho físico, `adb reverse` encaminha 127.0.0.1:8081
      // para a mesma porta no computador via USB.
      defaultValue: 'http://127.0.0.1:8081',
    ),
  );
}
