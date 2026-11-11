/// Ambientes disponíveis no ecossistema ShapeFit
enum AppEnvironment {
  dev,
  stage,
  prod,
}

/// Configurações centralizadas por ambiente de execução
class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;
  final bool enableDebugBanner;
  final bool enableVerboseLogging;
  final String? environmentBadge;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    this.enableDebugBanner = true,
    this.enableVerboseLogging = true,
    this.environmentBadge,
  });

  static AppConfig? _current;

  /// Retorna a configuração do ambiente atualmente ativo.
  /// Se nenhuma configuração explícita for definida, resolve automaticamente
  /// através de variáveis de compilação (--dart-define=ENV=dev|stage|prod).
  static AppConfig get current {
    if (_current != null) return _current!;

    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    const customApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

    switch (envString.toLowerCase()) {
      case 'stage':
      case 'staging':
        return stageConfig(customApiUrl.isNotEmpty ? customApiUrl : null);
      case 'prod':
      case 'production':
        return prodConfig(customApiUrl.isNotEmpty ? customApiUrl : null);
      case 'dev':
      default:
        return devConfig(customApiUrl.isNotEmpty ? customApiUrl : null);
    }
  }

  /// Inicializa o singleton com o perfil de ambiente desejado
  static void initialize(AppConfig config) {
    _current = config;
  }

  /// Configuração para Desenvolvimento Local (Dev)
  static AppConfig devConfig([String? apiUrl]) => AppConfig(
        environment: AppEnvironment.dev,
        appName: 'ShapeFit (Dev)',
        // 10.0.2.2 para Android Emulator, localhost para Web/Windows
        apiBaseUrl: apiUrl ?? 'http://10.0.2.2:5000',
        enableDebugBanner: true,
        enableVerboseLogging: true,
        environmentBadge: 'DEV',
      );

  /// Configuração para Homologação / Pré-produção (Stage)
  static AppConfig stageConfig([String? apiUrl]) => AppConfig(
        environment: AppEnvironment.stage,
        appName: 'ShapeFit (Stage)',
        apiBaseUrl: apiUrl ?? 'https://staging-api.shapefit.app',
        enableDebugBanner: true,
        enableVerboseLogging: true,
        environmentBadge: 'STAGE',
      );

  /// Configuração para Produção (Prod)
  static AppConfig prodConfig([String? apiUrl]) => AppConfig(
        environment: AppEnvironment.prod,
        appName: 'ShapeFit',
        apiBaseUrl: apiUrl ?? 'https://api.shapefit.app',
        enableDebugBanner: false,
        enableVerboseLogging: false,
        environmentBadge: null,
      );

  bool get isDevelopment => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.stage;
  bool get isProduction => environment == AppEnvironment.prod;
}
