import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../auth/controllers/auth_controller.dart';
import '../../bars/controllers/bars_controller.dart';
import '../../../core/utils/image_url_helper.dart';

/// Pantalla principal para clientes
class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Cargar bares cuando se inicializa la pantalla
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadAllBars();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isSearching = query.isNotEmpty;
      });
      if (query.isEmpty) {
        ref.read(barsControllerProvider.notifier).loadAllBars();
      } else {
        ref.read(barsControllerProvider.notifier).searchBars(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final barsState = ref.watch(barsControllerProvider);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${user?.fullName ?? "Usuario"}!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '¿Qué te apetece hoy?',
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
                              user?.initials ?? 'U',
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
                ),

                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
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
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, ciudad, dirección...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6366F1),
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
                ),

                const SizedBox(height: 24),

                // Contenido principal
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Promociones destacadas
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🔥 Promociones Destacadas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 180,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildPromotionCard(
                              title: '2x1 en Cócteles',
                              description: 'Todos los jueves',
                              discount: '50% OFF',
                              color: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 16),
                            _buildPromotionCard(
                              title: 'Happy Hour',
                              description: 'De 18:00 a 20:00',
                              discount: '30% OFF',
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 16),
                            _buildPromotionCard(
                              title: 'Menú del Día',
                              description: 'L-V hasta 16:00',
                              discount: '€12.90',
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Bares cercanos o resultados de búsqueda
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isSearching ? '🔍 Resultados de búsqueda' : '📍 Bares Cerca de Ti',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contenido de bares - con estados de loading/error/datos
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildBarsContent(barsState),
                      ),

                      const SizedBox(height: 24),
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

  /// Construir contenido de bares según el estado
  Widget _buildBarsContent(BarsState barsState) {
    // Estado de carga
    if (barsState.status == BarsStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    // Estado de error
    if (barsState.hasError) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            Text(
              'Error al cargar bares',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              barsState.errorMessage ?? 'Error desconocido',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
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
                backgroundColor: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      );
    }

    // Estado vacío
    if (barsState.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay bares disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor, intenta más tarde',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar bares (máximo 3 si no está buscando, todos si está buscando)
    final barsToShow = _isSearching ? barsState.bars : barsState.bars.take(3).toList();
    
    return Column(
      children: [
        ...barsToShow.map((bar) {
          // Usar rating real del bar
          final rating = bar.averageRating ?? 0.0;
          final reviews = bar.totalReviews ?? 0;
          
          // Debug: imprimir foto del bar
          print('Bar: ${bar.nameBar}, Photo: ${bar.photo}');
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildBarCard(
              barId: bar.id,
              name: bar.nameBar,
              address: bar.location,
              rating: rating,
              reviews: reviews,
              tags: ['Bar', 'Bebidas', 'Ambiente'], // Tags por defecto por ahora
              photo: bar.photo,
            ),
          );
        }).toList(),
        
        // Botón "Ver más" si hay más de 3 bares y NO está buscando
        if (barsState.bars.length > 3 && !_isSearching)
          TextButton.icon(
            onPressed: () {
              // Navegar a la lista completa de bares
              context.push('/client/bars');
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text('Ver todos (${barsState.bars.length})'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
            ),
          ),
      ],
    );
  }

  Widget _buildPromotionCard({
    required String title,
    required String description,
    required String discount,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                discount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard({
    required String barId,
    required String name,
    required String address,
    required double rating,
    required int reviews,
    required List<String> tags,
    String? photo,
  }) {
    return GestureDetector(
      onTap: () {
        // Navegar al detalle del bar
        context.push('/client/bars/$barId');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con foto del bar
            Stack(
              children: [
                // Imagen de fondo
                Container(
                  height: 160,
                  width: double.infinity,
                  child: photo != null && photo.isNotEmpty
                      ? Image.network(
                          ImageUrlHelper.getFullImageUrl(photo),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.storefront,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.storefront,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                ),

                // Gradiente oscuro en la parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
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

                // Rating badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFF59E0B),
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
                      ],
                    ),
                  ),
                ),

                // Favorito
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Agregar a favoritos
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
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
                  // Nombre
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Reviews
                  Text(
                    '$reviews reseñas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
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
