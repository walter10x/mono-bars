import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PROPÓSITO: Gestionar el entorno de la aplicación (Local vs Producción)
/// 
/// ¿POR QUÉ EXISTE ESTE ARCHIVO?
/// - Permite cambiar entre backend local y producción SIN editar código
/// - Guarda la preferencia del usuario en el dispositivo
/// - Centraliza la configuración de URLs
///
/// ¿DÓNDE SE USA?
/// - En app_constants.dart para determinar la baseUrl
/// - En la pantalla de configuración para cambiar el entorno
///
/// ¿CÓMO FUNCIONA?
/// - SharedPreferences guarda la preferencia localmente
/// - Riverpod notifica cambios a toda la app
/// - La app se puede reiniciar automáticamente con el nuevo entorno

enum AppEnvironment {
  local,      // Backend corriendo en tu PC (para desarrollo)
  production, // Backend en Railway (para producción)
}

/// Configuración de URLs por entorno
class EnvironmentConfig {
  // URL del backend LOCAL
  // IMPORTANTE: Esta es la IP de tu PC en la red local
  // Obtenida con 'ipconfig' en PowerShell
  // IPv4 Address: 192.168.56.1
  static const String localBaseUrl = 'http://192.168.56.1:3000';
  
  // URL del backend en PRODUCCIÓN (Railway)
  static const String productionBaseUrl = 'https://mono-bars-production.up.railway.app';

  /// Obtiene la URL correspondiente al entorno
  static String getBaseUrl(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.local:
        return localBaseUrl;
      case AppEnvironment.production:
        return productionBaseUrl;
    }
  }

  /// Obtiene el nombre legible del entorno
  static String getEnvironmentName(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.local:
        return 'Local (Tu PC)';
      case AppEnvironment.production:
        return 'Producción (Railway)';
    }
  }
}

/// PROVIDER: Gestiona el estado del entorno actual
/// 
/// ¿QUÉ ES UN PROVIDER?
/// - Es como una "caja mágica" que guarda un valor
/// - Cualquier widget puede leer o cambiar este valor
/// - Cuando cambia, todos los widgets que lo usan se actualizan
///
/// ¿POR QUÉ StateNotifier?
/// - Permite cambiar el estado de forma controlada
/// - Notifica automáticamente a los listeners cuando cambia
class EnvironmentNotifier extends StateNotifier<AppEnvironment> {
  static const String _storageKey = 'app_environment';
  final SharedPreferences _prefs;

  /// Constructor: Lee la preferencia guardada o usa producción por defecto
  EnvironmentNotifier(this._prefs) 
      : super(_getInitialEnvironment(_prefs));

  /// Lee el entorno guardado en el dispositivo
  static AppEnvironment _getInitialEnvironment(SharedPreferences prefs) {
    final savedEnv = prefs.getString(_storageKey);
    if (savedEnv == 'local') {
      return AppEnvironment.local;
    }
    return AppEnvironment.production; // Por defecto: producción
  }

  /// MÉTODO PRINCIPAL: Cambia el entorno
  /// 
  /// ¿CÓMO SE USA?
  /// ref.read(environmentProvider.notifier).setEnvironment(AppEnvironment.local);
  /// 
  /// ¿QUÉ HACE?
  /// 1. Guarda la nueva preferencia en el dispositivo
  /// 2. Actualiza el estado (automaticamente notifica a los widgets)
  Future<void> setEnvironment(AppEnvironment environment) async {
    await _prefs.setString(_storageKey, environment.name);
    state = environment; // Esto dispara la actualización en toda la app
  }

  /// Obtiene la URL del entorno actual
  String get currentBaseUrl => EnvironmentConfig.getBaseUrl(state);

  /// Obtiene el nombre del entorno actual
  String get currentEnvironmentName => EnvironmentConfig.getEnvironmentName(state);
}

/// PROVIDER GLOBAL: Permite acceder al entorno desde cualquier parte
/// 
/// ¿CÓMO LEER EL ENTORNO?
/// final env = ref.watch(environmentProvider);
/// 
/// ¿CÓMO CAMBIAR EL ENTORNO?
/// ref.read(environmentProvider.notifier).setEnvironment(AppEnvironment.local);
final environmentProvider = StateNotifierProvider<EnvironmentNotifier, AppEnvironment>((ref) {
  // Requiere SharedPreferences inicializado
  throw UnimplementedError('environmentProvider debe inicializarse en main.dart');
});

/// Provider para obtener directamente la baseUrl actual
/// 
/// ¿CÓMO SE USA?
/// final baseUrl = ref.watch(baseUrlProvider);
final baseUrlProvider = Provider<String>((ref) {
  final environment = ref.watch(environmentProvider);
  return EnvironmentConfig.getBaseUrl(environment);
});
