import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_models.dart';
import 'package:front_bars_flutter/core/utils/image_url_helper.dart';

/// Pantalla de vista previa de promoción para owners
/// Rediseñada con tema oscuro premium
class OwnerPromotionPreviewScreen extends StatelessWidget {
  final Promotion promotion;

  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);
  static const promoAccent = Color(0xFFEC4899);

  const OwnerPromotionPreviewScreen({
    super.key,
    required this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    final isExpired = now.isAfter(promotion.endDate);
    final isActive = promotion.status == PromotionStatus.active && !isExpired;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isActive),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isActive, isExpired),
                const SizedBox(height: 24),
                if (promotion.discountPercentage != null ||
                    promotion.discountAmount != null)
                  _buildDiscountInfo(),
                const SizedBox(height: 24),
                _buildValidityDates(dateFormat),
                const SizedBox(height: 24),
                if (promotion.description.isNotEmpty) _buildDescription(),
                const SizedBox(height: 24),
                if (promotion.requiresCode && promotion.promotionCode != null)
                  _buildPromoCode(),
                const SizedBox(height: 24),
                _buildAdditionalDetails(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isActive) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: primaryDark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (promotion.image != null && promotion.image!.isNotEmpty)
              Image.network(
                ImageUrlHelper.getFullImageUrl(promotion.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            else
              _buildImagePlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    backgroundColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            promoAccent.withOpacity(0.7),
            accentAmber.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_offer,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isActive, bool isExpired) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isExpired
                  ? Colors.grey.withOpacity(0.2)
                  : isActive
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpired
                    ? Colors.grey.withOpacity(0.3)
                    : isActive
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : accentAmber.withOpacity(0.3),
              ),
            ),
            child: Text(
              isExpired
                  ? 'EXPIRADA'
                  : promotion.status == PromotionStatus.active
                      ? 'ACTIVA'
                      : 'PAUSADA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isExpired
                    ? Colors.grey
                    : isActive
                        ? const Color(0xFF10B981)
                        : accentAmber,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Título
          Text(
            promotion.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              promoAccent.withOpacity(0.15),
              accentAmber.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: promoAccent.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [promoAccent, Color(0xFFF472B6)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_offer,
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
                    'Descuento',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [promoAccent, accentAmber],
                    ).createShader(bounds),
                    child: Text(
                      promotion.discountPercentage != null
                          ? '${promotion.discountPercentage}% OFF'
                          : '\$${promotion.discountAmount!.toStringAsFixed(2)} OFF',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildValidityDates(DateFormat dateFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentAmber.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: accentAmber,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Válido desde',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    dateFormat.format(promotion.startDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasta',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    dateFormat.format(promotion.endDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentAmber.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description,
                    color: accentAmber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              promotion.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: promoAccent.withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: promoAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: promoAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Código de promoción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    promoAccent.withOpacity(0.2),
                    promoAccent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: promoAccent.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  promotion.promotionCode!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: promoAccent,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentAmber.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: accentAmber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Detalles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (promotion.minimumPurchase != null)
              _buildDetailRow(
                Icons.shopping_cart,
                'Compra mínima',
                '\$${promotion.minimumPurchase!.toStringAsFixed(2)}',
              ),
            if (promotion.maxUses != null)
              _buildDetailRow(
                Icons.people,
                'Usos disponibles',
                '${promotion.maxUses! - promotion.currentUses} de ${promotion.maxUses}',
              ),
            if (promotion.daysOfWeek.isNotEmpty)
              _buildDetailRow(
                Icons.calendar_month,
                'Días aplicables',
                promotion.daysOfWeek.join(', '),
              ),
            if (promotion.startTime != null && promotion.endTime != null)
              _buildDetailRow(
                Icons.schedule,
                'Horario',
                '${promotion.startTime} - ${promotion.endTime}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accentAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
