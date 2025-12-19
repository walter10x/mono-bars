import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/bars/models/bar_models.dart';
import 'package:front_bars_flutter/modules/favorites/controllers/favorites_controller.dart';
import 'package:front_bars_flutter/modules/promotions/controllers/promotions_controller.dart';
import 'package:front_bars_flutter/core/utils/image_url_helper.dart';

/// Pantalla de lista de bares para clientes con búsqueda
class ClientBarsListScreen extends ConsumerStatefulWidget {
  const ClientBarsListScreen({super.key});

  @override
  ConsumerState<ClientBarsListScreen> createState() => _ClientBarsListScreenState();
}

class _ClientBarsListScreenState extends ConsumerState<ClientBarsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Cargar bares y promociones al iniciar
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadAllBars();
      ref.read(promotionsControllerProvider.notifier).loadAllActivePromotions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce de 300ms para no hacer demasiadas peticiones
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        ref.read(barsControllerProvider.notifier).loadAllBars();
      } else {
        ref.read(barsControllerProvider.notifier).searchBars(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final promotionsState = ref.watch(promotionsControllerProvider);
    
    // Color constants
    const accentAmber = Color(0xFFFFA500);
    const accentGold = Color(0xFFFFB84D);
    const backgroundColor = Color(0xFF0F0F1E);
    const primaryDark = Color(0xFF1A1A2E);
    
    // Calculate filter counts
    final totalBars = barsState.bars.length;
    final openBars = barsState.bars.where((bar) => bar.isActive == true).length;
    
    // Calcular bares con promociones usando los datos reales
    final barIdsWithPromos = promotionsState.promotions
        .map((promo) => promo.barId)
        .toSet();
    final barsWithPromos = barsState.bars
        .where((bar) => barIdsWithPromos.contains(bar.id))
        .length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con búsqueda
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: accentAmber,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Descubre Bares',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explora los mejores locales',
                      style: TextStyle(
                        fontSize: 16,
                        color: accentGold.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, ciudad, dirección...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          prefixIcon: Icon(
                            Icons.search,
                            color: accentAmber,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 'all', totalBars, accentAmber),
                      const SizedBox(width: 8),
                      _buildFilterChip('Abierto', 'open', openBars, accentAmber),
                      const SizedBox(width: 8),
                      _buildFilterChip('Con Promociones', 'promos', barsWithPromos, accentAmber),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de bares
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildBarsList(barsState, accentAmber, barIdsWithPromos),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarsList(BarsState barsState, Color accentColor, Set<String> barIdsWithPromos) {
    // Estado de carga
    if (barsState.status == BarsStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: accentColor,
        ),
      );
    }

    // Estado de error
    if (barsState.status == BarsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar bares',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                barsState.errorMessage ?? 'Error desconocido',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(barsControllerProvider.notifier).loadAllBars();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filtrar bares según el filtro seleccionado
    List<Bar> filteredBars = barsState.bars;
    if (_selectedFilter == 'open') {
      filteredBars = filteredBars.where((bar) => bar.isActive).toList();
    } else if (_selectedFilter == 'promos') {
      // Filtrar solo bares que tienen promociones activas
      filteredBars = filteredBars.where((bar) => barIdsWithPromos.contains(bar.id)).toList();
    }

    // Lista vacía
    if (filteredBars.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isNotEmpty
                    ? 'No se encontraron bares'
                    : _selectedFilter == 'all'
                        ? 'No hay bares disponibles'
                        : _selectedFilter == 'open'
                            ? 'No hay bares abiertos'
                            : 'No hay bares con promociones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isNotEmpty
                    ? 'Intenta con otros términos de búsqueda'
                    : 'Prueba cambiando el filtro',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Lista de bares
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: filteredBars.length,
      itemBuilder: (context, index) {
        final bar = filteredBars[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBarListItem(bar),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, int count, Color accentColor) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : const Color(0xFF1E1E2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF1A1A2E).withOpacity(0.2)
                    : accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1A1A2E) : accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarListItem(Bar bar) {
    // Usar rating real del bar
    final rating = bar.averageRating ?? 0.0;
    final reviews = bar.totalReviews ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
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
          // Imagen y badges
          Stack(
            children: [
              // Imagen del bar
              Container(
                height: 150,
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
              // Badge de estado
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bar.isActive ? const Color(0xFF10B981) : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    bar.isActive ? 'Abierto' : 'Cerrado',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bar.nameBar,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final favoritesController = ref.watch(favoritesControllerProvider.notifier);
                        final isFavorite = ref.watch(favoritesControllerProvider).isFavorite(bar.id);
                        
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isFavorite ? Colors.red : Colors.white.withOpacity(0.6),
                          iconSize: 24,
                          onPressed: () {
                            favoritesController.toggleFavorite(bar.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: const Color(0xFFFFA500),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bar.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Color(0xFFFFA500),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews ${reviews == 1 ? 'reseña' : 'reseñas'})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/client/bars/${bar.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      foregroundColor: const Color(0xFF1A1A2E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ver Detalles',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xFF6366F1).withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.storefront,
          size: 64,
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
    );
  }
}
