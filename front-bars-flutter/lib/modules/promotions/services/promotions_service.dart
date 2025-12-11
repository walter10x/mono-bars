import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/promotion_models.dart';
import '../../auth/controllers/auth_controller.dart';

class PromotionsService {
  static const String baseUrl = 'http://10.0.2.2:3000/promotions';

  Future<List<Promotion>> getPromotions({String? barId}) async {
    try {
      final url = barId != null ? '$baseUrl/bar/$barId' : baseUrl;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Promotion.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar promociones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Promotion>> getMyPromotions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-promotions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Promotion.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar mis promociones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Promotion> getPromotion(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Promotion.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar promoción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Promotion> createPromotion(
    CreatePromotionRequest request,
    String token,
  ) async {
    try {
      // Convertir el request a formato backend
      final requestData = {
        'title': request.title,
        'description': request.description,
        'barId': request.barId,
        'discountPercentage': request.discountPercentage,
        'validFrom': request.startDate.toIso8601String(),
        'validUntil': request.endDate.toIso8601String(),
        'isActive': true,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Convertir respuesta backend a modelo frontend
        final data = json.decode(response.body);
        return _mapBackendToFrontend(data);
      } else {
        throw Exception('Error al crear promoción: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Promotion> updatePromotion(
    String id,
    Map<String, dynamic> updates,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _mapBackendToFrontend(data);
      } else {
        throw Exception('Error al actualizar promoción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deletePromotion(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar promoción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<String> uploadPhoto(String id, String filePath, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$id/photo'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['photoUrl'];
      } else {
        throw Exception('Error al subir foto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir foto: $e');
    }
  }

  Future<void> deletePhoto(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id/photo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar foto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Mapear del backend (simple) al frontend (complejo)
  Promotion _mapBackendToFrontend(Map<String, dynamic> backendData) {
    return Promotion(
      id: backendData['id'],
      title: backendData['title'],
      description: backendData['description'] ?? '',
      type: PromotionType.discount, // Por defecto, podemos mejorarlo después
      status: backendData['isActive'] == true 
          ? PromotionStatus.active 
          : PromotionStatus.paused,
      barId: backendData['barId'],
      image: backendData['photoUrl'],
      images: backendData['photoUrl'] != null ? [backendData['photoUrl']] : [],
      discountPercentage: backendData['discountPercentage']?.toDouble(),
      startDate: DateTime.parse(backendData['validFrom']),
      endDate: DateTime.parse(backendData['validUntil']),
      createdAt: backendData['createdAt'] != null 
          ? DateTime.parse(backendData['createdAt'])
          : DateTime.now(),
      updatedAt: backendData['updatedAt'] != null
          ? DateTime.parse(backendData['updatedAt'])
          : DateTime.now(),
    );
  }
}

// Provider
final promotionsServiceProvider = Provider<PromotionsService>((ref) {
  return PromotionsService();
});
