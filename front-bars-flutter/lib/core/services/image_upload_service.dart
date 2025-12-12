import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';

import '../network/dio_client.dart';

/// Servicio para subir imágenes al backend
class ImageUploadService {
  final DioClient _dioClient;

  ImageUploadService(this._dioClient);

  /// Sube una imagen de menú
  Future<String> uploadMenuImage(String menuId, File imageFile) async {
    return _uploadImage('/menus/$menuId/photo', imageFile);
  }

  /// Sube una imagen de bar
  Future<String> uploadBarImage(String barId, File imageFile) async {
    return _uploadImage('/bars/$barId/photo', imageFile);
  }

  /// Sube una imagen de promoción
  Future<String> uploadPromotionImage(String promotionId, File imageFile) async {
    return _uploadImage('/promotions/$promotionId/photo', imageFile);
  }

  /// Método genérico para subir imagen
  Future<String> _uploadImage(String endpoint, File imageFile) async {
    try {
      // Comprimir imagen antes de subir
      final compressedFile = await _compressImage(imageFile);

      // Crear form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressedFile.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // Subir imagen usando DioClient
      final response = await _dioClient.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Extraer URL de la respuesta
      final photoUrl = response.data['photoUrl'] as String;
      return photoUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Comprime una imagen para reducir tamaño
  Future<File> _compressImage(File file) async {
    try {
      // Leer imagen
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es muy grande (máx 1920px de ancho)
      img.Image resized = image;
      if (image.width > 1920) {
        resized = img.copyResize(image, width: 1920);
      }

      // Comprimir como JPEG con calidad 85
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      // Guardar archivo comprimido
      final compressedFile = File('${file.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      // Si falla la compresión, devolver archivo original
      return file;
    }
  }
}

/// Provider del servicio
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ImageUploadService(dioClient);
});
