import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/promotions/controllers/promotions_controller.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_models.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_simple_model.dart';

/// Pantalla de gestión de promociones para propietarios
/// Rediseñada con tema oscuro premium
class OwnerPromotionsManagementScreen extends ConsumerStatefulWidget {
  const OwnerPromotionsManagementScreen({super.key});

  @override
  ConsumerState<OwnerPromotionsManagementScreen> createState() =>
      _OwnerPromotionsManagementScreenState();
}

class _OwnerPromotionsManagementScreenState
    extends ConsumerState<OwnerPromotionsManagementScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);
  
  // Color accent para promociones (rosa vibrante)
  static const promoAccent = Color(0xFFEC4899);

  String? selectedBarId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadMyBars();
      ref.read(promotionsControllerProvider.notifier).loadMyPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final promotionsState = ref.watch(promotionsControllerProvider);
    final barsState = ref.watch(barsControllerProvider);

    // Listener para errores
    ref.listen(promotionsControllerProvider, (previous, current) {
      if (current.error != null) {
        context.showErrorSnackBar(current.error!);
      }
    });

    // Filtrar promociones por bar si hay uno seleccionado
    final filteredPromotions = selectedBarId == null
        ? promotionsState.promotions
        : promotionsState.promotions
            .where((p) => p.barId == selectedBarId)
            .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con estilo premium
            _buildHeader(filteredPromotions.length),

            // Selector de Bar
            if (barsState.status == BarsStatus.loaded &&
                barsState.bars.isNotEmpty)
              _buildBarSelector(barsState),

            const SizedBox(height: 16),

            // Lista de promociones
            Expanded(
              child: _buildContent(promotionsState, filteredPromotions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int promotionCount) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [accentAmber, accentGold],
                  ).createShader(bounds),
                  child: const Text(
                    'Promociones',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: promoAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$promotionCount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: promoAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      promotionCount == 1 ? 'promoción' : 'promociones',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: selectedBarId != null
                  ? const LinearGradient(colors: [accentAmber, accentGold])
                  : null,
              color: selectedBarId == null ? Colors.grey.shade700 : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selectedBarId != null
                  ? [
                      BoxShadow(
                        color: accentAmber.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: selectedBarId == null
                    ? null
                    : () => context.push('/owner/promotions/create/$selectedBarId'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: selectedBarId != null ? Colors.black : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nueva',
                        style: TextStyle(
                          color: selectedBarId != null ? Colors.black : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarSelector(BarsState barsState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentAmber.withOpacity(0.2),
          ),
        ),
        child: DropdownButton<String?>(
          value: selectedBarId,
          hint: Text(
            'Selecciona un bar',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          isExpanded: true,
          dropdownColor: primaryDark,
          underline: const SizedBox(),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: accentAmber,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.store, color: accentAmber, size: 20),
                  const SizedBox(width: 12),
                  const Text('Todos los bares'),
                ],
              ),
            ),
            ...barsState.bars.map((bar) {
              return DropdownMenuItem<String?>(
                value: bar.id,
                child: Row(
                  children: [
                    Icon(Icons.storefront, color: accentGold, size: 20),
                    const SizedBox(width: 12),
                    Text(bar.nameBar),
                  ],
                ),
              );
            }),
          ],
          onChanged: (barId) {
            setState(() {
              selectedBarId = barId;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent(PromotionsState state, List<PromotionSimple> promotions) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: accentAmber,
        ),
      );
    }

    if (promotions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(promotionsControllerProvider.notifier).loadMyPromotions();
      },
      color: accentAmber,
      backgroundColor: primaryDark,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: promotions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final promotion = promotions[index];
          return _buildPromotionCard(promotion);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: promoAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 80,
                color: promoAccent.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              selectedBarId != null
                  ? 'No hay promociones para este bar'
                  : 'No tienes promociones creadas',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              selectedBarId != null
                  ? 'Crea tu primera promoción para este bar'
                  : 'Selecciona un bar y crea tu primera promoción',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedBarId != null) ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentAmber, accentGold],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentAmber.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/owner/promotions/create/$selectedBarId'),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_business, color: Colors.black),
                          SizedBox(width: 12),
                          Text(
                            'Crear Promoción',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(PromotionSimple promotionSimple) {
    // Convert to Promotion for display
    final promotion = _convertToPromotion(promotionSimple);
    final barsState = ref.watch(barsControllerProvider);

    // Encontrar el bar correspondiente
    final bar = barsState.bars.firstWhere(
      (b) => b.id == promotion.barId,
      orElse: () => barsState.bars.first,
    );

    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    final isExpired = now.isAfter(promotion.endDate);
    final isActive = promotion.status == PromotionStatus.active && !isExpired;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive 
              ? promoAccent.withOpacity(0.3) 
              : accentAmber.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: promoAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: promoAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.storefront,
                          size: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bar.nameBar,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Estado
              _buildStatusBadge(isExpired, isActive, promotion.status),
            ],
          ),
          if (promotion.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              promotion.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (promotion.discountPercentage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [promoAccent, Color(0xFFF472B6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${promotion.discountPercentage}% OFF',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '${dateFormat.format(promotion.startDate)} - ${dateFormat.format(promotion.endDate)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Ver promoción
              _buildActionButton(
                icon: Icons.visibility,
                color: const Color(0xFF10B981),
                tooltip: 'Ver promoción',
                onTap: () => context.push(
                  '/owner/promotions/${promotion.id}/preview',
                  extra: promotion,
                ),
              ),
              const SizedBox(width: 8),
              // Editar
              _buildActionButton(
                icon: Icons.edit,
                color: accentAmber,
                tooltip: 'Editar',
                onTap: () => context.showInfoSnackBar('Editar promoción - En desarrollo'),
              ),
              const SizedBox(width: 8),
              // Eliminar
              _buildActionButton(
                icon: Icons.delete_outline,
                color: const Color(0xFFEF4444),
                tooltip: 'Eliminar',
                onTap: () => _showDeleteConfirmation(promotion),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired, bool isActive, PromotionStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    if (isExpired) {
      bgColor = Colors.grey.withOpacity(0.2);
      textColor = Colors.grey.shade400;
      text = 'Expirada';
    } else if (isActive) {
      bgColor = const Color(0xFF10B981).withOpacity(0.15);
      textColor = const Color(0xFF10B981);
      text = 'Activa';
    } else {
      bgColor = accentAmber.withOpacity(0.15);
      textColor = accentAmber;
      text = 'Pausada';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Promotion _convertToPromotion(PromotionSimple simple) {
    return Promotion(
      id: simple.id,
      title: simple.title,
      description: simple.description ?? '',
      type: PromotionType.discount,
      status: simple.isActive ? PromotionStatus.active : PromotionStatus.paused,
      barId: simple.barId,
      image: simple.photoUrl,
      images: simple.photoUrl != null ? [simple.photoUrl!] : [],
      discountPercentage: simple.discountPercentage,
      discountAmount: null,
      minimumPurchase: null,
      startDate: simple.validFrom,
      endDate: simple.validUntil,
      applicableItems: const [],
      applicableCategories: const [],
      maxUses: null,
      currentUses: 0,
      daysOfWeek: const [],
      startTime: null,
      endTime: null,
      requiresCode: false,
      promotionCode: null,
      createdAt: simple.createdAt,
      updatedAt: simple.updatedAt,
    );
  }

  void _showDeleteConfirmation(Promotion promotion) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accentAmber.withOpacity(0.2),
          ),
        ),
        title: const Text(
          'Eliminar Promoción',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la promoción "${promotion.title}"? Esta acción no se puede deshacer.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  try {
                    await ref
                        .read(promotionsControllerProvider.notifier)
                        .deletePromotion(promotion.id);

                    if (mounted) {
                      context.showSuccessSnackBar('Promoción eliminada exitosamente');
                    }
                  } catch (e) {
                    if (mounted) {
                      context.showErrorSnackBar('Error al eliminar promoción');
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Eliminar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
