import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/network/dio_client.dart';
import '../models/bar_models.dart';

/// Servicio para manejar operaciones de bares
abstract class BarsService {
  Future<Either<Failure, List<Bar>>> getMyBars();
  Future<Either<Failure, Bar>> getBar(String id);
  Future<Either<Failure, List<Bar>>> getAllBars();
  Future<Either<Failure, Bar>> createBar(CreateBarRequest request);
  Future<Either<Failure, Bar>> updateBar(String id, UpdateBarRequest request);
  Future<Either<Failure, void>> deleteBar(String id);
}

/// Implementación del servicio de bares
class BarsServiceImpl implements BarsService {
  final DioClient _dioClient;

  BarsServiceImpl({
    required DioClient dioClient,
  }) : _dioClient = dioClient;

  @override
  Future<Either<Failure, List<Bar>>> getMyBars() async {
    try {
      final response = await _dioClient.get<List<dynamic>>('/bars/my-bars');

      if (response.statusCode == 200 && response.data != null) {
        final bars = (response.data as List)
            .map((barJson) => Bar.fromJson(barJson as Map<String, dynamic>))
            .toList();
        return Right(bars);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener bares',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bar>> getBar(String id) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>('/bars/$id');

      if (response.statusCode == 200 && response.data != null) {
        final bar = Bar.fromJson(response.data!);
        return Right(bar);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener bar',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bar>>> getAllBars() async {
    try {
      final response = await _dioClient.get<List<dynamic>>('/bars');

      if (response.statusCode == 200 && response.data != null) {
        final bars = (response.data as List)
            .map((barJson) => Bar.fromJson(barJson as Map<String, dynamic>))
            .toList();
        return Right(bars);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener bares',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bar>> createBar(CreateBarRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/bars',
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final bar = Bar.fromJson(response.data!);
        return Right(bar);
      } else {
        return const Left(ServerFailure(
          message: 'Error al crear bar',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bar>> updateBar(
    String id,
    UpdateBarRequest request,
  ) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        '/bars/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bar = Bar.fromJson(response.data!);
        return Right(bar);
      } else {
        return const Left(ServerFailure(
          message: 'Error al actualizar bar',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBar(String id) async {
    try {
      final response = await _dioClient.delete('/bars/$id');

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(
          message: 'Error al eliminar bar',
          statusCode: 500,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  /// Manejo de errores de Dio
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          message: 'La operación ha tard ado demasiado tiempo',
        );

      case DioExceptionType.connectionError:
        return const ConnectionFailure(
          message: 'Error de conexión. Verifica tu internet',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'Error desconocido';
        final responseData = error.response?.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          message = responseData['message'] as String;
        }

        switch (statusCode) {
          case 400:
            return ValidationFailure(
              message: message,
              statusCode: statusCode,
            );
          case 401:
            return AuthFailure(
              message: message.isEmpty ? 'No autorizado' : message,
              statusCode: statusCode,
            );
          case 403:
            return AuthFailure(
              message: 'No tienes permisos para realizar esta acción',
              statusCode: statusCode,
            );
          case 404:
            return NotFoundFailure(
              message: 'Recurso no encontrado',
              statusCode: statusCode,
            );
          case 409:
            return ValidationFailure(
              message: message,
              statusCode: statusCode,
            );
          case 429:
            return ServerFailure(
              message: 'Demasiadas solicitudes. Intenta más tarde',
              statusCode: statusCode,
            );
          case 500:
          case 502:
          case 503:
            return ServerFailure(
              message: 'Error interno del servidor',
              statusCode: statusCode,
            );
          default:
            return ServerFailure(
              message: message,
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return const GeneralFailure(message: 'Operación cancelada');

      default:
        return GeneralFailure(
          message: error.message ?? 'Error desconocido',
        );
    }
  }
}

/// Provider para el servicio de bares
final barsServiceProvider = Provider<BarsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  
  return BarsServiceImpl(
    dioClient: dioClient,
  );
});
