import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promotion_models.dart';
import '../services/promotions_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'promotions_controller.g.dart';

// Estado para las promociones
class PromotionsState {
  final List<Promotion> promotions;
  final bool isLoading;
  final String? error;

  const PromotionsState({
    this.promotions = const [],
    this.isLoading = false,
    this.error,
  });

  PromotionsState copyWith({
    List<Promotion>? promotions,
    bool? isLoading,
    String? error,
  }) {
    return PromotionsState(
      promotions: promotions ?? this.promotions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class PromotionsController extends _$PromotionsController {
  @override
  PromotionsState build() {
    return const PromotionsState();
  }

  Future<void> loadMyPromotions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final service = ref.read(promotionsServiceProvider);
      final promotions = await service.getMyPromotions(token);

      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPromotionsByBar(String barId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(promotionsServiceProvider);
      final promotions = await service.getPromotions(barId: barId);

      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createPromotion(CreatePromotionRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final service = ref.read(promotionsServiceProvider);
      final newPromotion = await service.createPromotion(request, token);

      state = state.copyWith(
        promotions: [...state.promotions, newPromotion],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updatePromotion(String id, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final service = ref.read(promotionsServiceProvider);
      final updatedPromotion = await service.updatePromotion(id, updates, token);

      final updatedList = state.promotions.map((p) {
        return p.id == id ? updatedPromotion : p;
      }).toList();

      state = state.copyWith(
        promotions: updatedList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deletePromotion(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final service = ref.read(promotionsServiceProvider);
      await service.deletePromotion(id, token);

      final updatedList = state.promotions.where((p) => p.id != id).toList();

      state = state.copyWith(
        promotions: updatedList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<String> uploadPhoto(String id, String filePath) async {
    try {
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final service = ref.read(promotionsServiceProvider);
      final photoUrl = await service.uploadPhoto(id, filePath, token);

      // Actualizar la promoción con la nueva foto
      await updatePromotion(id, {'photoUrl': photoUrl});

      return photoUrl;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      final storageService = ref.read(secureStorageServiceProvider);
      final token = await storageService.getAccessToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final service = ref.read(promotionsServiceProvider);
      await service.deletePhoto(id, token);

      // Recargar promociones
      await loadMyPromotions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
