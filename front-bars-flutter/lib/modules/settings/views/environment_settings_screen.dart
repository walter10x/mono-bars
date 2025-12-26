import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/environment_config.dart';

/// PANTALLA DE CONFIGURACIÓN DE ENTORNO
/// 
/// ¿DÓNDE SE ENCUENTRA ESTA PANTALLA?
/// - Dentro del menú de usuario (perfil)
/// - O como botón flotante en modo DEBUG
///
/// ¿QUÉ HACE?
/// - Muestra el entorno actual (Local o Producción)
/// - Permite cambiar entre entornos con un switch
/// - Guarda la preferencia automáticamente
/// - Muestra la URL actual del backend
///
/// ¿CÓMO FUNCIONA?
/// 1. Lee el entorno actual de Riverpod
/// 2. Muestra un Switch para cambiar
/// 3. Al cambiar, guarda en SharedPreferences
/// 4. La app usa automáticamente la nueva URL

class EnvironmentSettingsScreen extends ConsumerWidget {
  const EnvironmentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lee el entorno actual (local o producción)
    final currentEnvironment = ref.watch(environmentProvider);
    final environmentNotifier = ref.read(environmentProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Entorno'),
        backgroundColor: const Color(0xFF1e3a5f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card informativo
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '¿Qué es esto?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cambia entre el backend LOCAL (tu PC) y PRODUCCIÓN (Railway) '
                      'sin editar código. Útil para pruebas sin afectar la base de datos real.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Entorno Actual
            Text(
              'Entorno Actual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Switch para cambiar entorno
            Card(
              elevation: 2,
              child: SwitchListTile(
                title: Text(
                  currentEnvironment == AppEnvironment.production
                      ? '🚀 Producción (Railway)'
                      : '🏠 Local (Tu PC)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  environmentNotifier.currentBaseUrl,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
                value: currentEnvironment == AppEnvironment.production,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.orange,
                onChanged: (bool value) async {
                  // Cambia el entorno
                  final newEnvironment = value 
                      ? AppEnvironment.production 
                      : AppEnvironment.local;
                  
                  await environmentNotifier.setEnvironment(newEnvironment);
                  
                  // Muestra un mensaje de confirmación
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Entorno cambiado a: ${EnvironmentConfig.getEnvironmentName(newEnvironment)}'
                        ),
                        backgroundColor: value ? Colors.green : Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            Card(
              color: currentEnvironment == AppEnvironment.production
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          currentEnvironment == AppEnvironment.production
                              ? Icons.cloud
                              : Icons.computer,
                          color: currentEnvironment == AppEnvironment.production
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentEnvironment == AppEnvironment.production
                                ? 'Modo Producción'
                                : 'Modo Local',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentEnvironment == AppEnvironment.production
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentEnvironment == AppEnvironment.production
                          ? '✅ Conectado a Railway\n'
                            '✅ Base de datos: MongoDB Atlas\n'
                            '✅ Los cambios son permanentes'
                          : '✅ Conectado a tu PC\n'
                            '✅ Base de datos: Local\n'
                            '✅ Los cambios NO afectan producción',
                      style: TextStyle(
                        fontSize: 14,
                        color: currentEnvironment == AppEnvironment.production
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instrucciones
            if (currentEnvironment == AppEnvironment.local) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Recuerda',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Tu backend debe estar corriendo: npm run start:dev\n'
                        '2. Tu PC y móvil deben estar en la misma red WiFi\n'
                        '3. Actualiza la IP en environment_config.dart si cambias de red',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// BOTÓN FLOTANTE PARA DESARROLLO (Solo visible en DEBUG)
/// 
/// ¿DÓNDE SE USA?
/// - En las pantallas principales durante desarrollo
/// - NO aparece en builds de producción (release)
///
/// ¿QUÉ HACE?
/// - Muestra un botón flotante para acceso rápido
/// - Al tocarlo, abre la pantalla de configuración
/// 
/// ¿CÓMO AÑADIRLO A UNA PANTALLA?
/// floatingActionButton: const EnvironmentDebugButton()
class EnvironmentDebugButton extends ConsumerWidget {
  const EnvironmentDebugButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo mostrar en modo DEBUG
    if (!const bool.fromEnvironment('dart.vm.product')) {
      final currentEnvironment = ref.watch(environmentProvider);
      
      return FloatingActionButton(
        mini: true,
        backgroundColor: currentEnvironment == AppEnvironment.production
            ? Colors.green
            : Colors.orange,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EnvironmentSettingsScreen(),
            ),
          );
        },
        child: Icon(
          currentEnvironment == AppEnvironment.production
              ? Icons.cloud
              : Icons.computer,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
