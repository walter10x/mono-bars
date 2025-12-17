import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/review_models.dart';
import '../services/reviews_service.dart';

part 'reviews_controller.g.dart';

/// Estado del controlador de reseñas
enum ReviewsStatus { initial, loading, loaded, error }

class ReviewsState {
  final ReviewsStatus status;
  final List<Review> reviews;
  final ReviewStats? stats;
  final String? errorMessage;

  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.reviews = const [],
    this.stats,
    this.errorMessage,
  });

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<Review>? reviews,
    ReviewStats? stats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isLoading => status == ReviewsStatus.loading;
  bool get hasError => status == ReviewsStatus.error;
  bool get isEmpty => reviews.isEmpty && status == ReviewsStatus.loaded;
}

/// Controlador de reseñas
@riverpod
class ReviewsController extends _$ReviewsController {
  late ReviewsService _reviewsService;

  @override
  ReviewsState build() {
    _reviewsService = ref.watch(reviewsServiceProvider);
    return const ReviewsState();
  }

  /// Cargar reseñas de un bar
  Future<void> loadBarReviews(String barId) async {
    state = state.copyWith(status: ReviewsStatus.loading);

    try {
      final result = await _reviewsService.getBarReviews(barId);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
        },
        (reviews) {
          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: reviews,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar estadísticas de un bar
  Future<void> loadBarStats(String barId) async {
    try {
      final result = await _reviewsService.getBarStats(barId);

      result.fold(
        (failure) {
          // No cambiar estado de error solo por stats
        },
        (stats) {
          state = state.copyWith(stats: stats);
        },
      );
    } catch (e) {
      // Ignorar errores de stats
    }
  }

  /// Cargar mis reseñas
  Future<void> loadMyReviews() async {
    state = state.copyWith(status: ReviewsStatus.loading);

    try {
      final result = await _reviewsService.getMyReviews();

      result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
        },
        (reviews) {
          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: reviews,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar reseñas de mis bares (owner)
  Future<void> loadMyBarsReviews() async {
    state = state.copyWith(status: ReviewsStatus.loading);

    try {
      final result = await _reviewsService.getMyBarsReviews();

      result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
        },
        (reviews) {
          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: reviews,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Crear una nueva reseña
  Future<bool> createReview(CreateReviewDto dto) async {
    state = state.copyWith(status: ReviewsStatus.loading);

    try {
      final result = await _reviewsService.createReview(dto);

      return result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
          return false;
        },
        (review) {
          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: [review, ...state.reviews],
            clearError: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualizar una reseña
  Future<bool> updateReview(String id, UpdateReviewDto dto) async {
    try {
      final result = await _reviewsService.updateReview(id, dto);

      return result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
          return false;
        },
        (updatedReview) {
          final updatedReviews = state.reviews.map((r) {
            return r.id == id ? updatedReview : r;
          }).toList();

          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: updatedReviews,
            clearError: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  /// Eliminar una reseña
  Future<bool> deleteReview(String id) async {
    try {
      final result = await _reviewsService.deleteReview(id);

      return result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
          return false;
        },
        (_) {
          final updatedReviews = state.reviews.where((r) => r.id != id).toList();

          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: updatedReviews,
            clearError: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  /// Añadir respuesta del owner
  Future<bool> addOwnerResponse(String id, String response) async {
    try {
      final dto = OwnerResponseDto(response: response);
      final result = await _reviewsService.addOwnerResponse(id, dto);

      return result.fold(
        (failure) {
          state = state.copyWith(
            status: ReviewsStatus.error,
            errorMessage: failure.message,
          );
          return false;
        },
        (updatedReview) {
          final updatedReviews = state.reviews.map((r) {
            return r.id == id ? updatedReview : r;
          }).toList();

          state = state.copyWith(
            status: ReviewsStatus.loaded,
            reviews: updatedReviews,
            clearError: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }
}
