import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../auth/models/auth_models.dart';

part 'user_models.g.dart';

/// Request para registrar un nuevo usuario
@JsonSerializable()
class RegisterUserRequest extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String? firstName;
  final String? lastName;
  final String? phone;

  const RegisterUserRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserRequestToJson(this);

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        firstName,
        lastName,
        phone,
      ];
}

/// Request para actualizar un usuario
@JsonSerializable()
class UpdateUserRequest extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;

  const UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);

  @override
  List<Object?> get props => [firstName, lastName, phone, avatar];
}

/// Response para operaciones de usuario
@JsonSerializable()
class UserResponse extends Equatable {
  final User user;
  final String? message;

  const UserResponse({
    required this.user,
    this.message,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  List<Object?> get props => [user, message];
}

/// Response para lista de usuarios (con paginación)
@JsonSerializable()
class UsersListResponse extends Equatable {
  final List<User> users;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  const UsersListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) =>
      _$UsersListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UsersListResponseToJson(this);

  @override
  List<Object?> get props => [users, total, page, limit, hasNext, hasPrev];
}

/// Filtros para buscar usuarios
@JsonSerializable()
class UserFilters extends Equatable {
  final String? search;
  final List<String>? roles;
  final bool? isActive;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  const UserFilters({
    this.search,
    this.roles,
    this.isActive,
    this.createdAfter,
    this.createdBefore,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  factory UserFilters.fromJson(Map<String, dynamic> json) =>
      _$UserFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$UserFiltersToJson(this);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (roles != null && roles!.isNotEmpty) params['roles'] = roles!.join(',');
    if (isActive != null) params['isActive'] = isActive.toString();
    if (createdAfter != null) params['createdAfter'] = createdAfter!.toIso8601String();
    if (createdBefore != null) params['createdBefore'] = createdBefore!.toIso8601String();
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    
    return params;
  }

  @override
  List<Object?> get props => [
        search,
        roles,
        isActive,
        createdAfter,
        createdBefore,
        page,
        limit,
        sortBy,
        sortOrder,
      ];

  UserFilters copyWith({
    String? search,
    List<String>? roles,
    bool? isActive,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return UserFilters(
      search: search ?? this.search,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Estado del módulo de usuarios
enum UsersStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Estado para manejar la lista de usuarios
@JsonSerializable()
class UsersState extends Equatable {
  final UsersStatus status;
  final List<User> users;
  final int totalUsers;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? errorMessage;
  final bool isLoadingMore;
  final UserFilters filters;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.totalUsers = 0,
    this.currentPage = 1,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.errorMessage,
    this.isLoadingMore = false,
    this.filters = const UserFilters(),
  });

  factory UsersState.fromJson(Map<String, dynamic> json) =>
      _$UsersStateFromJson(json);

  Map<String, dynamic> toJson() => _$UsersStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        users,
        totalUsers,
        currentPage,
        hasNextPage,
        hasPrevPage,
        errorMessage,
        isLoadingMore,
        filters,
      ];

  UsersState copyWith({
    UsersStatus? status,
    List<User>? users,
    int? totalUsers,
    int? currentPage,
    bool? hasNextPage,
    bool? hasPrevPage,
    String? errorMessage,
    bool? isLoadingMore,
    UserFilters? filters,
    bool clearError = false,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      totalUsers: totalUsers ?? this.totalUsers,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPrevPage: hasPrevPage ?? this.hasPrevPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
    );
  }
}

/// Estado para operaciones individuales de usuario
enum UserOperationStatus {
  initial,
  loading,
  success,
  error,
}

/// Estado para crear/editar usuario
@JsonSerializable()
class UserOperationState extends Equatable {
  final UserOperationStatus status;
  final String? errorMessage;
  final String? successMessage;

  const UserOperationState({
    this.status = UserOperationStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  factory UserOperationState.fromJson(Map<String, dynamic> json) =>
      _$UserOperationStateFromJson(json);

  Map<String, dynamic> toJson() => _$UserOperationStateToJson(this);

  @override
  List<Object?> get props => [status, errorMessage, successMessage];

  UserOperationState copyWith({
    UserOperationStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return UserOperationState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
