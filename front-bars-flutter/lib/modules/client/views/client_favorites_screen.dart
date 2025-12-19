import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../favorites/controllers/favorites_controller.dart';
import '../../bars/controllers/bars_controller.dart';
import '../../../core/utils/image_url_helper.dart';

/// Pantalla de favoritos para clientes
class ClientFavoritesScreen extends ConsumerStatefulWidget {
  const ClientFavoritesScreen({super.key});

  @override
  ConsumerState<ClientFavoritesScreen> createState() => _ClientFavoritesScreenState();
}

class _ClientFavoritesScreenState extends ConsumerState<ClientFavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar todos los bares para poder filtrar los favoritos
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadAllBars();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0F0F1E);
    const cardBackground = Color(0xFF1E1E2D);
    const accentAmber = Color(0xFFFFA500);
    
    final favoritesState = ref.watch(favoritesControllerProvider);
    final barsState = ref.watch(barsControllerProvider);
    
    // Filtrar solo los bares que están en favoritos
    final favoriteBars = barsState.bars
        .where((bar) => favoritesState.favoriteBarIds.contains(bar.id))
        .toList();
    
    final hasFavorites = favoriteBars.isNotEmpty;

    return Scaffold(
      backgroundColor: primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: accentAmber,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mis Favoritos',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasFavorites 
                        ? '${favoriteBars.length} ${favoriteBars.length == 1 ? 'bar guardado' : 'bares guardados'}'
                        : 'Aún no tienes bares guardados',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: barsState.status == BarsStatus.loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: accentAmber,
                      ),
                    )
                  : hasFavorites
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: favoriteBars.length,
                          itemBuilder: (context, index) {
                            final bar = favoriteBars[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildFavoriteBarCard(bar, accentAmber, cardBackground),
                            );
                          },
                        )
                      : _buildEmptyState(accentAmber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteBarCard(bar, Color accentAmber, Color cardBackground) {
    final rating = bar.averageRating ?? 0.0;
    final reviews = bar.totalReviews ?? 0;
    
    return GestureDetector(
      onTap: () {
        context.push('/client/bars/${bar.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Stack con imagen y botón de favorito
            Stack(
              children: [
                // Imagen
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: bar.photo != null && bar.photo!.isNotEmpty
                      ? Image.network(
                          ImageUrlHelper.getFullImageUrl(bar.photo),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
                
                // Gradiente oscuro en la parte inferior de la imagen
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Botón de favorito
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final favoritesController = ref.watch(favoritesControllerProvider.notifier);
                      return GestureDetector(
                        onTap: () {
                          favoritesController.toggleFavorite(bar.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Información del bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    bar.nameBar,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: accentAmber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bar.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating y estado
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accentAmber.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: accentAmber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bar.isActive
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: bar.isActive
                                ? const Color(0xFF10B981).withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: bar.isActive
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bar.isActive ? 'Abierto' : 'Cerrado',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: bar.isActive
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
        ),
      ),
      child: Icon(
        Icons.storefront,
        size: 64,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildEmptyState(Color accentAmber) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes favoritos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Empieza a guardar tus bares\nfavoritos desde el inicio',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/client/home');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explorar Bares'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentAmber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
