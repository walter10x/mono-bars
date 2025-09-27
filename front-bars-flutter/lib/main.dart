import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'core/storage/secure_storage_service.dart';

void main() async {
  // Asegurar que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Crear la instancia del servicio de almacenamiento
  final storageService = SecureStorageService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        // Sobrescribir el provider de almacenamiento con la instancia real
        secureStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const BarApp(),
    ),
  );
}

class BarApp extends ConsumerWidget {
  const BarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Bar Management',
      debugShowCheckedModeBanner: false,
      
      // Configuración del tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Configuración de localización (español)
      locale: const Locale('es', 'ES'),
      
      // Configuración del router
      routerConfig: router,
      
      // Builder para manejar errores globales y configuración adicional
      builder: (context, child) {
        // Configurar el manejo de errores de widgets
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Algo salió mal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Ha ocurrido un error inesperado. Por favor, reinicia la aplicación.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          details.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}
