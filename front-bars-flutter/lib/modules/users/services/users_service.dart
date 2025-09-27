import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/auth_models.dart';
import '../models/user_models.dart';

/// Servicio para manejar operaciones de usuarios
abstract class UsersService {
  Future<Either<Failure, UserResponse>> registerUser(RegisterUserRequest request);
  Future<Either<Failure, UsersListResponse>> getUsers(UserFilters filters);
  Future<Either<Failure, UserResponse>> getUserById(String id);
  Future<Either<Failure, UserResponse>> updateUser(String id, UpdateUserRequest request);
  Future<Either<Failure, void>> deleteUser(String id);
}

/// Implementación del servicio de usuarios
class UsersServiceImpl implements UsersService {
  final DioClient _dioClient;

  UsersServiceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<Either<Failure, UserResponse>> registerUser(
    RegisterUserRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/users/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final userResponse = UserResponse.fromJson(response.data!);
        return Right(userResponse);
      } else {
        return const Left(ServerFailure(
          message: 'Error al registrar usuario',
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
  Future<Either<Failure, UsersListResponse>> getUsers(
    UserFilters filters,
  ) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/users',
        queryParameters: filters.toQueryParameters(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final usersResponse = UsersListResponse.fromJson(response.data!);
        return Right(usersResponse);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener lista de usuarios',
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
  Future<Either<Failure, UserResponse>> getUserById(String id) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/users/$id',
      );

      if (response.statusCode == 200 && response.data != null) {
        final userResponse = UserResponse.fromJson(response.data!);
        return Right(userResponse);
      } else {
        return const Left(NotFoundFailure(
          message: 'Usuario no encontrado',
          statusCode: 404,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserResponse>> updateUser(
    String id,
    UpdateUserRequest request,
  ) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        '/users/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final userResponse = UserResponse.fromJson(response.data!);
        return Right(userResponse);
      } else {
        return const Left(ServerFailure(
          message: 'Error al actualizar usuario',
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
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      final response = await _dioClient.delete('/users/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(
          message: 'Error al eliminar usuario',
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
          message: 'La operación ha tardado demasiado tiempo',
        );

      case DioExceptionType.connectionError:
        return const ConnectionFailure(
          message: 'Error de conexión. Verifica tu internet',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Error desconocido';

        switch (statusCode) {
          case 400:
            return ValidationFailure(
              message: message,
              statusCode: statusCode,
            );
          case 401:
            return AuthFailure(
              message: 'No autorizado',
              statusCode: statusCode,
            );
          case 403:
            return AuthFailure(
              message: 'No tienes permisos para realizar esta acción',
              statusCode: statusCode,
            );
          case 404:
            return NotFoundFailure(
              message: 'Usuario no encontrado',
              statusCode: statusCode,
            );
          case 409:
            return ValidationFailure(
              message: 'El usuario ya existe',
              statusCode: statusCode,
            );
          case 422:
            return ValidationFailure(
              message: message,
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

/// Provider para el servicio de usuarios
final usersServiceProvider = Provider<UsersService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UsersServiceImpl(dioClient: dioClient);
});
