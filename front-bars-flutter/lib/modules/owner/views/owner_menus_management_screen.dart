import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/core/utils/image_url_helper.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/menus/controllers/menus_controller.dart';
import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';

/// Pantalla de gestión de menús para propietarios
/// Rediseñada con tema oscuro premium
class OwnerMenusManagementScreen extends ConsumerStatefulWidget {
  const OwnerMenusManagementScreen({super.key});

  @override
  ConsumerState<OwnerMenusManagementScreen> createState() =>
      _OwnerMenusManagementScreenState();
}

class _OwnerMenusManagementScreenState
    extends ConsumerState<OwnerMenusManagementScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  @override
  void initState() {
    super.initState();
    // Cargar bares del owner para el selector
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadMyBars();
      // Cargar todos los menús inicialmente
      ref.read(menusControllerProvider.notifier).loadMyMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menusState = ref.watch(menusControllerProvider);
    final barsState = ref.watch(barsControllerProvider);
    final menus = ref.watch(myMenusProvider);
    final selectedBarId = ref.watch(selectedBarIdProvider);

    // Listener para errores
    ref.listen(menusControllerProvider, (previous, current) {
      if (current.hasError) {
        context.showErrorSnackBar(current.errorMessage!);
        ref.read(menusControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con estilo premium
            _buildHeader(selectedBarId),

            // Selector de Bar
            if (barsState.status == BarsStatus.loaded &&
                barsState.bars.isNotEmpty)
              _buildBarSelector(barsState, selectedBarId),

            const SizedBox(height: 16),

            // Lista de menús
            Expanded(
              child: _buildContent(menusState.status, menus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? selectedBarId) {
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
                    'Menús',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tus cartas y productos',
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
                    : () => context.push('/owner/menus/create/$selectedBarId'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: selectedBarId != null
                            ? Colors.black
                            : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nuevo',
                        style: TextStyle(
                          color: selectedBarId != null
                              ? Colors.black
                              : Colors.white54,
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

  Widget _buildBarSelector(BarsState barsState, String? selectedBarId) {
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
            if (barId == null) {
              ref.read(menusControllerProvider.notifier).loadMyMenus();
              ref.read(menusControllerProvider.notifier).selectBar(null);
            } else {
              ref.read(menusControllerProvider.notifier).selectBar(barId);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(MenusStatus status, List<Menu> menus) {
    if (status == MenusStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: accentAmber,
        ),
      );
    }

    if (status == MenusStatus.error) {
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
              'Error al cargar menús',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
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
                    final selectedBarId = ref.read(selectedBarIdProvider);
                    if (selectedBarId != null) {
                      ref
                          .read(menusControllerProvider.notifier)
                          .loadMenusByBar(selectedBarId);
                    } else {
                      ref.read(menusControllerProvider.notifier).loadMyMenus();
                    }
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

    if (menus.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final selectedBarId = ref.read(selectedBarIdProvider);
        if (selectedBarId != null) {
          await ref
              .read(menusControllerProvider.notifier)
              .loadMenusByBar(selectedBarId);
        } else {
          await ref.read(menusControllerProvider.notifier).loadMyMenus();
        }
      },
      color: accentAmber,
      backgroundColor: primaryDark,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: menus.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final menu = menus[index];
          return _buildMenuCard(menu);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final selectedBarId = ref.watch(selectedBarIdProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
                Icons.restaurant_menu,
                size: 80,
                color: accentAmber.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              selectedBarId != null
                  ? 'No hay menús para este bar'
                  : 'No tienes menús creados',
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
                  ? 'Crea tu primer menú para este bar'
                  : 'Selecciona un bar y crea tu primer menú',
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
                    onTap: () =>
                        context.push('/owner/menus/create/$selectedBarId'),
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
                            'Crear Menú',
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

  Widget _buildMenuCard(Menu menu) {
    final barsState = ref.watch(barsControllerProvider);

    // Encontrar el bar correspondiente
    final bar = barsState.bars.firstWhere(
      (b) => b.id == menu.barId,
      orElse: () => barsState.bars.first,
    );

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
          // Header con imagen del menú
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: secondaryDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: menu.photoUrl != null && menu.photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullImageUrl(menu.photoUrl),
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
                            Icons.restaurant_menu,
                            size: 64,
                            color: accentAmber.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: accentAmber.withOpacity(0.3),
                    ),
                  ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del menú y bar
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 16,
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
                if (menu.description != null &&
                    menu.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    menu.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentAmber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentAmber.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: accentAmber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${menu.itemCount} productos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Ver
                    _buildActionButton(
                      icon: Icons.visibility,
                      color: const Color(0xFF10B981),
                      tooltip: 'Ver detalles',
                      onTap: () =>
                          context.push('/owner/menus/${menu.id}/preview'),
                    ),
                    const SizedBox(width: 8),
                    // Botón Editar
                    _buildActionButton(
                      icon: Icons.edit,
                      color: accentAmber,
                      tooltip: 'Editar menú',
                      onTap: () =>
                          context.push('/owner/menus/${menu.id}/edit'),
                    ),
                    const SizedBox(width: 8),
                    // Botón Eliminar
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: const Color(0xFFEF4444),
                      tooltip: 'Eliminar menú',
                      onTap: () => _showDeleteConfirmation(menu),
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

  void _showDeleteConfirmation(Menu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accentAmber.withOpacity(0.2),
          ),
        ),
        title: const Text(
          'Eliminar Menú',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar el menú "${menu.name}"? Esta acción no se puede deshacer.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
                  Navigator.of(context).pop();

                  final success = await ref
                      .read(menusControllerProvider.notifier)
                      .deleteMenu(menu.id);

                  if (success && mounted) {
                    context.showSuccessSnackBar('Menú eliminado exitosamente');
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
