import 'package:equatable/equatable.dart';

/// Clase abstracta para manejar errores de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  
  const Failure({
    required this.message,
    this.statusCode,
  });
  
  @override
  List<Object?> get props => [message, statusCode];
}

/// Error de servidor (500, 502, 503, etc.)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error de conexión a internet
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error de cache local
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error de validación de datos
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error de autenticación (401, 403)
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.statusCode,
  });
}

/// Error genérico
class GeneralFailure extends Failure {
  const GeneralFailure({
    required super.message,
    super.statusCode,
  });
}
