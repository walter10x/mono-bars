import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/auth_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

/// Pantalla principal del perfil de usuario
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) {
      // Si no hay usuario, redirigir al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: Column(
          children: [
            // Header con avatar e información
            ProfileHeader(
              user: user,
              onEditTap: () => context.push('/profile/edit'),
            ),

            const SizedBox(height: 16),

            // Lista de opciones
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Editar Perfil
                  ProfileMenuItem(
                    icon: Icons.edit_rounded,
                    title: 'Editar Perfil',
                    subtitle: 'Actualiza tu información personal',
                    onTap: () => context.push('/profile/edit'),
                    iconColor: const Color(0xFFFFA500),
                  ),

                  // Cambiar Contraseña
                  ProfileMenuItem(
                    icon: Icons.lock_rounded,
                    title: 'Cambiar Contraseña',
                    subtitle: 'Mantén tu cuenta segura',
                    onTap: () => context.push('/profile/change-password'),
                    iconColor: const Color(0xFFFFB84D),
                  ),

                  // Estadísticas (solo para owners y admins)
                  if (user.role == 'owner' || user.role == 'admin')
                    ProfileMenuItem(
                      icon: Icons.bar_chart_rounded,
                      title: 'Estadísticas',
                      subtitle: 'Métricas y análisis',
                      onTap: () {
                        // TODO: Navegar a estadísticas
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente disponible'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      iconColor: const Color(0xFFF59E0B),
                    ),

                  // Configuración
                  ProfileMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'Configuración',
                    subtitle: 'Preferencias de la app',
                    onTap: () {
                      // TODO: Navegar a configuración
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente disponible'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    iconColor: Colors.white.withOpacity(0.5),
                  ),

                  const SizedBox(height: 16),

                  // Cerrar Sesión
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context, ref),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500).withOpacity(0.15),
                          foregroundColor: const Color(0xFFFFA500),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: const Color(0xFFFFA500).withOpacity(0.3)),
                          ),
                       ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Versión de la app
                  Center(
                    child: Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA500).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFFA500),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500),
              foregroundColor: const Color(0xFF0F0F1E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFA500),
          ),
        ),
      );

      // Ejecutar logout
      await ref.read(authControllerProvider.notifier).logout();

      // Cerrar loading y navegar
      if (context.mounted) {
        Navigator.of(context).pop();
        context.go('/login');
      }
    }
  }
}
