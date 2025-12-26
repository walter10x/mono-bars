import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

// Color primario de la app (ámbar/naranja)
const Color _primaryColor = Color(0xFFFFA500);

/// Pantalla de selección de rol para usuarios nuevos de Google
/// Se muestra después del primer login con Google
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _isLoading = false;
  String? _selectedRole;

  Future<void> _selectRole(String role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        context.go('/login');
        return;
      }

      // Llamar al backend para actualizar el rol
      final authService = ref.read(authServiceProvider);
      final result = await authService.updateUserRole(user.id, role);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        },
        (updatedUser) {
          // Actualizar el usuario en el estado
          ref.read(authControllerProvider.notifier).updateUser(updatedUser);
          
          // Navegar al dashboard correspondiente
          if (role == 'owner') {
            context.go('/owner/dashboard');
          } else {
            context.go('/client/home');
          }
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF1A2332),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Título
                const Text(
                  '¡Bienvenido a TourBar!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  '¿Cómo vas a usar la app?',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Opción Cliente
                _buildRoleCard(
                  role: 'client',
                  icon: Icons.explore_outlined,
                  title: 'Buscar bares',
                  subtitle: 'Descubre los mejores bares cerca de ti',
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 20),
                
                // Opción Owner
                _buildRoleCard(
                  role: 'owner',
                  icon: Icons.store_outlined,
                  title: 'Tengo un bar',
                  subtitle: 'Gestiona tu bar y llega a más clientes',
                  color: _primaryColor,
                ),
                
                const Spacer(flex: 2),
                
                // Indicador de carga
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    final isDisabled = _isLoading && !isSelected;

    return GestureDetector(
      onTap: isDisabled ? null : () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          gradient: LinearGradient(
            colors: isSelected
                ? [color.withOpacity(0.2), color.withOpacity(0.1)]
                : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected && _isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
