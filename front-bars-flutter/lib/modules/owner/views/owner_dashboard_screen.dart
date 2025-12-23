import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../bars/controllers/bars_controller.dart';
import '../../menus/controllers/menus_controller.dart';
import '../../promotions/controllers/promotions_controller.dart';
import '../../reviews/controllers/reviews_controller.dart';
import 'owner_reviews_screen.dart';

/// Pantalla principal del dashboard para propietarios de bares
class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  // Colores del tema oscuro
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadMyBars();
      ref.read(menusControllerProvider.notifier).loadMyMenus();
      ref.read(promotionsControllerProvider.notifier).loadMyPromotions();
      ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final barsState = ref.watch(barsControllerProvider);
    final menusState = ref.watch(menusControllerProvider);
    final promotionsState = ref.watch(promotionsControllerProvider);
    final reviewsState = ref.watch(reviewsControllerProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con gradiente
              _buildHeader(user),

              const SizedBox(height: 32),

              // Estadísticas - Fila 1
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/owner/bars'),
                      child: _buildStatCard(
                        icon: Icons.storefront,
                        title: 'Mis Bares',
                        value: '${barsState.bars.length}',
                        color: accentAmber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/owner/menus'),
                      child: _buildStatCard(
                        icon: Icons.restaurant_menu,
                        title: 'Menús',
                        value: '${menusState.menus.length}',
                        color: accentGold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fila 2
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/owner/promotions'),
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
                      onTap: () => context.go('/owner/reservations'),
                      child: _buildStatCard(
                        icon: Icons.calendar_today,
                        title: 'Reservas',
                        value: '0',
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fila 3 - Reseñas
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerReviewsScreen(),
                    ),
                  );
                },
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'Reseñas',
                  value: '${reviewsState.reviews.length}',
                  color: const Color(0xFFEC4899),
                ),
              ),

              const SizedBox(height: 32),

              // Acciones rápidas
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [accentAmber, accentGold],
                ).createShader(bounds),
                child: const Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildActionCard(
                icon: Icons.add_business,
                title: 'Agregar Nuevo Bar',
                description: 'Registra un nuevo establecimiento',
                onTap: () => context.go('/owner/bars'),
              ),

              const SizedBox(height: 12),

              _buildActionCard(
                icon: Icons.edit_note,
                title: 'Crear Menú',
                description: 'Añade un nuevo menú a tus bares',
                onTap: () => context.go('/owner/menus'),
              ),

              const SizedBox(height: 12),

              _buildActionCard(
                icon: Icons.campaign,
                title: 'Nueva Promoción',
                description: 'Crea ofertas para atraer clientes',
                onTap: () => context.go('/owner/promotions'),
              ),

              const SizedBox(height: 32),

              // Actividad reciente
              _buildActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${user?.fullName ?? "Owner"}!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentAmber, accentGold],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '👔 OWNER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Panel de Control',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [accentAmber, accentGold],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentAmber.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user?.initials ?? 'O',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
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
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentAmber.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentAmber.withOpacity(0.2),
                    accentGold.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accentAmber,
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: accentAmber.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: accentAmber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Actividad Reciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityItem(
            icon: Icons.check_circle,
            title: 'Nueva reserva confirmada',
            time: 'Hace 2 horas',
            color: const Color(0xFF10B981),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          _buildActivityItem(
            icon: Icons.star,
            title: 'Nueva reseña recibida',
            time: 'Hace 5 horas',
            color: accentGold,
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          _buildActivityItem(
            icon: Icons.edit,
            title: 'Menú actualizado',
            time: 'Hace 1 día',
            color: accentAmber,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
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
