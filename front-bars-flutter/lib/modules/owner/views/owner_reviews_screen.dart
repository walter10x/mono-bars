import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reviews/controllers/reviews_controller.dart';
import '../../reviews/models/review_models.dart';
import '../../reviews/views/reviews_widgets.dart';

/// Pantalla para que el owner vea y responda las reseñas de sus bares
class OwnerReviewsScreen extends ConsumerStatefulWidget {
  const OwnerReviewsScreen({super.key});

  @override
  ConsumerState<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends ConsumerState<OwnerReviewsScreen> {
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
      appBar: AppBar(
        title: const Text('Reseñas de mis bares'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
            },
          ),
        ],
      ),
      body: _buildBody(reviewsState),
    );
  }

  Widget _buildBody(ReviewsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Error al cargar reseñas',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
              },
              child: const Text('Reintentar'),
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
            Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Sin reseñas aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando los clientes dejen reseñas,\naparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StarRating(rating: avgRating.round(), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${avgRating.toStringAsFixed(1)} • ${reviews.length} reseñas',
                            style: const TextStyle(
                              color: Colors.white70,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$pendingCount pendientes',
                      style: const TextStyle(
                        color: Colors.white,
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
            child: ReviewCard(
              review: review,
              isOwner: true,
              onReplyTap: () => _showReplyDialog(review),
            ),
          )).toList(),
        ],
      ),
    );
  }

  void _showReplyDialog(Review review) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder a la reseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar reseña original
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.user?.fullName ?? 'Cliente',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                      color: Colors.grey.shade700,
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
              decoration: InputDecoration(
                hintText: 'Escribe tu respuesta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La respuesta debe tener al menos 10 caracteres'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final success = await ref
                  .read(reviewsControllerProvider.notifier)
                  .addOwnerResponse(review.id!, controller.text.trim());
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Respuesta enviada!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
                // Recargar reseñas
                ref.read(reviewsControllerProvider.notifier).loadMyBarsReviews();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
