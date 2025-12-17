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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escribir Reseña'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del bar
            Text(
              widget.barName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Qué te pareció este lugar?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Rating
            const Text(
              'Tu valoración',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: StarRatingInput(
                rating: _rating,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
                size: 48,
              ),
            ),
            if (_rating > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getRatingText(_rating),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Comentario
            const Text(
              'Tu comentario',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mínimo 10 caracteres',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Publicar Reseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
