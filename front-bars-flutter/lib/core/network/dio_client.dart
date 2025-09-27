import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

/// Configuración del cliente HTTP usando Dio
class DioClient {
  late final Dio _dio;
  final SecureStorageService _storageService;
  final Logger _logger = Logger();

  DioClient(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Interceptor para agregar token de autenticación
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (kDebugMode) {
          _logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        if (kDebugMode) {
          _logger.i(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          _logger.d('Data: ${response.data}');
        }
        handler.next(response);
      },
      
      onError: (error, handler) async {
        if (kDebugMode) {
          _logger.e(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          _logger.e('Message: ${error.message}');
          if (error.response?.data != null) {
            _logger.e('Error Data: ${error.response?.data}');
          }
        }

        // Manejo de token expirado
        if (error.response?.statusCode == 401) {
          final refreshToken = await _storageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              await _refreshToken(refreshToken);
              // Reintentar la petición original
              final clonedRequest = await _dio.fetch(error.requestOptions);
              return handler.resolve(clonedRequest);
            } catch (refreshError) {
              // Si falla el refresh, limpiar tokens y redirigir al login
              await _storageService.clearTokens();
              _logger.e('Failed to refresh token: $refreshError');
            }
          }
        }
        
        handler.next(error);
      },
    ));

    // Interceptor para logging en debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        logPrint: (o) => _logger.d(o),
        requestBody: false, // Ya manejamos el logging manualmente
        responseBody: false,
        error: false,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  Future<void> _refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      await _storageService.saveAccessToken(data['accessToken']);
      if (data['refreshToken'] != null) {
        await _storageService.saveRefreshToken(data['refreshToken']);
      }
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  // Métodos HTTP
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    String message = AppConstants.genericErrorMessage;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.timeoutErrorMessage;
        break;
      case DioExceptionType.connectionError:
        message = AppConstants.networkErrorMessage;
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          message = AppConstants.unauthorizedErrorMessage;
        } else if (error.response?.data != null) {
          message = error.response?.data['message'] ?? message;
        }
        break;
      default:
        break;
    }
    
    return Exception(message);
  }

  void dispose() {
    _dio.close();
  }
}

/// Provider para DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  final storageService = ref.watch(secureStorageServiceProvider);
  return DioClient(storageService);
});
