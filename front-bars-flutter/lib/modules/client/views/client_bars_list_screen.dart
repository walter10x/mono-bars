import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de lista de bares para clientes
class ClientBarsListScreen extends ConsumerStatefulWidget {
  const ClientBarsListScreen({super.key});

  @override
  ConsumerState<ClientBarsListScreen> createState() => _ClientBarsListScreenState();
}

class _ClientBarsListScreenState extends ConsumerState<ClientBarsListScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descubre Bares',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Explora los mejores locales',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
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
                      _buildFilterChip('Todos', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cerca de mí', 'nearby'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Mejor valorados', 'top'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Promociones', 'promos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Abierto ahora', 'open'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Lista de bares
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      _buildBarListItem(
                        name: 'El Rincón del Jazz',
                        address: 'Calle Mayor 45, Madrid',
                        distance: '0.5 km',
                        rating: 4.5,
                        reviews: 128,
                        price: '€€',
                        tags: ['Jazz', 'Cócteles', 'Ambiente', 'Terraza'],
                        isOpen: true,
                        hasPromotion: true,
                      ),
                      const SizedBox(height: 16),
                      _buildBarListItem(
                        name: 'La Taberna Moderna',
                        address: 'Avenida de la Paz 12, Madrid',
                        distance: '0.8 km',
                        rating: 4.2,
                        reviews: 89,
                        price: '€',
                        tags: ['Tapas', 'Cerveza', 'Terraza'],
                        isOpen: true,
                        hasPromotion: false,
                      ),
                      const SizedBox(height: 16),
                      _buildBarListItem(
                        name: 'Bar Central',
                        address: 'Plaza del Sol 3, Madrid',
                        distance: '1.2 km',
                        rating: 4.7,
                        reviews: 256,
                        price: '€€€',
                        tags: ['Clásico', 'Vinos', 'Comida'],
                        isOpen: false,
                        hasPromotion: true,
                      ),
                      const SizedBox(height: 16),
                      _buildBarListItem(
                        name: 'La Cervecería Artesana',
                        address: 'Calle de la Libertad 8, Madrid',
                        distance: '1.5 km',
                        rating: 4.4,
                        reviews: 178,
                        price: '€€',
                        tags: ['Cerveza Artesanal', 'Burguer', 'Moderno'],
                        isOpen: true,
                        hasPromotion: true,
                      ),
                      const SizedBox(height: 16),
                      _buildBarListItem(
                        name: 'El Pub Irlandés',
                        address: 'Calle Gran Vía 67, Madrid',
                        distance: '2.0 km',
                        rating: 4.3,
                        reviews: 145,
                        price: '€€',
                        tags: ['Pub', 'Música en Vivo', 'Deportes'],
                        isOpen: true,
                        hasPromotion: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBarListItem({
    required String name,
    required String address,
    required String distance,
    required double rating,
    required int reviews,
    required String price,
    required List<String> tags,
    required bool isOpen,
    required bool hasPromotion,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPromotion
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : Colors.grey.shade200,
          width: hasPromotion ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagen y badge de promoción
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.storefront,
                    size: 64,
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
              ),
              if (hasPromotion)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Oferta',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen ? const Color(0xFF10B981) : Colors.grey,
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
                    isOpen ? 'Abierto' : 'Cerrado',
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
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.grey.shade400,
                      iconSize: 24,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      ),
                    ),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
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
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews reseñas)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
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
}
