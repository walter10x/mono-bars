import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/auth_models.dart';
import '../../users/models/user_models.dart';
import '../models/profile_models.dart';

/// Proveedor del servicio de perfil
final profileServiceProvider = Provider<ProfileService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileServiceImpl(dioClient);
});

/// Interfaz del servicio de perfil
abstract class ProfileService {
  /// Obtener perfil del usuario
  Future<Either<Failure, User>> getProfile(String userId);

  /// Actualizar perfil del usuario
  Future<Either<Failure, User>> updateProfile(
    String userId,
    UpdateUserRequest request,
  );

  /// Cambiar contraseña
  Future<Either<Failure, void>> changePassword(
    String userId,
    ChangePasswordRequest request,
  );
}

/// Implementación del servicio de perfil
class ProfileServiceImpl implements ProfileService {
  final DioClient _dioClient;

  ProfileServiceImpl(this._dioClient);

  @override
  Future<Either<Failure, User>> getProfile(String userId) async {
    try {
      final response = await _dioClient.get('/users/$userId');
      final user = User.fromJson(response.data as Map<String, dynamic>);
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
    String userId,
    UpdateUserRequest request,
  ) async {
    try {
      final response = await _dioClient.put(
        '/users/$userId',
        data: request.toJson(),
      );
      final user = User.fromJson(response.data as Map<String, dynamic>);
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String userId,
    ChangePasswordRequest request,
  ) async {
    try {
      await _dioClient.put(
        '/users/$userId/change-password',
        data: {
          'currentPassword': request.currentPassword,
          'newPassword': request.newPassword,
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  Failure _handleError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final message = error.response?.data?['message'] as String? ?? 
        error.response?.data?['error'] as String? ?? 
        'Error en la operación';

    switch (statusCode) {
      case 401:
        return AuthFailure(message: message, statusCode: statusCode);
      case 403:
        return AuthFailure(message: message, statusCode: statusCode);
      case 404:
        return ServerFailure(message: message, statusCode: statusCode);
      default:
        return ServerFailure(message: message, statusCode: statusCode);
    }
  }
}
