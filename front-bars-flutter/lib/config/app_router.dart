import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../modules/auth/controllers/auth_controller.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/profile/views/profile_screen.dart';
import '../modules/profile/views/change_password_screen.dart';

// Owner screens
import '../modules/owner/views/owner_dashboard_screen.dart';
import '../modules/owner/views/owner_bars_management_screen.dart';
import '../modules/owner/views/owner_menus_management_screen.dart';
import '../modules/owner/views/owner_statistics_screen.dart';
import '../modules/owner/views/bar_form_screen.dart';
import '../modules/owner/views/menu_form_screen.dart';

// Client screens
import '../modules/client/views/client_home_screen.dart';
import '../modules/client/views/client_bars_list_screen.dart';
import '../modules/client/views/client_promotions_screen.dart';
import '../modules/client/views/client_favorites_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  // Rutas de autenticación
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Rutas de owner
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerBars = '/owner/bars';
  static const String ownerBarCreate = '/owner/bars/create';
  static const String ownerBarEdit = '/owner/bars/:id/edit';
  static const String ownerMenus = '/owner/menus';
  static const String ownerMenuCreate = '/owner/menus/create/:barId';
  static const String ownerMenuEdit = '/owner/menus/:id/edit';
  static const String ownerStatistics = '/owner/statistics';
  
  // Rutas de client
  static const String clientHome = '/client/home';
  static const String clientBars = '/client/bars';
  static const String clientPromotions = '/client/promotions';
  static const String clientFavorites = '/client/favorites';
  
  // Rutas comunes
  static const String profile = '/profile';
  static const String changePassword = '/profile/change-password';
  
  /// Crea la configuración del router
  static GoRouter createRouter(ProviderRef<GoRouter> ref) {
    return GoRouter(
      initialLocation: login,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isAuthenticated = ref.read(isAuthenticatedProvider);
        final userRole = ref.read(userRoleProvider);
        final currentLocation = state.matchedLocation;
        
        // Rutas de autenticación
        final isLoggingIn = currentLocation == login;
        final isRegistering = currentLocation == register;
        final isForgotPassword = currentLocation == forgotPassword;
        final isAuthRoute = isLoggingIn || isRegistering || isForgotPassword;
        
        // Si no está autenticado y no está en pantallas de auth, redirigir al login
        if (!isAuthenticated && !isAuthRoute) {
          return login;
        }
        
        // Si está autenticado y está en pantallas de auth, redirigir según rol
        if (isAuthenticated && isAuthRoute) {
          if (userRole == 'owner') {
            return ownerDashboard;
          } else {
            return clientHome;
          }
        }
        
        // Proteger rutas de owner (solo para owners)
        final isOwnerRoute = currentLocation.startsWith('/owner');
        if (isAuthenticated && isOwnerRoute && userRole != 'owner') {
          return clientHome; // Redirigir a client si intenta acceder a rutas de owner
        }
        
        // Proteger rutas de client (solo para clients)
        final isClientRoute = currentLocation.startsWith('/client');
        if (isAuthenticated && isClientRoute && userRole == 'owner') {
          return ownerDashboard; // Redirigir a owner si intenta acceder a rutas de client
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
        
        // Rutas de Owner
        GoRoute(
          path: ownerDashboard,
          name: 'ownerDashboard',
          builder: (context, state) => const OwnerNavigationWrapper(
            initialIndex: 0,
          ),
        ),
        
        GoRoute(
          path: ownerBars,
          name: 'ownerBars',
          builder: (context, state) => const OwnerNavigationWrapper(
            initialIndex: 1,
          ),
        ),
        
        GoRoute(
          path: ownerMenus,
          name: 'ownerMenus',
          builder: (context, state) => const OwnerNavigationWrapper(
            initialIndex: 2,
          ),
        ),
        
        GoRoute(
          path: ownerStatistics,
          name: 'ownerStatistics',
          builder: (context, state) => const OwnerNavigationWrapper(
            initialIndex: 3,
          ),
        ),
        
        GoRoute(
          path: ownerBarCreate,
          name: 'ownerBarCreate',
          builder: (context, state) => const BarFormScreen(),
        ),
        
        GoRoute(
          path: ownerBarEdit,
          name: 'ownerBarEdit',
          builder: (context, state) {
            final barId = state.pathParameters['id'];
            return BarFormScreen(barId: barId);
          },
        ),
        
        GoRoute(
          path: ownerMenuCreate,
          name: 'ownerMenuCreate',
          builder: (context, state) {
            final barId = state.pathParameters['barId'];
            return MenuFormScreen(barId: barId);
          },
        ),
        
        GoRoute(
          path: ownerMenuEdit,
          name: 'ownerMenuEdit',
          builder: (context, state) {
            final menuId = state.pathParameters['id'];
            return MenuFormScreen(menuId: menuId);
          },
        ),
        
        // Rutas de Client
        GoRoute(
          path: clientHome,
          name: 'clientHome',
          builder: (context, state) => const ClientNavigationWrapper(
            initialIndex: 0,
          ),
        ),
        
        GoRoute(
          path: clientBars,
          name: 'clientBars',
          builder: (context, state) => const ClientNavigationWrapper(
            initialIndex: 1,
          ),
        ),
        
        GoRoute(
          path: clientPromotions,
          name: 'clientPromotions',
          builder: (context, state) => const ClientNavigationWrapper(
            initialIndex: 2,
          ),
        ),
        
        GoRoute(
          path: clientFavorites,
          name: 'clientFavorites',
          builder: (context, state) => const ClientNavigationWrapper(
            initialIndex: 3,
          ),
        ),
        
        // Rutas comunes
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        
        GoRoute(
          path: changePassword,
          name: 'changePassword',
          builder: (context, state) => const ChangePasswordScreen(),
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
                onPressed: () => context.go(login),
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

/// Wrapper con navegación inferior para Owners
class OwnerNavigationWrapper extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const OwnerNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<OwnerNavigationWrapper> createState() => _OwnerNavigationWrapperState();
}

class _OwnerNavigationWrapperState extends ConsumerState<OwnerNavigationWrapper> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    OwnerDashboardScreen(),
    OwnerBarsManagementScreen(),
    OwnerMenusManagementScreen(),
    OwnerStatisticsScreen(),
  ];
  
  final List<String> _routes = [
    AppRouter.ownerDashboard,
    AppRouter.ownerBars,
    AppRouter.ownerMenus,
    AppRouter.ownerStatistics,
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Mis Bares',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menús',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}

/// Wrapper con navegación inferior para Clients
class ClientNavigationWrapper extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const ClientNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<ClientNavigationWrapper> createState() => _ClientNavigationWrapperState();
}

class _ClientNavigationWrapperState extends ConsumerState<ClientNavigationWrapper> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    ClientHomeScreen(),
    ClientBarsListScreen(),
    ClientPromotionsScreen(),
    ClientFavoritesScreen(),
  ];
  
  final List<String> _routes = [
    AppRouter.clientHome,
    AppRouter.clientBars,
    AppRouter.clientPromotions,
    AppRouter.clientFavorites,
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: 'Bares',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promociones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
