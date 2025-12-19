import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../promotions/controllers/promotions_controller.dart';
import '../../promotions/models/promotion_simple_model.dart';
import '../../../core/utils/image_url_helper.dart';

/// Pantalla de promociones para clientes
class ClientPromotionsScreen extends ConsumerStatefulWidget {
  const ClientPromotionsScreen({super.key});

  @override
  ConsumerState<ClientPromotionsScreen> createState() => _ClientPromotionsScreenState();
}

class _ClientPromotionsScreenState extends ConsumerState<ClientPromotionsScreen> {
  // Colores de la app
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const backgroundColor = Color(0xFF0F0F1E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  @override
  void initState() {
    super.initState();
    // Cargar todas las promociones activas al iniciar
    Future.microtask(() {
      ref.read(promotionsControllerProvider.notifier).loadAllActivePromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final promotionsState = ref.watch(promotionsControllerProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con gradiente oscuro
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryDark,
                    secondaryDark,
                    primaryDark.withOpacity(0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentAmber.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: accentAmber, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Promociones',
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
                      'Ofertas y descuentos especiales',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de promociones
            Expanded(
              child: _buildContent(promotionsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PromotionsState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: accentAmber,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar promociones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(promotionsControllerProvider.notifier).loadAllActivePromotions();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentAmber,
                    foregroundColor: primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.promotions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay promociones disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vuelve más tarde para ver nuevas ofertas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(promotionsControllerProvider.notifier).loadAllActivePromotions();
      },
      color: accentAmber,
      backgroundColor: secondaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: state.promotions.length,
        itemBuilder: (context, index) {
          final promotion = state.promotions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPromotionCard(promotion),
          );
        },
      ),
    );
  }

  Widget _buildPromotionCard(PromotionSimple promotion) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final cardBackground = const Color(0xFF1E1E2D);

    return GestureDetector(
      onTap: () {
        // Navegar al detalle de la promoción
        context.push('/client/promotion/${promotion.id}', extra: promotion);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentAmber,
                    accentGold,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
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
                      _getPromotionIcon(promotion),
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
                          promotion.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // Navegar al detalle del bar
                            context.push('/client/bars/${promotion.barId}');
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.storefront,
                                size: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  promotion.barName ?? 'Bar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (promotion.discountPercentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${promotion.discountPercentage!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFA500),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  if (promotion.description != null && promotion.description!.isNotEmpty)
                    Text(
                      promotion.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // Fecha de validez
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: accentGold,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Válido hasta ${dateFormat.format(promotion.validUntil)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/client/promotion/${promotion.id}', extra: promotion);
                          },
                          icon: Icon(Icons.info_outline, size: 18, color: accentAmber),
                          label: Text(
                            'Detalles',
                            style: TextStyle(color: accentAmber),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accentAmber),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navegar al detalle del bar
                            context.push('/client/bars/${promotion.barId}');
                          },
                          icon: const Icon(Icons.store, size: 18),
                          label: const Text('Ver Bar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentAmber,
                            foregroundColor: primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
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
      ),
    );
  }

  IconData _getPromotionIcon(PromotionSimple promotion) {
    // Asignar iconos basados en palabras clave en el título
    final title = promotion.title.toLowerCase();
    
    if (title.contains('cóctel') || title.contains('coctel') || title.contains('2x1') || title.contains('cocktail')) {
      return Icons.local_bar;
    } else if (title.contains('happy hour') || title.contains('hora')) {
      return Icons.access_time;
    } else if (title.contains('menú') || title.contains('menu') || title.contains('comida')) {
      return Icons.restaurant_menu;
    } else if (title.contains('tapa')) {
      return Icons.tapas;
    } else if (title.contains('cerveza') || title.contains('beer') || title.contains('birra')) {
      return Icons.sports_bar;
    } else if (title.contains('music') || title.contains('música') || title.contains('live')) {
      return Icons.music_note;
    } else if (title.contains('pizza')) {
      return Icons.local_pizza;
    } else if (title.contains('café') || title.contains('cafe') || title.contains('coffee')) {
      return Icons.local_cafe;
    } else {
      return Icons.local_offer;
    }
  }
}
