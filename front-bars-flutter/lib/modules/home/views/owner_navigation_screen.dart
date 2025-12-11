import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_router.dart';
import '../../auth/controllers/auth_controller.dart';

/// Pantalla de navegación para usuarios tipo OWNER
/// Muestra opciones para gestionar bares, menús y promociones
class OwnerNavigationScreen extends ConsumerStatefulWidget {
  const OwnerNavigationScreen({super.key});

  @override
  ConsumerState<OwnerNavigationScreen> createState() => _OwnerNavigationScreenState();
}

class _OwnerNavigationScreenState extends ConsumerState<OwnerNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.local_bar,
      label: 'Mis Bares',
    ),
    NavigationItem(
      icon: Icons.restaurant_menu,
      label: 'Menús',
    ),
    NavigationItem(
      icon: Icons.local_offer,
      label: 'Promociones',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Perfil',
    ),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_navigationItems[_selectedIndex].label),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  context.push(AppRouter.settings);
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: currentUser?.avatar != null
                    ? ClipOval(
                        child: Image.network(
                          currentUser!.avatar!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(currentUser.initials);
                          },
                        ),
                      )
                    : Text(currentUser?.initials ?? 'O'),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const OwnerDashboardContent();
      case 1:
        return const OwnerBarsContent();
      case 2:
        return const OwnerMenusContent();
      case 3:
        return const OwnerPromotionsContent();
      case 4:
        return const OwnerProfileContent();
      default:
        return const OwnerDashboardContent();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

/// Modelo para elementos de navegación
class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
}

/// Contenido del dashboard para owners
class OwnerDashboardContent extends ConsumerWidget {
  const OwnerDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bienvenida
          Text(
            '¡Bienvenido, ${currentUser?.name ?? 'Propietario'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Panel de control de tu negocio',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.local_bar,
                  title: '0',
                  subtitle: 'Bares',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.restaurant_menu,
                  title: '0',
                  subtitle: 'Menús',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.local_offer,
                  title: '0',
                  subtitle: 'Promociones',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.visibility,
                  title: '0',
                  subtitle: 'Visitas',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Acciones rápidas
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            icon: Icons.add_business,
            title: 'Crear Nuevo Bar',
            subtitle: 'Registra un nuevo establecimiento',
            onTap: () {
              // TODO: Navegar a crear bar
            },
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            context,
            icon: Icons.add,
            title: 'Crear Promoción',
            subtitle: 'Agrega una nueva oferta',
            onTap: () {
              // TODO: Navegar a crear promoción
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// Contenido de bares para owners
class OwnerBarsContent extends StatelessWidget {
  const OwnerBarsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_bar, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Gestión de Bares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Por implementar - Lista y gestión de tus bares'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar a crear bar
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Nuevo Bar'),
          ),
        ],
      ),
    );
  }
}

/// Contenido de menús para owners
class OwnerMenusContent extends StatelessWidget {
  const OwnerMenusContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Gestión de Menús',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Administra los menús de tus bares'),
        ],
      ),
    );
  }
}

/// Contenido de promociones para owners
class OwnerPromotionsContent extends StatelessWidget {
  const OwnerPromotionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Gestión de Promociones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Crea y gestiona promociones'),
        ],
      ),
    );
  }
}

/// Contenido de perfil para owners
class OwnerProfileContent extends StatelessWidget {
  const OwnerProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Mi Perfil de Negocio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Configuración del perfil'),
        ],
      ),
    );
  }
}
