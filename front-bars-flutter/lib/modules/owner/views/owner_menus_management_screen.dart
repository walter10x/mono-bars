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
class OwnerMenusManagementScreen extends ConsumerStatefulWidget {
  const OwnerMenusManagementScreen({super.key});

  @override
  ConsumerState<OwnerMenusManagementScreen> createState() =>
      _OwnerMenusManagementScreenState();
}

class _OwnerMenusManagementScreenState
    extends ConsumerState<OwnerMenusManagementScreen> {
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menús',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gestiona tus cartas y productos',
                          style: TextStyle(
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
                              // Navegar a crear menú con bar pre-seleccionado
                              context.push('/owner/menus/create/$selectedBarId');
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
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
                      dropdownColor: const Color(0xFF6366F1),
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
                        if (barId == null) {
                          // Cargar todos los menús
                          ref
                              .read(menusControllerProvider.notifier)
                              .loadMyMenus();
                          ref
                              .read(menusControllerProvider.notifier)
                              .selectBar(null);
                        } else {
                          // Filtrar por bar
                          ref.read(menusControllerProvider.notifier).selectBar(barId);
                        }
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Lista de menús
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(menusState.status, menus),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MenusStatus status, List<Menu> menus) {
    if (status == MenusStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (status == MenusStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar menús',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final selectedBarId = ref.read(selectedBarIdProvider);
                if (selectedBarId != null) {
                  ref
                      .read(menusControllerProvider.notifier)
                      .loadMenusByBar(selectedBarId);
                } else {
                  ref.read(menusControllerProvider.notifier).loadMyMenus();
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
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
      child: ListView.separated(
        padding: const EdgeInsets.all(24.0),
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
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              selectedBarId != null
                  ? 'No hay menús para este bar'
                  : 'No tienes menús creados',
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
                  ? 'Crea tu primer menú para este bar'
                  : 'Selecciona un bar y crea tu primer menú',
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
                  context.push('/owner/menus/create/$selectedBarId');
                },
                icon: const Icon(Icons.add_business),
                label: const Text('Crear Menú'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
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

  Widget _buildMenuCard(Menu menu) {
    final barsState = ref.watch(barsControllerProvider);
    
    // Encontrar el bar correspondiente
    final bar = barsState.bars.firstWhere(
      (b) => b.id == menu.barId,
      orElse: () => barsState.bars.first,
    );

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con imagen del menú
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: menu.photoUrl != null && menu.photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullImageUrl(menu.photoUrl),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        ),
                      ),
                      errorWidget: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: const Color(0xFF8B5CF6).withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
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
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bar.nameBar,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (menu.description != null && menu.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    menu.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${menu.itemCount} productos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
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
                    IconButton(
                      onPressed: () {
                        context.push('/owner/menus/${menu.id}/preview');
                      },
                      icon: const Icon(Icons.visibility),
                      color: const Color(0xFF10B981),
                      tooltip: 'Ver detalles',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón Editar
                    IconButton(
                      onPressed: () {
                        context.push('/owner/menus/${menu.id}/edit');
                      },
                      icon: const Icon(Icons.edit),
                      color: const Color(0xFF6366F1),
                      tooltip: 'Editar menú',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón Eliminar
                    IconButton(
                      onPressed: () {
                        _showDeleteConfirmation(menu);
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0xFFEF4444),
                      tooltip: 'Eliminar menú',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

  void _showDeleteConfirmation(Menu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Menú'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el menú "${menu.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await ref
                  .read(menusControllerProvider.notifier)
                  .deleteMenu(menu.id);

              if (success && mounted) {
                context.showSuccessSnackBar('Menú eliminado exitosamente');
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
