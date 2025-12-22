import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/reviews_controller.dart';
import '../models/review_models.dart';
import 'reviews_widgets.dart';

/// Pantalla para escribir una nueva reseña
class WriteReviewScreen extends ConsumerStatefulWidget {
  final String barId;
  final String barName;

  const WriteReviewScreen({
    super.key,
    required this.barId,
    required this.barName,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF1A1A2E);
    const backgroundDark = Color(0xFF0F0F1E);
    const cardBackground = Color(0xFF1E1E2D);
    const accentAmber = Color(0xFFFFA500);
    const accentGold = Color(0xFFFFB84D);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: const Text('Escribir Reseña'),
        centerTitle: true,
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del bar con estilo destacado
            Text(
              widget.barName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Qué te pareció este lugar?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Rating en card oscura
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Tu valoración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StarRatingInput(
                    rating: _rating,
                    onRatingChanged: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                    size: 52,
                    color: accentAmber,
                  ),
                  if (_rating > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      _getRatingText(_rating),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: accentAmber,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Comentario con estilo dark
            const Text(
              'Tu comentario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 6,
              maxLength: 500,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 15,
                ),
                filled: true,
                fillColor: cardBackground,
                counterStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: accentAmber,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mínimo 10 caracteres',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),

            // Botón enviar con gradiente
            SizedBox(
              width: double.infinity,
              child: _canSubmit()
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSubmitting ? null : _submitReview,
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentAmber,
                                accentGold,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: accentAmber.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: primaryDark,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.send_rounded,
                                        color: primaryDark,
                                        size: 22,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Publicar Reseña',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white.withOpacity(0.3),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Publicar Reseña',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.3),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _rating > 0 && 
           _commentController.text.length >= 10 && 
           !_isSubmitting;
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '😞 Muy malo';
      case 2:
        return '😕 Malo';
      case 3:
        return '😐 Regular';
      case 4:
        return '😊 Bueno';
      case 5:
        return '🤩 Excelente';
      default:
        return '';
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    final dto = CreateReviewDto(
      barId: widget.barId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    final success = await ref
        .read(reviewsControllerProvider.notifier)
        .createReview(dto);

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Gracias por tu reseña!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      context.pop(true); // Volver con resultado exitoso
    } else if (mounted) {
      final error = ref.read(reviewsControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al publicar reseña'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
