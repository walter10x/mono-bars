import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/image_url_helper.dart';
import '../../bars/controllers/bars_controller.dart';
import '../../bars/models/bar_models.dart';

/// Pantalla de gestión de bares para propietarios
/// Rediseñada con tema oscuro premium
class OwnerBarsManagementScreen extends ConsumerStatefulWidget {
  const OwnerBarsManagementScreen({super.key});

  @override
  ConsumerState<OwnerBarsManagementScreen> createState() =>
      _OwnerBarsManagementScreenState();
}

class _OwnerBarsManagementScreenState
    extends ConsumerState<OwnerBarsManagementScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  @override
  void initState() {
    super.initState();
    // Cargar bares al iniciar la pantalla
    Future.microtask(
      () => ref.read(barsControllerProvider.notifier).loadMyBars(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final bars = barsState.bars;

    // Listener para errores
    ref.listen(barsControllerProvider, (previous, current) {
      if (current.hasError) {
        context.showErrorSnackBar(current.errorMessage!);
        ref.read(barsControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con estilo premium
            _buildHeader(),

            const SizedBox(height: 24),

            // Lista de bares
            Expanded(
              child: _buildContent(barsState.status, bars),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                    'Mis Bares',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tus establecimientos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentAmber, accentGold],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentAmber.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/owner/bars/create'),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Nuevo',
                        style: TextStyle(
                          color: Colors.black,
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

  Widget _buildContent(BarsStatus status, List<Bar> bars) {
    if (status == BarsStatus.loading && bars.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: accentAmber,
        ),
      );
    }

    if (status == BarsStatus.error && bars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar bares',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta de nuevo más tarde',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentAmber, accentGold],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref.read(barsControllerProvider.notifier).loadMyBars();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Reintentar',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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

    if (bars.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: accentAmber.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Aún no tienes bares!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Comienza agregando tu primer bar para gestionar tu negocio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
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
                    onTap: () => context.push('/owner/bars/create'),
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
                            'Crear Mi Primer Bar',
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
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(barsControllerProvider.notifier).loadMyBars();
      },
      color: accentAmber,
      backgroundColor: primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: bars.length,
        itemBuilder: (context, index) {
          final bar = bars[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBarCard(bar),
          );
        },
      ),
    );
  }

  Widget _buildBarCard(Bar bar) {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
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
          // Imagen del bar
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: secondaryDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: bar.photo != null && bar.photo!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullImageUrl(bar.photo),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: accentAmber.withOpacity(0.5),
                        ),
                      ),
                      errorWidget: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.storefront,
                            size: 64,
                            color: accentAmber.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.storefront,
                      size: 64,
                      color: accentAmber.withOpacity(0.3),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bar.isActive
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFFEF4444).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: bar.isActive
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFEF4444).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        bar.isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: bar.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bar.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                if (bar.description != null && bar.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bar.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
                if (bar.phone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bar.phone!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Ver
                    _buildActionButton(
                      icon: Icons.visibility,
                      color: const Color(0xFF10B981),
                      tooltip: 'Ver detalles',
                      onTap: () => context.push('/owner/bars/${bar.id}/preview'),
                    ),
                    const SizedBox(width: 8),
                    // Botón Editar
                    _buildActionButton(
                      icon: Icons.edit,
                      color: accentAmber,
                      tooltip: 'Editar bar',
                      onTap: () => context.push('/owner/bars/${bar.id}/edit'),
                    ),
                    const SizedBox(width: 8),
                    // Botón Eliminar
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: const Color(0xFFEF4444),
                      tooltip: 'Eliminar bar',
                      onTap: () => _showDeleteConfirmation(bar),
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

  void _showDeleteConfirmation(Bar bar) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: accentAmber.withOpacity(0.2),
            ),
          ),
          title: const Text(
            'Eliminar Bar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${bar.nameBar}"?\n\nEsta acción no se puede deshacer.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
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
                    final success = await ref
                        .read(barsControllerProvider.notifier)
                        .deleteBar(bar.id);
                    if (success && mounted) {
                      context.showSuccessSnackBar(
                        'Bar eliminado exitosamente',
                      );
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
        );
      },
    );
  }
}
