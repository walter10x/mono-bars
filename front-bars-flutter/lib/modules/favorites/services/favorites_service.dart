import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/errors/http_exception.dart';

/// Servicio para manejar favoritos
class FavoritesService {
  final DioClient _dioClient;

  FavoritesService(this._dioClient);

  /// Agregar bar a favoritos
  Future<Map<String, dynamic>> addToFavorites(String barId) async {
    try {
      final response = await _dioClient.post('/favorites/$barId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw HttpException('Error al agregar a favoritos: $e');
    }
  }

  /// Quitar bar de favoritos
  Future<Map<String, dynamic>> removeFromFavorites(String barId) async {
    try {
      final response = await _dioClient.delete('/favorites/$barId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw HttpException('Error al quitar de favoritos: $e');
    }
  }

  /// Obtener lista de favoritos
  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await _dioClient.get('/favorites');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw HttpException('Error al obtener favoritos: $e');
    }
  }
}

/// Provider del servicio de favoritos
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FavoritesService(dioClient);
});
