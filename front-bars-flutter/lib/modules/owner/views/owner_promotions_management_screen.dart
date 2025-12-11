import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/promotions/controllers/promotions_controller.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_models.dart';

/// Pantalla de gestión de promociones para propietarios
class OwnerPromotionsManagementScreen extends ConsumerStatefulWidget {
  const OwnerPromotionsManagementScreen({super.key});

  @override
  ConsumerState<OwnerPromotionsManagementScreen> createState() =>
      _OwnerPromotionsManagementScreenState();
}

class _OwnerPromotionsManagementScreenState
    extends ConsumerState<OwnerPromotionsManagementScreen> {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEC4899),
              Color(0xFFF97316),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
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
                        const Text(
                          'Promociones',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredPromotions.length} ${filteredPromotions.length == 1 ? 'promoción' : 'promociones'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: selectedBarId == null
                          ? null
                          : () {
                              context.push('/owner/promotions/create/$selectedBarId');
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEC4899),
                        disabledBackgroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Selector de Bar
              if (barsState.status == BarsStatus.loaded &&
                  barsState.bars.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String?>(
                      value: selectedBarId,
                      hint: const Text(
                        'Selecciona un bar',
                        style: TextStyle(color: Colors.white70),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFFEC4899),
                      underline: const SizedBox(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos los bares'),
                        ),
                        ...barsState.bars.map((bar) {
                          return DropdownMenuItem<String?>(
                            value: bar.id,
                            child: Text(bar.nameBar),
                          );
                        }).toList(),
                      ],
                      onChanged: (barId) {
                        setState(() {
                          selectedBarId = barId;
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),

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
                  child: _buildContent(promotionsState, filteredPromotions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PromotionsState state, List<Promotion> promotions) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (promotions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(promotionsControllerProvider.notifier).loadMyPromotions();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(24.0),
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
            Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              selectedBarId != null
                  ? 'No hay promociones para este bar'
                  : 'No tienes promociones creadas',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
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
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedBarId != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/owner/promotions/create/$selectedBarId');
                },
                icon: const Icon(Icons.add_business),
                label: const Text('Crear Promoción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFFEC4899).withOpacity(0.3) : Colors.grey.shade200,
          width: isActive ? 2 : 1,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Color(0xFFEC4899),
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
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bar.nameBar,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.grey.shade100
                      : isActive
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isExpired
                      ? 'Expirada'
                      : promotion.status == PromotionStatus.active
                          ? 'Activa'
                          : 'Pausada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExpired
                        ? Colors.grey.shade700
                        : isActive
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (promotion.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              promotion.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${promotion.discountPercentage}% OFF',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC4899),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${dateFormat.format(promotion.startDate)} - ${dateFormat.format(promotion.endDate)}',
                style: TextStyle(
                  fontSize: 13,
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
                  onPressed: () {
                    // TODO: Editar promoción
                    context.showInfoSnackBar('Editar promoción - En desarrollo');
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEC4899),
                    side: const BorderSide(color: Color(0xFFEC4899)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(promotion);
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Promoción'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la promoción "${promotion.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
