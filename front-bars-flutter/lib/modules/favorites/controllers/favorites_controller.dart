import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/controllers/auth_controller.dart';
import '../models/favorites_models.dart';
import '../services/favorites_service.dart';

part 'favorites_controller.g.dart';

/// Controlador de favoritos
@riverpod
class FavoritesController extends _$FavoritesController {
  @override
  FavoritesState build() {
    // Obtener favoritos del usuario autenticado
    final authState = ref.watch(authStateProvider);
    if (authState.user != null) {
      return FavoritesState(
        favoriteBarIds: authState.user!.favoriteBars,
      );
    }
    return FavoritesState.initial();
  }

  /// Toggle favorite (agregar o quitar)
  Future<void> toggleFavorite(String barId) async {
    final currentState = state;
    final isFavorite = currentState.isFavorite(barId);

    // Actualización optimista (actualizar UI inmediatamente)
    if (isFavorite) {
      state = currentState.copyWith(
        favoriteBarIds: currentState.favoriteBarIds.where((id) => id != barId).toList(),
      );
    } else {
      state = currentState.copyWith(
        favoriteBarIds: [...currentState.favoriteBarIds, barId],
      );
    }

    // Llamada al backend
    final service = ref.read(favoritesServiceProvider);
    
    try {
      if (isFavorite) {
        await service.removeFromFavorites(barId);
      } else {
        await service.addToFavorites(barId);
      }
      
      // Actualizar también el authState para sincronizar
      final authController = ref.read(authControllerProvider.notifier);
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        final updatedFavorites = state.favoriteBarIds;
        final updatedUser = user.copyWith(favoriteBars: updatedFavorites);
        authController.updateUserData(updatedUser);
      }
    } catch (e) {
      // Si falla, revertir cambio optimista
      state = currentState.copyWith(errorMessage: e.toString());
    }
  }

  /// Verificar si un bar es favorito
  bool isFavorite(String barId) {
    return state.isFavorite(barId);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
