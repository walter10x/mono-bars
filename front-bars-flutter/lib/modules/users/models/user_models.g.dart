// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterUserRequest _$RegisterUserRequestFromJson(Map<String, dynamic> json) =>
    RegisterUserRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$RegisterUserRequestToJson(
        RegisterUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'avatar': instance.avatar,
    };

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'message': instance.message,
    };

UsersListResponse _$UsersListResponseFromJson(Map<String, dynamic> json) =>
    UsersListResponse(
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$UsersListResponseToJson(UsersListResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };

UserFilters _$UserFiltersFromJson(Map<String, dynamic> json) => UserFilters(
      search: json['search'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isActive: json['isActive'] as bool?,
      createdAfter: json['createdAfter'] == null
          ? null
          : DateTime.parse(json['createdAfter'] as String),
      createdBefore: json['createdBefore'] == null
          ? null
          : DateTime.parse(json['createdBefore'] as String),
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      sortBy: json['sortBy'] as String? ?? 'createdAt',
      sortOrder: json['sortOrder'] as String? ?? 'desc',
    );

Map<String, dynamic> _$UserFiltersToJson(UserFilters instance) =>
    <String, dynamic>{
      'search': instance.search,
      'roles': instance.roles,
      'isActive': instance.isActive,
      'createdAfter': instance.createdAfter?.toIso8601String(),
      'createdBefore': instance.createdBefore?.toIso8601String(),
      'page': instance.page,
      'limit': instance.limit,
      'sortBy': instance.sortBy,
      'sortOrder': instance.sortOrder,
    };

UsersState _$UsersStateFromJson(Map<String, dynamic> json) => UsersState(
      status: $enumDecodeNullable(_$UsersStatusEnumMap, json['status']) ??
          UsersStatus.initial,
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPrevPage: json['hasPrevPage'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      isLoadingMore: json['isLoadingMore'] as bool? ?? false,
      filters: json['filters'] == null
          ? const UserFilters()
          : UserFilters.fromJson(json['filters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsersStateToJson(UsersState instance) =>
    <String, dynamic>{
      'status': _$UsersStatusEnumMap[instance.status]!,
      'users': instance.users,
      'totalUsers': instance.totalUsers,
      'currentPage': instance.currentPage,
      'hasNextPage': instance.hasNextPage,
      'hasPrevPage': instance.hasPrevPage,
      'errorMessage': instance.errorMessage,
      'isLoadingMore': instance.isLoadingMore,
      'filters': instance.filters,
    };

const _$UsersStatusEnumMap = {
  UsersStatus.initial: 'initial',
  UsersStatus.loading: 'loading',
  UsersStatus.loaded: 'loaded',
  UsersStatus.error: 'error',
};

UserOperationState _$UserOperationStateFromJson(Map<String, dynamic> json) =>
    UserOperationState(
      status:
          $enumDecodeNullable(_$UserOperationStatusEnumMap, json['status']) ??
              UserOperationStatus.initial,
      errorMessage: json['errorMessage'] as String?,
      successMessage: json['successMessage'] as String?,
    );

Map<String, dynamic> _$UserOperationStateToJson(UserOperationState instance) =>
    <String, dynamic>{
      'status': _$UserOperationStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'successMessage': instance.successMessage,
    };

const _$UserOperationStatusEnumMap = {
  UserOperationStatus.initial: 'initial',
  UserOperationStatus.loading: 'loading',
  UserOperationStatus.success: 'success',
  UserOperationStatus.error: 'error',
};
