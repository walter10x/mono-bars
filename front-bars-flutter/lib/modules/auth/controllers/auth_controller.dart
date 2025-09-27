import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

part 'auth_controller.g.dart';

/// Controlador de autenticación usando Riverpod
@riverpod
class AuthController extends _$AuthController {
  late final AuthService _authService;
  late final SecureStorageService _storageService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _storageService = ref.watch(secureStorageServiceProvider);
    
    // Verificar automáticamente el estado de autenticación al inicializar
    _checkAuthStatus();
    
    return AuthState.initial();
  }

  /// Verifica el estado de autenticación actual
  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await _storageService.isAuthenticated();
      
      if (isAuthenticated) {
        // Intentar obtener datos del usuario
        final result = await _authService.getCurrentUser();
        
        result.fold(
          (failure) {
            // Si falla, marcar como no autenticado
            state = AuthState.unauthenticated();
          },
          (user) {
            // Si tiene éxito, marcar como autenticado
            state = AuthState.authenticated(user);
          },
        );
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  /// Inicia sesión con email y contraseña
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();

    try {
      final request = LoginRequest(email: email, password: password);
      final result = await _authService.login(request);

      result.fold(
        (failure) {
          state = AuthState.error(failure.message);
        },
        (loginResponse) {
          state = AuthState.authenticated(loginResponse.user);
        },
      );
    } catch (e) {
      state = AuthState.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    state = AuthState.loading();

    try {
      final result = await _authService.logout();

      result.fold(
        (failure) {
          // Aunque falle el logout en el servidor, limpiar el estado local
          state = AuthState.unauthenticated();
        },
        (_) {
          state = AuthState.unauthenticated();
        },
      );
    } catch (e) {
      // En caso de error, aún así cerrar sesión localmente
      state = AuthState.unauthenticated();
    }
  }

  /// Envía email de recuperación de contraseña
  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true);

    try {
      final request = ForgotPasswordRequest(email: email);
      final result = await _authService.forgotPassword(request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
          success = false;
        },
        (_) {
          state = state.copyWith(isLoading: false, clearError: true);
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error inesperado: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  /// Restablece la contraseña con token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      final result = await _authService.resetPassword(request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
          success = false;
        },
        (_) {
          state = state.copyWith(isLoading: false, clearError: true);
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error inesperado: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  /// Cambia la contraseña del usuario autenticado
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      final result = await _authService.changePassword(request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
          success = false;
        },
        (_) {
          state = state.copyWith(isLoading: false, clearError: true);
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error inesperado: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  /// Actualiza los datos del usuario actual
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final result = await _authService.getCurrentUser();

      result.fold(
        (failure) {
          // Si falla, podría ser que el token expiró
          if (failure.statusCode == 401) {
            state = AuthState.unauthenticated();
          }
        },
        (user) {
          state = state.copyWith(user: user);
        },
      );
    } catch (e) {
      // Si hay error, mantener el estado actual
    }
  }

  /// Verifica si el token actual es válido
  Future<bool> verifyToken() async {
    try {
      final result = await _authService.verifyToken();
      
      return result.fold(
        (failure) => false,
        (isValid) {
          if (!isValid && state.isAuthenticated) {
            // Si el token no es válido, cerrar sesión
            state = AuthState.unauthenticated();
          }
          return isValid;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Limpia el error actual
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Actualiza los datos del usuario en el estado
  void updateUser(User user) {
    if (state.isAuthenticated) {
      state = state.copyWith(user: user);
      // También actualizar en almacenamiento local
      _storageService.saveUserData(user.toJson());
    }
  }

  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String role) {
    return state.user?.hasRole(role) ?? false;
  }

  /// Verifica si el usuario es admin
  bool get isAdmin {
    return state.user?.isAdmin ?? false;
  }

  /// Obtiene el usuario actual
  User? get currentUser => state.user;

  /// Verifica si está autenticado
  bool get isAuthenticated => state.isAuthenticated;

  /// Verifica si está cargando
  bool get isLoading => state.isLoadingState;

  /// Obtiene el error actual
  String? get error => state.errorMessage;
}

/// Provider para el controlador de autenticación (generado automáticamente)

/// Provider que expone solo el estado de autenticación
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});

/// Provider que verifica si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

/// Provider que obtiene el usuario actual
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

/// Provider que verifica si hay una operación de auth en progreso
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoadingState;
});

/// Provider que obtiene el error de autenticación actual
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.errorMessage;
});
