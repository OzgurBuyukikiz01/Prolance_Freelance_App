/// Flutter `--dart-define=API_BASE_URL=http://localhost:3000` when API is running.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get isConfigured => baseUrl.isNotEmpty;
}
