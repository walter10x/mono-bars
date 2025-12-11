import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de promociones para clientes
class ClientPromotionsScreen extends ConsumerWidget {
  const ClientPromotionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      'Promociones',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ofertas y descuentos especiales',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de promociones
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
                      _buildPromotionCard(
                        title: '2x1 en Cócteles',
                        description: 'Todos los jueves en El Rincón del Jazz',
                        discount: '50% OFF',
                        validUntil: 'Válido hasta el 31 Dic',
                        barName: 'El Rincón del Jazz',
                        color: const Color(0xFFEF4444),
                        icon: Icons.local_bar,
                      ),
                      const SizedBox(height: 16),
                      _buildPromotionCard(
                        title: 'Happy Hour',
                        description: 'De 18:00 a 20:00 todos los días',
                        discount: '30% OFF',
                        validUntil: 'Promoción permanente',
                        barName: 'La Taberna Moderna',
                        color: const Color(0xFFF59E0B),
                        icon: Icons.access_time,
                      ),
                      const SizedBox(height: 16),
                      _buildPromotionCard(
                        title: 'Menú del Día',
                        description: 'Incluye primer plato, segundo y postre',
                        discount: '€12.90',
                        validUntil: 'L-V hasta 16:00',
                        barName: 'Bar Central',
                        color: const Color(0xFF10B981),
                        icon: Icons.restaurant_menu,
                      ),
                      const SizedBox(height: 16),
                      _buildPromotionCard(
                        title: 'Noche de Tapas',
                        description: '3 tapas + bebida por precio especial',
                        discount: '€9.90',
                        validUntil: 'Todos los miércoles',
                        barName: 'La Taberna Moderna',
                        color: const Color(0xFF8B5CF6),
                        icon: Icons.tapas,
                      ),
                      const SizedBox(height: 16),
                      _buildPromotionCard(
                        title: 'Cerveza Artesanal',
                        description: 'Segunda cerveza al 50%',
                        discount: '50% OFF',
                        validUntil: 'Fines de semana',
                        barName: 'La Cervecería Artesana',
                        color: const Color(0xFF3B82F6),
                        icon: Icons.sports_bar,
                      ),
                      const SizedBox(height: 16),
                      _buildPromotionCard(
                        title: 'Live Music Night',
                        description: 'Entrada gratis + copa de bienvenida',
                        discount: 'GRATIS',
                        validUntil: 'Viernes y sábados',
                        barName: 'El Pub Irlandés',
                        color: const Color(0xFFEC4899),
                        icon: Icons.music_note,
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

  Widget _buildPromotionCard({
    required String title,
    required String description,
    required String discount,
    required String validUntil,
    required String barName,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con color
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        barName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    discount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      validUntil,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Ver Detalles'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.redeem, size: 18),
                        label: const Text('Usar Ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
