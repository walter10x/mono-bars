import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';

/// Servicio para manejar la autenticación
abstract class AuthService {
  Future<Either<Failure, LoginResponse>> login(LoginRequest request);
  Future<Either<Failure, RefreshTokenResponse>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> forgotPassword(ForgotPasswordRequest request);
  Future<Either<Failure, void>> resetPassword(ResetPasswordRequest request);
  Future<Either<Failure, void>> changePassword(ChangePasswordRequest request);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, bool>> verifyToken();
}

/// Implementación del servicio de autenticación
class AuthServiceImpl implements AuthService {
  final DioClient _dioClient;
  final SecureStorageService _storageService;

  AuthServiceImpl({
    required DioClient dioClient,
    required SecureStorageService storageService,
  })  : _dioClient = dioClient,
        _storageService = storageService;

  @override
  Future<Either<Failure, LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);
        
        // Guardar tokens y datos de usuario
        await _storageService.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        );
        await _storageService.saveUserData(loginResponse.user.toJson());

        return Right(loginResponse);
      } else {
        return const Left(ServerFailure(
          message: 'Error en el servidor',
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
  Future<Either<Failure, RefreshTokenResponse>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final refreshResponse = RefreshTokenResponse.fromJson(response.data!);
        
        // Actualizar tokens
        await _storageService.saveTokens(
          accessToken: refreshResponse.accessToken,
          refreshToken: refreshResponse.refreshToken,
        );

        return Right(refreshResponse);
      } else {
        return const Left(ServerFailure(
          message: 'Error al renovar token',
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
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      
      // Intentar hacer logout en el servidor si hay refresh token
      if (refreshToken != null) {
        try {
          await _dioClient.post(
            '/auth/logout',
            data: {'refreshToken': refreshToken},
          );
        } catch (e) {
          // Si falla el logout en el servidor, continuamos con la limpieza local
        }
      }

      // Limpiar datos locales
      await _storageService.clearSession();

      return const Right(null);
    } catch (e) {
      // Siempre limpiar datos locales aunque falle
      await _storageService.clearSession();
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _dioClient.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(
          message: 'Error al enviar email de recuperación',
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
  Future<Either<Failure, void>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await _dioClient.post(
        '/auth/reset-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(
          message: 'Error al restablecer contraseña',
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
  Future<Either<Failure, void>> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final response = await _dioClient.put(
        '/auth/change-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(
          message: 'Error al cambiar contraseña',
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
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Primero intentar obtener del almacenamiento local
      final userData = await _storageService.getUserData();
      if (userData != null) {
        try {
          final user = User.fromJson(userData);
          return Right(user);
        } catch (e) {
          // Si falla la deserialización, obtener del servidor
        }
      }

      // Obtener del servidor
      final response = await _dioClient.get<Map<String, dynamic>>('/auth/me');

      if (response.statusCode == 200 && response.data != null) {
        final user = User.fromJson(response.data!);
        
        // Guardar en almacenamiento local
        await _storageService.saveUserData(user.toJson());
        
        return Right(user);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener datos del usuario',
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
  Future<Either<Failure, bool>> verifyToken() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        return const Right(false);
      }

      final response = await _dioClient.get('/auth/verify');
      
      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return const Right(false);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Right(false);
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return const Right(false);
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
              message: 'Credenciales inválidas o sesión expirada',
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

/// Provider para el servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  
  return AuthServiceImpl(
    dioClient: dioClient,
    storageService: storageService,
  );
});
