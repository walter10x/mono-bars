import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:front_bars_flutter/core/errors/failures.dart';
import 'package:front_bars_flutter/core/network/dio_client.dart';
import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';

/// Servicio para manejar operaciones de menús
abstract class MenusService {
  Future<Either<Failure, List<Menu>>> getMyMenus();
  Future<Either<Failure, List<Menu>>> getMenusByBar(String barId);
  Future<Either<Failure, Menu>> getMenu(String id);
  Future<Either<Failure, Menu>> createMenu(CreateMenuRequest request);
  Future<Either<Failure, Menu>> updateMenu(String id, UpdateMenuRequest request);
  Future<Either<Failure, void>> deleteMenu(String id);
}

/// Implementación del servicio de menús
class MenusServiceImpl implements MenusService {
  final DioClient _dioClient;

  MenusServiceImpl({
    required DioClient dioClient,
  }) : _dioClient = dioClient;

  @override
  Future<Either<Failure, List<Menu>>> getMyMenus() async {
    try {
      final response = await _dioClient.get<List<dynamic>>('/menus/my-menus');

      if (response.statusCode == 200 && response.data != null) {
        final menus = (response.data as List)
            .map((menuJson) => Menu.fromJson(menuJson as Map<String, dynamic>))
            .toList();
        return Right(menus);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener menús',
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
  Future<Either<Failure, List<Menu>>> getMenusByBar(String barId) async {
    try {
      final response = await _dioClient.get<List<dynamic>>('/menus/bar/$barId');

      if (response.statusCode == 200 && response.data != null) {
        final menus = (response.data as List)
            .map((menuJson) => Menu.fromJson(menuJson as Map<String, dynamic>))
            .toList();
        return Right(menus);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener menús del bar',
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
  Future<Either<Failure, Menu>> getMenu(String id) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>('/menus/$id');

      if (response.statusCode == 200 && response.data != null) {
        final menu = Menu.fromJson(response.data!);
        return Right(menu);
      } else {
        return const Left(ServerFailure(
          message: 'Error al obtener menú',
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
  Future<Either<Failure, Menu>> createMenu(CreateMenuRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/menus',
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final menu = Menu.fromJson(response.data!);
        return Right(menu);
      } else {
        return const Left(ServerFailure(
          message: 'Error al crear menú',
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
  Future<Either<Failure, Menu>> updateMenu(
    String id,
    UpdateMenuRequest request,
  ) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        '/menus/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final menu = Menu.fromJson(response.data!);
        return Right(menu);
      } else {
        return const Left(ServerFailure(
          message: 'Error al actualizar menú',
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
  Future<Either<Failure, void>> deleteMenu(String id) async {
    try {
      final response = await _dioClient.delete('/menus/$id');

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(ServerFailure(
          message: 'Error al eliminar menú',
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

/// Provider para el servicio de menús
final menusServiceProvider = Provider<MenusService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  
  return MenusServiceImpl(
    dioClient: dioClient,
  );
});
