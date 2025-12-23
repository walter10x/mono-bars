import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/core/utils/image_url_helper.dart';
import 'package:front_bars_flutter/modules/menus/controllers/menus_controller.dart';
import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';

/// Pantalla de vista previa del menú (solo lectura)
/// Rediseñada con tema oscuro premium
class MenuPreviewScreen extends ConsumerStatefulWidget {
  final String menuId;

  const MenuPreviewScreen({
    super.key,
    required this.menuId,
  });

  @override
  ConsumerState<MenuPreviewScreen> createState() => _MenuPreviewScreenState();
}

class _MenuPreviewScreenState extends ConsumerState<MenuPreviewScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(menusControllerProvider.notifier).loadMenu(widget.menuId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menusState = ref.watch(menusControllerProvider);
    final menu = menusState.selectedMenu;

    if (menusState.isLoading || menu == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: accentAmber),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryDark,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                menu.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  menu.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl:
                              ImageUrlHelper.getFullImageUrl(menu.photoUrl),
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          backgroundColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: () {
                    context.push('/owner/menus/${widget.menuId}/edit');
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentAmber.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: accentAmber, size: 20),
                  ),
                  tooltip: 'Editar',
                ),
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  if (menu.description != null &&
                      menu.description!.isNotEmpty) ...[
                    _buildSection(
                      title: 'Descripción',
                      icon: Icons.description,
                      child: Text(
                        menu.description!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Items del menú
                  _buildSection(
                    title: 'Productos (${menu.itemCount})',
                    icon: Icons.inventory_2,
                    child: menu.items.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: menu.items
                                .map((item) => _buildMenuItem(item))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentAmber, accentGold],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: accentAmber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentAmber.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          if (item.photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: ImageUrlHelper.getFullImageUrl(item.photoUrl),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) =>
                    _buildItemPlaceholder(),
              ),
            )
          else
            _buildItemPlaceholder(),

          const SizedBox(width: 16),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentAmber, accentGold],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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

  Widget _buildItemPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: secondaryDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
        ),
      ),
      child: Icon(
        Icons.fastfood,
        color: Colors.white.withOpacity(0.3),
        size: 28,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentAmber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: accentAmber.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este menú no tiene productos aún',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
