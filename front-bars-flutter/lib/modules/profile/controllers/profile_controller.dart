import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/auth_models.dart';
import '../../users/models/user_models.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

part 'profile_controller.g.dart';

/// Proveedor del controlador de perfil
@riverpod
class ProfileController extends _$ProfileController {
  @override
  ProfileState build() {
    // Obtener usuario actual del auth state
    final authState = ref.watch(authStateProvider);
    if (authState.user != null) {
      return ProfileState.loaded(authState.user!);
    }
    return ProfileState.initial();
  }

  /// Actualizar perfil del usuario
  Future<void> updateProfile(UpdateUserRequest request) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    state = state.copyWith(isUpdating: true, clearError: true);

    final profileService = ref.read(profileServiceProvider);
    final result = await profileService.updateProfile(currentUser.id, request);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
      },
      (updatedUser) {
        // Actualizar también el estado de auth
        ref.read(authControllerProvider.notifier).updateUserData(updatedUser);
        
        state = ProfileState.loaded(updatedUser).copyWith(isUpdating: false);
      },
    );
  }

  /// Cambiar contraseña
  Future<void> changePassword(ChangePasswordRequest request) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    // Validar que las contraseñas coincidan
    if (request.newPassword != request.confirmPassword) {
      state = state.copyWith(
        errorMessage: 'Las contraseñas no coinciden',
      );
      return;
    }

    state = state.copyWith(isChangingPassword: true, clearError: true);

    final profileService = ref.read(profileServiceProvider);
    final result = await profileService.changePassword(currentUser.id, request);

    result.fold(
      (failure) {
        state = state.copyWith(
          isChangingPassword: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(isChangingPassword: false);
      },
    );
  }

  /// Verificar fortaleza de contraseña
  PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Longitud
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Mayúsculas
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Minúsculas
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Números
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Símbolos
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  /// Verificar requisitos de contraseña
  Map<String, bool> checkPasswordRequirements(String password) {
    return {
      'length': password.length >= 8,
      'uppercase': password.contains(RegExp(r'[A-Z]')),
      'number': password.contains(RegExp(r'[0-9]')),
      'symbol': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
