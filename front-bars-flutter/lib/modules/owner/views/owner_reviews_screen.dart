import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reviews/controllers/reviews_controller.dart';
import '../../reviews/models/review_models.dart';
import '../../reviews/views/reviews_widgets.dart';

/// Pantalla para que el owner vea y responda las reseñas de sus bares
/// Rediseñada con tema oscuro premium
class OwnerReviewsScreen extends ConsumerStatefulWidget {
  const OwnerReviewsScreen({super.key});

  @override
  ConsumerState<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends ConsumerState<OwnerReviewsScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);
  
  // Color accent para reseñas (rosa/estrella)
  static const reviewAccent = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(reviewsControllerProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con estilo premium
            _buildHeader(reviewsState.reviews.length),
            
            // Body
            Expanded(
              child: _buildBody(reviewsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int reviewCount) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: reviewAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star,
              color: reviewAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [accentAmber, accentGold],
                  ).createShader(bounds),
                  child: const Text(
                    'Reseñas de mis Bares',
                    style: TextStyle(
                      fontSize: 22,
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
                        color: reviewAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$reviewCount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: reviewAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reviewCount == 1 ? 'reseña total' : 'reseñas totales',
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
          // Botón refresh
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.refresh,
                  color: accentAmber,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ReviewsState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: accentAmber),
      );
    }

    if (state.hasError) {
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
            Text(
              state.errorMessage ?? 'Error al cargar reseñas',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPrimaryButton(
              icon: Icons.refresh,
              label: 'Reintentar',
              onTap: () {
                ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
              },
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: reviewAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 80,
                color: reviewAccent.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin reseñas aún',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando los clientes dejen reseñas,\naparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Agrupar reseñas por bar
    final reviewsByBar = <String, List<Review>>{};
    for (final review in state.reviews) {
      final barName = review.bar?.nameBar ?? 'Bar desconocido';
      reviewsByBar.putIfAbsent(barName, () => []).add(review);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
      },
      color: accentAmber,
      backgroundColor: primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: reviewsByBar.length,
        itemBuilder: (context, index) {
          final barName = reviewsByBar.keys.elementAt(index);
          final reviews = reviewsByBar[barName]!;

          return _buildBarSection(barName, reviews);
        },
      ),
    );
  }

  Widget _buildBarSection(String barName, List<Review> reviews) {
    // Calcular promedio
    final avgRating = reviews.isNotEmpty
        ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
        : 0.0;

    // Contar sin responder
    final pendingCount = reviews.where((r) => !r.hasOwnerResponse).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryDark,
                  secondaryDark.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentAmber.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StarRating(rating: avgRating.round(), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${avgRating.toStringAsFixed(1)} • ${reviews.length} reseñas',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentAmber, accentGold],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$pendingCount pendientes',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Lista de reseñas
          ...reviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReviewCard(review),
              )),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: review.hasOwnerResponse
              ? const Color(0xFF10B981).withOpacity(0.3)
              : accentAmber.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [reviewAccent, Color(0xFFF472B6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    (review.user?.fullName ?? 'C')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.fullName ?? 'Cliente',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        StarRating(rating: review.rating, size: 14),
                        const SizedBox(width: 8),
                        if (review.hasOwnerResponse)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Respondida',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
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
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          if (review.ownerResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu respuesta',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.ownerResponse!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!review.hasOwnerResponse) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActionButton(
                icon: Icons.reply,
                label: 'Responder',
                color: accentAmber,
                onTap: () => _showReplyDialog(review),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(Review review) {
    final controller = TextEditingController();

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
          'Responder a la reseña',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar reseña original
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.user?.fullName ?? 'Cliente',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      StarRating(rating: review.rating, size: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Campo de respuesta
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 300,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe tu respuesta...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: secondaryDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentAmber, width: 2),
                ),
                counterStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
                colors: [accentAmber, accentGold],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (controller.text.trim().length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'La respuesta debe tener al menos 10 caracteres',
                        ),
                        backgroundColor: accentAmber,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  final success = await ref
                      .read(reviewsControllerProvider.notifier)
                      .addOwnerResponse(review.id!, controller.text.trim());

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('¡Respuesta enviada!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    ref
                        .read(reviewsControllerProvider.notifier)
                        .loadMyBarsReviews();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Enviar',
                    style: TextStyle(
                      color: Colors.black,
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
