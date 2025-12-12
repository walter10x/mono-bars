import 'package:front_bars_flutter/core/constants/app_constants.dart';

class ImageUrlHelper {
  /// Convierte una URL relativa del backend a una URL absoluta
  /// Si la URL ya es absoluta (empieza con http), la devuelve sin cambios
  /// Si es relativa (empieza con /), le agrega el baseUrl
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // Si ya es URL absoluta, devolverla tal cual
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Si es URL relativa, agregar baseUrl
    if (imageUrl.startsWith('/')) {
      return '${AppConstants.baseUrl}$imageUrl';
    }

    // Si no tiene /, agregarle uno
    return '${AppConstants.baseUrl}/$imageUrl';
  }
}
