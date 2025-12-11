import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_router.dart';
import '../../auth/controllers/auth_controller.dart';

/// Pantalla de navegación para usuarios tipo CLIENT
/// Muestra opciones para buscar bares, ver menús y promociones
class ClientNavigationScreen extends ConsumerStatefulWidget {
  const ClientNavigationScreen({super.key});

  @override
  ConsumerState<ClientNavigationScreen> createState() => _ClientNavigationScreenState();
}

class _ClientNavigationScreenState extends ConsumerState<ClientNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      label: 'Inicio',
    ),
    NavigationItem(
      icon: Icons.search,
      label: 'Buscar',
    ),
    NavigationItem(
      icon: Icons.restaurant_menu,
      label: 'Menús',
    ),
    NavigationItem(
      icon: Icons.local_offer,
      label: 'Ofertas',
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
                    : Text(currentUser?.initials ?? 'C'),
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
        return const ClientHomeContent();
      case 1:
        return const ClientSearchContent();
      case 2:
        return const ClientMenusContent();
      case 3:
        return const ClientPromotionsContent();
      case 4:
        return const ClientProfileContent();
      default:
        return const ClientHomeContent();
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

/// Contenido de la pantalla de inicio para clientes
class ClientHomeContent extends ConsumerWidget {
  const ClientHomeContent({super.key});

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
            '¡Hola, ${currentUser?.name ?? 'Cliente'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre los mejores bares cerca de ti',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Bares destacados
          Text(
            'Bares Destacados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildPlaceholderCard(
            context,
            icon: Icons.local_bar,
            title: 'Bares cercanos',
            subtitle: 'Por implementar - Lista de bares recomendados',
          ),
          const SizedBox(height: 24),

          // Promociones activas
          Text(
            'Promociones Activas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildPlaceholderCard(
            context,
            icon: Icons.local_offer,
            title: 'Ofertas del día',
            subtitle: 'Por implementar - Promociones vigentes',
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido de búsqueda para clientes
class ClientSearchContent extends StatelessWidget {
  const ClientSearchContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Búsqueda de Bares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Búsqueda avanzada de bares'),
        ],
      ),
    );
  }
}

/// Contenido de menús para clientes
class ClientMenusContent extends StatelessWidget {
  const ClientMenusContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Explorar Menús',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Menús de diferentes bares'),
        ],
      ),
    );
  }
}

/// Contenido de promociones para clientes
class ClientPromotionsContent extends StatelessWidget {
  const ClientPromotionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Promociones Disponibles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Ofertas y descuentos'),
        ],
      ),
    );
  }
}

/// Contenido de perfil para clientes
class ClientProfileContent extends StatelessWidget {
  const ClientProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Mi Perfil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Por implementar - Perfil de usuario'),
        ],
      ),
    );
  }
}
