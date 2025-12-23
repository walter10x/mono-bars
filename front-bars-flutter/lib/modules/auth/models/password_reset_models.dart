// lib/modules/auth/models/password_reset_models.dart

/// Modelo de request para solicitar reset de contraseña
class RequestResetPasswordRequest {
  final String email;

  RequestResetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}

/// Modelo de request para restablecer contraseña
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'newPassword': newPassword,
      };
}

/// Modelo de respuesta genérico para las operaciones de reset
class PasswordResetResponse {
  final String message;

  PasswordResetResponse({required this.message});

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      message: json['message'] as String,
    );
  }
}
