import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promotion_simple_model.dart';
import '../models/promotion_models.dart'; // For CreatePromotionRequest and owner operations
import '../services/promotions_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'promotions_controller.g.dart';

// Estado para las promociones
class PromotionsState {
  final List<PromotionSimple> promotions;
  final bool isLoading;
  final String? error;

  const PromotionsState({
    this.promotions = const [],
    this.isLoading = false,
    this.error,
  });

  PromotionsState copyWith({
    List<PromotionSimple>? promotions,
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

      // Convert Promotion to PromotionSimple for state compatibility
      final simplePromotions = promotions.map((promo) {
        return PromotionSimple(
          id: promo.id,
          title: promo.title,
          description: promo.description,
          barId: promo.barId,
          discountPercentage: promo.discountPercentage,
          validFrom: promo.startDate,
          validUntil: promo.endDate,
          isActive: promo.status == PromotionStatus.active,
          photoUrl: promo.image,
          termsAndConditions: null,
          createdAt: promo.createdAt,
          updatedAt: promo.updatedAt,
        );
      }).toList();

      print('🎁 LOADED ${simplePromotions.length} PROMOTIONS FOR OWNER');
      simplePromotions.forEach((p) => print('  - ${p.title} (${p.barId})'));

      state = state.copyWith(
        promotions: simplePromotions,
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

  Future<void> loadAllActivePromotions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(promotionsServiceProvider);
      final promotions = await service.getAllActivePromotions();

      print('🎁 LOADED ${promotions.length} ACTIVE PROMOTIONS FROM ALL BARS');
      promotions.forEach((p) => print('  - ${p.title} at ${p.barName ?? p.barId}'));

      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
      );
    } catch (e) {
      print('❌ ERROR loading active promotions: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<PromotionSimple>> loadFeaturedPromotions() async {
    try {
      final service = ref.read(promotionsServiceProvider);
      final promotions = await service.getFeaturedPromotions();

      print('🔥 LOADED ${promotions.length} FEATURED PROMOTIONS');
      promotions.forEach((p) => print('  - ${p.title} at ${p.barName}'));

      return promotions;
    } catch (e) {
      print('❌ ERROR loading featured promotions: $e');
      return [];
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

      // Don't update state for owner operations
      state = state.copyWith(
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

      // Don't update state for owner operations
      state = state.copyWith(
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

// Provider separado para "todas las promociones activas" 
// Esto evita conflictos cuando otras pantallas cargan promociones de un bar específico
@riverpod
class AllActivePromotionsController extends _$AllActivePromotionsController {
  @override
  PromotionsState build() {
    // Cargar automáticamente al crear el provider
    Future.microtask(() => loadPromotions());
    return const PromotionsState();
  }

  Future<void> loadPromotions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(promotionsServiceProvider);
      final allPromotions = await service.getAllActivePromotions();

      state = state.copyWith(
        promotions: allPromotions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
