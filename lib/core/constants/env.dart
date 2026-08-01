enum AppEnv { dev, prod }

class Env {
  // State
  static const String _env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  // Constructor
  static AppEnv get current {
    switch (_env) {
      case 'prod':
        return AppEnv.prod;
      case 'dev':
      default:
        return AppEnv.dev;
    }
  }

  static const bool apiSecure = bool.fromEnvironment(
    'API_SECURE',
    defaultValue: false,
  );

  // Getters
  static bool get isDev => current == AppEnv.dev;

  static bool get isProd => current == AppEnv.prod;
}
