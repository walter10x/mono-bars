import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/core/utils/image_url_helper.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/bars/models/bar_models.dart';

/// Pantalla de vista previa del bar (solo lectura)
class BarPreviewScreen extends ConsumerStatefulWidget {
  final String barId;

  const BarPreviewScreen({
    super.key,
    required this.barId,
  });

  @override
  ConsumerState<BarPreviewScreen> createState() => _BarPreviewScreenState();
}

class _BarPreviewScreenState extends ConsumerState<BarPreviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadBar(widget.barId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final bar = barsState.selectedBar;

    if (barsState.isLoading || bar == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                bar.nameBar,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              background: bar.photo != null && bar.photo!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullImageUrl(bar.photo),
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.push('/owner/bars/${widget.barId}/edit');
                },
                icon: const Icon(Icons.edit),
                tooltip: 'Editar',
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
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bar.isActive
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bar.isActive ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: bar.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bar.isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: bar.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ubicación
                  _buildSection(
                    title: 'Ubicación',
                    icon: Icons.location_on,
                    child: Text(
                      bar.location,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),

                  if (bar.description != null && bar.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Descripción',
                      icon: Icons.description,
                      child: Text(
                        bar.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],

                  // Contacto
                  if (bar.phone != null && bar.phone!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Contacto',
                      icon: Icons.phone,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 20,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bar.phone!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Redes sociales
                  if (bar.socialLinks != null &&
                      (bar.socialLinks!.facebook != null ||
                          bar.socialLinks!.instagram != null)) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Redes Sociales',
                      icon: Icons.share,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (bar.socialLinks!.facebook != null) ...[
                            _buildSocialLink(
                              'Facebook',
                              Icons.facebook,
                              bar.socialLinks!.facebook!,
                            ),
                          ],
                          if (bar.socialLinks!.instagram != null) ...[
                            if (bar.socialLinks!.facebook != null)
                              const SizedBox(height: 12),
                            _buildSocialLink(
                              'Instagram',
                              Icons.camera_alt,
                              bar.socialLinks!.instagram!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Horarios
                  if (bar.hours != null && _hasHours(bar.hours!)) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Horarios',
                      icon: Icons.access_time,
                      child: Column(
                        children: _buildHoursList(bar.hours!),
                      ),
                    ),
                  ],
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
      color: const Color(0xFF6366F1),
      child: const Center(
        child: Icon(
          Icons.storefront,
          size: 80,
          color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
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

  Widget _buildSocialLink(String name, IconData icon, String url) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasHours(WeekHours hours) {
    return hours.monday != null ||
        hours.tuesday != null ||
        hours.wednesday != null ||
        hours.thursday != null ||
        hours.friday != null ||
        hours.saturday != null ||
        hours.sunday != null;
  }

  List<Widget> _buildHoursList(WeekHours hours) {
    final days = {
      'Lunes': hours.monday,
      'Martes': hours.tuesday,
      'Miércoles': hours.wednesday,
      'Jueves': hours.thursday,
      'Viernes': hours.friday,
      'Sábado': hours.saturday,
      'Domingo': hours.sunday,
    };

    final widgets = <Widget>[];
    days.forEach((dayName, dayHours) {
      if (dayHours != null) {
        widgets.add(_buildDayHour(dayName, dayHours));
        widgets.add(const SizedBox(height: 8));
      }
    });

    if (widgets.isNotEmpty) {
      widgets.removeLast(); // Remove last SizedBox
    }

    return widgets;
  }

  Widget _buildDayHour(String dayName, DayHours hours) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            '${hours.open} - ${hours.close}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
