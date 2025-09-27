/// Configuración de entorno para la aplicación
class Environment {
  // Configuración por defecto (desarrollo)
  static const String _defaultBaseUrl = 'http://localhost:3000/api';
  static const String _defaultAppName = 'Bar Management';
  static const bool _defaultDebugMode = true;

  /// URL base del API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// Nombre de la aplicación
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: _defaultAppName,
  );

  /// Modo debug
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: _defaultDebugMode,
  );

  /// Configuraciones por ambiente
  static bool get isDevelopment => baseUrl.contains('localhost');
  static bool get isProduction => !isDevelopment;

  /// Configuraciones específicas por ambiente
  static Duration get apiTimeout {
    return isDevelopment 
        ? const Duration(seconds: 30)
        : const Duration(seconds: 15);
  }

  static bool get enableLogging {
    return isDevelopment || debugMode;
  }

  /// Método para validar la configuración
  static void validateConfig() {
    assert(baseUrl.isNotEmpty, 'BASE_URL no puede estar vacía');
    assert(appName.isNotEmpty, 'APP_NAME no puede estar vacío');
    
    if (isDevelopment) {
      print('🔧 Ejecutando en modo DESARROLLO');
      print('📡 API Base URL: $baseUrl');
    } else {
      print('🚀 Ejecutando en modo PRODUCCIÓN');
    }
  }
}

/// Configuraciones específicas para diferentes flavors
class FlavorConfig {
  final String name;
  final String baseUrl;
  final String appName;
  final bool debugMode;

  FlavorConfig({
    required this.name,
    required this.baseUrl,
    required this.appName,
    required this.debugMode,
  });

  /// Configuración para desarrollo
  static FlavorConfig get development => FlavorConfig(
    name: 'development',
    baseUrl: 'http://localhost:3000/api',
    appName: 'Bar Management (Dev)',
    debugMode: true,
  );

  /// Configuración para staging/pruebas
  static FlavorConfig get staging => FlavorConfig(
    name: 'staging',
    baseUrl: 'https://staging-api.ejemplo.com/api',
    appName: 'Bar Management (Staging)',
    debugMode: true,
  );

  /// Configuración para producción
  static FlavorConfig get production => FlavorConfig(
    name: 'production',
    baseUrl: 'https://api.ejemplo.com/api',
    appName: 'Bar Management',
    debugMode: false,
  );
}
