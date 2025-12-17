import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/network/dio_client.dart';
import '../models/review_models.dart';

/// Provider para el servicio de reseñas
final reviewsServiceProvider = Provider<ReviewsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReviewsServiceImpl(dioClient);
});

/// Interfaz del servicio de reseñas
abstract class ReviewsService {
  /// Crear una nueva reseña
  Future<Either<Failure, Review>> createReview(CreateReviewDto dto);

  /// Obtener reseñas de un bar
  Future<Either<Failure, List<Review>>> getBarReviews(String barId);

  /// Obtener estadísticas de un bar
  Future<Either<Failure, ReviewStats>> getBarStats(String barId);

  /// Obtener mis reseñas
  Future<Either<Failure, List<Review>>> getMyReviews();

  /// Obtener reseñas de mis bares (para owners)
  Future<Either<Failure, List<Review>>> getMyBarsReviews();

  /// Actualizar mi reseña
  Future<Either<Failure, Review>> updateReview(String id, UpdateReviewDto dto);

  /// Eliminar mi reseña
  Future<Either<Failure, void>> deleteReview(String id);

  /// Responder a una reseña (owner)
  Future<Either<Failure, Review>> addOwnerResponse(String id, OwnerResponseDto dto);
}

/// Implementación del servicio de reseñas
class ReviewsServiceImpl implements ReviewsService {
  final DioClient _dioClient;

  ReviewsServiceImpl(this._dioClient);

  @override
  Future<Either<Failure, Review>> createReview(CreateReviewDto dto) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/reviews',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final reviewJson = response.data!['review'] as Map<String, dynamic>;
        return Right(Review.fromJson(reviewJson));
      }

      return const Left(ServerFailure(
        message: 'Error al crear la reseña',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getBarReviews(String barId) async {
    try {
      print('🔍 ReviewsService.getBarReviews - barId: $barId');
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/reviews/bar/$barId',
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final reviewsList = response.data!['reviews'] as List;
        print('🔍 Reviews count from backend: ${reviewsList.length}');
        final reviews = reviewsList
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
        print('🔍 Reviews parsed successfully: ${reviews.length}');
        return Right(reviews);
      }

      return const Left(ServerFailure(
        message: 'Error al obtener reseñas',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e) {
      print('❌ Exception: $e');
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewStats>> getBarStats(String barId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/reviews/bar/$barId/stats',
      );

      if (response.statusCode == 200 && response.data != null) {
        return Right(ReviewStats.fromJson(response.data!));
      }

      return const Left(ServerFailure(
        message: 'Error al obtener estadísticas',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getMyReviews() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/reviews/my-reviews',
      );

      if (response.statusCode == 200 && response.data != null) {
        final reviewsList = response.data!['reviews'] as List;
        final reviews = reviewsList
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(reviews);
      }

      return const Left(ServerFailure(
        message: 'Error al obtener mis reseñas',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getMyBarsReviews() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/reviews/my-bars',
      );

      if (response.statusCode == 200 && response.data != null) {
        final reviewsList = response.data!['reviews'] as List;
        final reviews = reviewsList
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(reviews);
      }

      return const Left(ServerFailure(
        message: 'Error al obtener reseñas de mis bares',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview(String id, UpdateReviewDto dto) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        '/reviews/$id',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final reviewJson = response.data!['review'] as Map<String, dynamic>;
        return Right(Review.fromJson(reviewJson));
      }

      return const Left(ServerFailure(
        message: 'Error al actualizar reseña',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String id) async {
    try {
      final response = await _dioClient.delete<Map<String, dynamic>>(
        '/reviews/$id',
      );

      if (response.statusCode == 200) {
        return const Right(null);
      }

      return const Left(ServerFailure(
        message: 'Error al eliminar reseña',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> addOwnerResponse(String id, OwnerResponseDto dto) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/reviews/$id/response',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final reviewJson = response.data!['review'] as Map<String, dynamic>;
        return Right(Review.fromJson(reviewJson));
      }

      return const Left(ServerFailure(
        message: 'Error al añadir respuesta',
        statusCode: 500,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode ?? 500;
      final data = e.response?.data;
      String message = 'Error del servidor';

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'] is List
            ? (data['message'] as List).first.toString()
            : data['message'].toString();
      }

      return ServerFailure(message: message, statusCode: statusCode);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ConnectionFailure(message: 'Tiempo de conexión agotado');
    }

    return ConnectionFailure(message: e.message ?? 'Error de conexión');
  }
}
