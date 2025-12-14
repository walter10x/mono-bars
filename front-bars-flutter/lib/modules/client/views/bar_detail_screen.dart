import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/bars/models/bar_models.dart';
import 'package:front_bars_flutter/core/utils/image_url_helper.dart';
import 'package:front_bars_flutter/modules/menus/controllers/menus_controller.dart';
import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';
import 'package:front_bars_flutter/modules/promotions/controllers/promotions_controller.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_simple_model.dart';

/// Pantalla de detalle de un bar para clientes
class BarDetailScreen extends ConsumerStatefulWidget {
  final String barId;

  const BarDetailScreen({
    super.key,
    required this.barId,
  });

  @override
  ConsumerState<BarDetailScreen> createState() => _BarDetailScreenState();
}

class _BarDetailScreenState extends ConsumerState<BarDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // DEBUG: Mostrar el barId que estamos usando
    print('╔════════════════════════════════════════╗');
    print('║  BAR DETAIL SCREEN - INIT STATE       ║');
    print('╠════════════════════════════════════════╣');
    print('║  Bar ID: ${widget.barId}');
    print('╚════════════════════════════════════════╝');
    
    // Cargar el bar específico y sus menús
    Future.microtask(() {
      print('🔵 Cargando bar: ${widget.barId}');
      ref.read(barsControllerProvider.notifier).loadBar(widget.barId);
      
      print('🔵 Cargando menús para bar: ${widget.barId}');
      ref.read(menusControllerProvider.notifier).loadMenusByBar(widget.barId);
      
      print('🔵 Cargando promociones para bar: ${widget.barId}');
      ref.read(promotionsControllerProvider.notifier).loadPromotionsByBar(widget.barId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final bar = barsState.selectedBar;
    
    // IMPORTANTE: Escuchar cambios en menús y promociones para forzar rebuild
    final menusState = ref.watch(menusControllerProvider);
    final promotionsState = ref.watch(promotionsControllerProvider);
    print('🔄 BarDetailScreen.build() - Menus: ${menusState.menus.length}, Promotions: ${promotionsState.promotions.length}');

    // Estado de carga
    if (barsState.status == BarsStatus.loading || bar == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    // Estado de error
    if (barsState.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                barsState.errorMessage ?? 'Error al cargar el bar',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          _buildSliverAppBar(bar),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica
                _buildBasicInfo(bar),

                const SizedBox(height: 16),

                // Tabs
                _buildTabs(),

                const SizedBox(height: 16),

                // Contenido de los tabs
                _buildTabContent(bar),

                const SizedBox(height: 100), // Espacio para el botón flotante
              ],
            ),
          ),
        ],
      ),

      // Botón flotante de reservar
      bottomNavigationBar: _buildReserveButton(bar),
    );
  }

  Widget _buildSliverAppBar(Bar bar) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Agregar a favoritos
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favoritos próximamente')),
            );
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Compartir
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen o placeholder
            if (bar.photo != null && bar.photo!.isNotEmpty)
              Image.network(
                ImageUrlHelper.getFullImageUrl(bar.photo),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            else
              _buildImagePlaceholder(),

            // Gradiente oscuro
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
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
      color: const Color(0xFF6366F1),
      child: Center(
        child: Icon(
          Icons.storefront,
          size: 100,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(Bar bar) {
    // Calcular rating simulado
    final rating = 4.0 + (bar.id.hashCode % 10) / 10;
    final reviews = 50 + (bar.id.hashCode % 200);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del bar
          Text(
            bar.nameBar,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 12),

          // Ubicación
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bar.location,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating y estado
          Row(
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Estado (simulado por ahora)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bar.isActive
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: bar.isActive
                          ? const Color(0xFF10B981)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bar.isActive ? 'Abierto' : 'Cerrado',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: bar.isActive
                            ? const Color(0xFF10B981)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Teléfono si existe
              if (bar.phone != null && bar.phone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.phone),
                  color: const Color(0xFF6366F1),
                  onPressed: () {
                    // TODO: Llamar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Llamar a ${bar.phone}')),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Menú'),
          Tab(text: 'Promociones'),
          Tab(text: 'Ubicación'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Bar bar) {
    return Consumer(
      builder: (context, ref, child) {
        final menusState = ref.watch(menusControllerProvider);
        
        print('🔄 _buildTabContent rebuilding - Menus: ${menusState.menus.length}');
        
        return SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(bar),
              _buildMenuTab(bar),
              _buildPromotionsTab(bar),
              _buildLocationTab(bar),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(Bar bar) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descripción
          const Text(
            'Sobre este bar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bar.description ?? 'Un excelente lugar para disfrutar.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Horarios si existen
          if (bar.hours != null) ...[
            const Text(
              'Horarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            _buildHoursInfo(bar.hours!),
          ],

          const SizedBox(height: 24),

          // Redes sociales
          if (bar.socialLinks != null &&
              (bar.socialLinks!.facebook != null ||
                  bar.socialLinks!.instagram != null)) ...[
            const Text(
              'Síguenos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (bar.socialLinks!.facebook != null)
                  IconButton(
                    icon: const Icon(Icons.facebook),
                    color: const Color(0xFF1877F2),
                    onPressed: () {},
                  ),
                if (bar.socialLinks!.instagram != null)
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    color: const Color(0xFFE4405F),
                    onPressed: () {},
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHoursInfo(WeekHours hours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (hours.monday != null)
            _buildHourRow('Lunes', hours.monday!),
          if (hours.tuesday != null)
            _buildHourRow('Martes', hours.tuesday!),
          if (hours.wednesday != null)
            _buildHourRow('Miércoles', hours.wednesday!),
          if (hours.thursday != null)
            _buildHourRow('Jueves', hours.thursday!),
          if (hours.friday != null)
            _buildHourRow('Viernes', hours.friday!),
          if (hours.saturday != null)
            _buildHourRow('Sábado', hours.saturday!),
          if (hours.sunday != null)
            _buildHourRow('Domingo', hours.sunday!),
        ],
      ),
    );
  }

  Widget _buildHourRow(String day, DayHours dayHours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${dayHours.open ?? '--'} - ${dayHours.close ?? '--'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab(Bar bar) {
    final menusState = ref.watch(menusControllerProvider);

    // Debug: Verificar estado
    print('═══════════════════════════════════════');
    print('🍽️  MENU TAB RENDERING');
    print('═══════════════════════════════════════');
    print('Status: ${menusState.status}');
    print('Menus count: ${menusState.menus.length}');
    print('Has error: ${menusState.hasError}');
    if (menusState.hasError) {
      print('Error message: ${menusState.errorMessage}');
    }
    print('═══════════════════════════════════════');

    // Si hay menús, mostrarlos INMEDIATAMENTE
    if (menusState.menus.isNotEmpty) {
      print('✅ MOSTRANDO ${menusState.menus.length} MENÚS');
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: menusState.menus.map((menu) {
            print('   Renderizando: ${menu.name}');
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMenuCard(menu),
            );
          }).toList(),
        ),
      );
    }

    // Estado de carga
    if (menusState.status == MenusStatus.loading) {
      print('⏳ MOSTRANDO LOADING');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    // Estado de error
    if (menusState.hasError) {
      print('❌ MOSTRANDO ERROR');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar menús',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                menusState.errorMessage ?? 'Error desconocido',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(menusControllerProvider.notifier).loadMenusByBar(bar.id);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si llegamos aquí, está vacío
    print('📭 MOSTRANDO VACÍO');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin menús disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este bar aún no ha publicado su menú',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del menú
          if (menu.photoUrl != null && menu.photoUrl!.isNotEmpty)
            Container(
              height: 120,
              width: double.infinity,
              child: Image.network(
                ImageUrlHelper.getFullImageUrl(menu.photoUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFF6366F1).withOpacity(0.1),
              child: Icon(
                Icons.restaurant_menu,
                size: 48,
                color: const Color(0xFF6366F1).withOpacity(0.5),
              ),
            ),

          // Información del menú
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del menú
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 8),

                // Descripción
                if (menu.description != null && menu.description!.isNotEmpty)
                  Text(
                    menu.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Botón ver menú completo
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        '/client/menu/${menu.id}',
                        extra: menu,
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver Menú Completo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildPromotionsTab(Bar bar) {
    final promotionsState = ref.watch(promotionsControllerProvider);

    // Debug: Verificar estado
    print('═══════════════════════════════════════');
    print('🎁  PROMOTIONS TAB RENDERING');
    print('═══════════════════════════════════════');
    print('Loading: ${promotionsState.isLoading}');
    print('Promotions count: ${promotionsState.promotions.length}');
    print('Has error: ${promotionsState.error != null}');
    if (promotionsState.error != null) {
      print('Error message: ${promotionsState.error}');
    }
    print('═══════════════════════════════════════');

    // Si hay promociones, mostrarlas INMEDIATAMENTE
    if (promotionsState.promotions.isNotEmpty) {
      print('✅ MOSTRANDO ${promotionsState.promotions.length} PROMOCIONES');
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: promotionsState.promotions.map((promotion) {
            print('   Renderizando: ${promotion.title}');
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPromotionCard(promotion),
            );
          }).toList(),
        ),
      );
    }

    // Estado de carga
    if (promotionsState.isLoading) {
      print('⏳ MOSTRANDO LOADING');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    // Estado de error
    if (promotionsState.error != null) {
      print('❌ MOSTRANDO ERROR');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar promociones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                promotionsState.error ?? 'Error desconocido',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(promotionsControllerProvider.notifier).loadPromotionsByBar(bar.id);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si llegamos aquí, está vacío
    print('📭 MOSTRANDO VACÍO');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin promociones activas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este bar no tiene promociones en este momento',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(PromotionSimple promotion) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          // Imagen de la promoción
          if (promotion.photoUrl != null && promotion.photoUrl!.isNotEmpty)
            Container(
              height: 160,
              width: double.infinity,
              child: Image.network(
                ImageUrlHelper.getFullImageUrl(promotion.photoUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    child: Icon(
                      Icons.local_offer,
                      size: 64,
                      color: const Color(0xFFF59E0B).withOpacity(0.5),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.7),
                    const Color(0xFFEF4444).withOpacity(0.7),
                  ],
                ),
              ),
              child: const Icon(
                Icons.local_offer,
                size: 64,
                color: Colors.white,
              ),
            ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de descuento
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${promotion.discountPercentage?.toStringAsFixed(0) ?? "0"}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Título
                Text(
                  promotion.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Descripción
                if (promotion.description != null && promotion.description!.isNotEmpty)
                  Text(
                    promotion.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Fechas
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Válido hasta: ${_formatDate(promotion.validUntil)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón ver promoción completa
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        '/client/promotion/${promotion.id}',
                        extra: promotion,
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver Promoción Completa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildLocationTab(Bar bar) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dirección
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF6366F1),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dirección',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bar.location,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón para abrir en mapas
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Abrir en Google Maps
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrir en mapas próximamente')),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Cómo llegar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Placeholder para mapa
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa próximamente',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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

  Widget _buildReserveButton(Bar bar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navegar al formulario de reserva con el bar preseleccionado
              context.push(
                '/client/reservations/create?barId=${bar.id}',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.event_seat,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'RESERVAR MESA',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
