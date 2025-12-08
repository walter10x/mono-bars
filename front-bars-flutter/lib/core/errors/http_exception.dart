/// Excepción personalizada para errores de red HTTP
/// Sobrescribe toString() para retornar solo el mensaje sin el prefijo "Exception:"
class HttpException implements Exception {
  final String message;
  
  const HttpException(this.message);
  
  @override
  String toString() => message;
}
