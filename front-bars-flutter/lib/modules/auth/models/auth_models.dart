import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

/// Request para login
@JsonSerializable()
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [email, password];
}

/// Response del login
@JsonSerializable()
class LoginResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final User user;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

/// Request para refresh token
@JsonSerializable()
class RefreshTokenRequest extends Equatable {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);

  @override
  List<Object?> get props => [refreshToken];
}

/// Response del refresh token
@JsonSerializable()
class RefreshTokenResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;

  const RefreshTokenResponse({
    required this.accessToken,
    this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

/// Request para forgot password
@JsonSerializable()
class ForgotPasswordRequest extends Equatable {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);

  @override
  List<Object?> get props => [email];
}

/// Request para reset password
@JsonSerializable()
class ResetPasswordRequest extends Equatable {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

/// Request para change password
@JsonSerializable()
class ChangePasswordRequest extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

/// Modelo de usuario básico (puede estar en un archivo separado si se usa en otros módulos)
@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? role;
  final List<String> roles;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.avatar,
    this.role,
    this.roles = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Getter para nombre completo
  String get fullName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    } else if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  /// Getter para iniciales
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final words = name!.trim().split(' ');
      if (words.length >= 2) {
        return '${words[0][0].toUpperCase()}${words[1][0].toUpperCase()}';
      }
      return name![0].toUpperCase();
    } else if (firstName != null && lastName != null) {
      return '${firstName![0].toUpperCase()}${lastName![0].toUpperCase()}';
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    } else if (lastName != null) {
      return lastName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String role) {
    return roles.contains(role);
  }

  /// Verifica si el usuario es admin
  bool get isAdmin {
    return hasRole('admin') || hasRole('administrator');
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        firstName,
        lastName,
        avatar,
        role,
        roles,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Método para copiar con modificaciones
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    List<String>? roles,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Estado de autenticación
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Request para registrar un nuevo usuario
@JsonSerializable()
class RegisterRequest extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role; // 'client' (default) o 'owner'

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.role = 'client',
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  List<Object?> get props => [
        email,
        password,
        name,
        role,
      ];
}

/// Response del registro
@JsonSerializable()
class RegisterResponse extends Equatable {
  final User user;
  final String? message;

  const RegisterResponse({
    required this.user,
    this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  @override
  List<Object?> get props => [user, message];
}

/// Estado del auth controller
@JsonSerializable()
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);

  Map<String, dynamic> toJson() => _$AuthStateToJson(this);

  /// Estado inicial
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Estado de carga
  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
      isLoading: true,
    );
  }

  /// Estado autenticado
  factory AuthState.authenticated(User user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Estado no autenticado
  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  /// Estado de error
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// Verifica si está autenticado
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Verifica si está cargando
  bool get isLoadingState => status == AuthStatus.loading || isLoading;

  /// Verifica si hay error
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  @override
  List<Object?> get props => [status, user, errorMessage, isLoading];

  /// Método para copiar con modificaciones
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
