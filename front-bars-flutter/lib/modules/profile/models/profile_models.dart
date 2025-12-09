import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../auth/models/auth_models.dart';

/// Enum para fortaleza de contraseña
enum PasswordStrength { weak, medium, strong, veryStrong }

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Débil';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Fuerte';
      case PasswordStrength.veryStrong:
        return 'Muy fuerte';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.weak:
        return const Color(0xFFEF4444); // Red
      case PasswordStrength.medium:
        return const Color(0xFFF59E0B); // Amber
      case PasswordStrength.strong:
        return const Color(0xFF3B82F6); // Blue
      case PasswordStrength.veryStrong:
        return const Color(0xFF10B981); // Green
    }
  }
}

/// Estado del perfil
enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Estado del módulo de perfil
class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;
  final bool isUpdating;
  final bool isChangingPassword;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.isUpdating = false,
    this.isChangingPassword = false,
  });

  factory ProfileState.initial() => const ProfileState();

  factory ProfileState.loading() => const ProfileState(status: ProfileStatus.loading);

  factory ProfileState.loaded(User user) => ProfileState(
        status: ProfileStatus.loaded,
        user: user,
      );

  factory ProfileState.error(String message) => ProfileState(
        status: ProfileStatus.error,
        errorMessage: message,
      );

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        isUpdating,
        isChangingPassword,
      ];

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
    bool? isUpdating,
    bool? isChangingPassword,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdating: isUpdating ?? this.isUpdating,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
    );
  }
}
