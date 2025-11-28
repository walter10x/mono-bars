import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../modules/auth/controllers/auth_controller.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/home/views/home_screen.dart';

// Importaciones temporales para pantallas que crearemos después
// import '../modules/auth/views/forgot_password_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bars = '/bars';
  static const String barDetail = '/bars/:id';
  static const String menus = '/menus';
  static const String menuDetail = '/menus/:id';
  static const String promotions = '/promotions';
  static const String promotionDetail = '/promotions/:id';
  static const String settings = '/settings';
  
  /// Crea la configuración del router
  static GoRouter createRouter(ProviderRef<GoRouter> ref) {
    return GoRouter(
      initialLocation: login,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isAuthenticated = ref.read(isAuthenticatedProvider);
        final isLoggingIn = state.matchedLocation == login;
        final isRegistering = state.matchedLocation == register;
        final isForgotPassword = state.matchedLocation == forgotPassword;

        // Si no está autenticado y no está en pantallas de auth, redirigir al login
        if (!isAuthenticated && !isLoggingIn && !isRegistering && !isForgotPassword) {
          return login;
        }

        // Si está autenticado y está en pantallas de auth, redirigir al home
        if (isAuthenticated && (isLoggingIn || isRegistering || isForgotPassword)) {
          return home;
        }

        return null; // No redireccionar
      },
      routes: [
        // Rutas de autenticación
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Pantalla de Recuperación de Contraseña - Por implementar'),
            ),
          ),
        ),

        // Rutas principales (requieren autenticación)
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Pantalla de Perfil - Por implementar'),
            ),
          ),
        ),

        // Rutas de bares
        GoRoute(
          path: bars,
          name: 'bars',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Pantalla de Bares - Por implementar'),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              name: 'barDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return Scaffold(
                  body: Center(
                    child: Text('Detalle del Bar $id - Por implementar'),
                  ),
                );
              },
            ),
          ],
        ),

        // Rutas de menús
        GoRoute(
          path: menus,
          name: 'menus',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Pantalla de Menús - Por implementar'),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              name: 'menuDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return Scaffold(
                  body: Center(
                    child: Text('Detalle del Menú $id - Por implementar'),
                  ),
                );
              },
            ),
          ],
        ),

        // Rutas de promociones
        GoRoute(
          path: promotions,
          name: 'promotions',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Pantalla de Promociones - Por implementar'),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              name: 'promotionDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return Scaffold(
                  body: Center(
                    child: Text('Detalle de la Promoción $id - Por implementar'),
                  ),
                );
              },
            ),
          ],
        ),

        // Rutas de configuración
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Pantalla de Configuración - Por implementar'),
            ),
          ),
        ),
      ],
      
      // Manejo de errores
      errorBuilder: (context, state) => Scaffold(
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
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'La página que buscas no existe.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Ir al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider para el router de la aplicación
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

/// Pantalla principal con navegación inferior
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      label: 'Inicio',
      route: AppRouter.home,
    ),
    NavigationItem(
      icon: Icons.local_bar,
      label: 'Bares',
      route: AppRouter.bars,
    ),
    NavigationItem(
      icon: Icons.restaurant_menu,
      label: 'Menús',
      route: AppRouter.menus,
    ),
    NavigationItem(
      icon: Icons.local_offer,
      label: 'Promociones',
      route: AppRouter.promotions,
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Perfil',
      route: AppRouter.profile,
    ),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      // Aquí podrías navegar a diferentes pantallas si usas un enfoque diferente
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
                  : Text(currentUser?.initials ?? 'U'),
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
        return const HomeContent();
      case 1:
        return const BarsContent();
      case 2:
        return const MenusContent();
      case 3:
        return const PromotionsContent();
      case 4:
        return const ProfileContent();
      default:
        return const HomeContent();
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
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// Contenido temporal para las diferentes secciones
class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, ${currentUser?.fullName ?? 'Usuario'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const Text('Pantalla de inicio - Por implementar'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del usuario:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${currentUser?.email ?? 'N/A'}'),
                  Text('Roles: ${currentUser?.roles.join(', ') ?? 'N/A'}'),
                  Text('Activo: ${currentUser?.isActive == true ? 'Sí' : 'No'}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarsContent extends StatelessWidget {
  const BarsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contenido de Bares - Por implementar'),
    );
  }
}

class MenusContent extends StatelessWidget {
  const MenusContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contenido de Menús - Por implementar'),
    );
  }
}

class PromotionsContent extends StatelessWidget {
  const PromotionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contenido de Promociones - Por implementar'),
    );
  }
}

class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Contenido de Perfil - Por implementar'),
    );
  }
}
