import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../bars/controllers/bars_controller.dart';
import '../../menus/controllers/menus_controller.dart';
import '../../promotions/controllers/promotions_controller.dart';

/// Pantalla principal del dashboard para propietarios de bares
class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al montar el widget
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadMyBars();
      ref.read(menusControllerProvider.notifier).loadMyMenus();
      ref.read(promotionsControllerProvider.notifier).loadMyPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final barsState = ref.watch(barsControllerProvider);
    final menusState = ref.watch(menusControllerProvider);
    final promotionsState = ref.watch(promotionsControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${user?.fullName ?? "Owner"}!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Panel de Control',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.initials ?? 'O',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Estadísticas rápidas
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navegar a gestión de bares
                          context.go('/owner/bars');
                        },
                        child: _buildStatCard(
                          icon: Icons.storefront,
                          title: 'Mis Bares',
                          value: '${barsState.bars.length}',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navegar a gestión de menús
                          context.go('/owner/menus');
                        },
                        child: _buildStatCard(
                          icon: Icons.restaurant_menu,
                          title: 'Menús',
                          value: '${menusState.menus.length}',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navegar a gestión de promociones
                          context.go('/owner/promotions');
                        },
                        child: _buildStatCard(
                          icon: Icons.local_offer,
                          title: 'Promociones',
                          value: '${promotionsState.promotions.length}',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gestión de reservas próximamente'),
                            ),
                          );
                        },
                        child: _buildStatCard(
                          icon: Icons.calendar_today,
                          title: 'Reservas Hoy',
                          value: '24',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Acciones rápidas
                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                _buildActionCard(
                  icon: Icons.add_business,
                  title: 'Agregar Nuevo Bar',
                  description: 'Registra un nuevo establecimiento',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    // Navegar a gestión de bares
                    context.go('/owner/bars');
                  },
                ),

                const SizedBox(height: 12),

                _buildActionCard(
                  icon: Icons.edit_note,
                  title: 'Crear Menú',
                  description: 'Añade un nuevo menú a tus bares',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    // Navegar a gestión de menús
                    context.go('/owner/menus');
                  },
                ),

                const SizedBox(height: 12),

                _buildActionCard(
                  icon: Icons.campaign,
                  title: 'Nueva Promoción',
                  description: 'Crea ofertas para atraer clientes',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    // Navegar a gestión de promociones
                    context.go('/owner/promotions');
                  },
                ),

                const SizedBox(height: 32),

                // Actividad reciente
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Color(0xFF6366F1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Actividad Reciente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildActivityItem(
                        icon: Icons.check_circle,
                        title: 'Nueva reserva confirmada',
                        time: 'Hace 2 horas',
                        color: const Color(0xFF10B981),
                      ),
                      const Divider(),
                      _buildActivityItem(
                        icon: Icons.star,
                        title: 'Nueva reseña recibida',
                        time: 'Hace 5 horas',
                        color: const Color(0xFFF59E0B),
                      ),
                      const Divider(),
                      _buildActivityItem(
                        icon: Icons.edit,
                        title: 'Menú actualizado',
                        time: 'Hace 1 día',
                        color: const Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
