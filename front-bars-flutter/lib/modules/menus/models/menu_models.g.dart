// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      barId: json['barId'] as String,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'barId': instance.barId,
      'categories': instance.categories,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) => MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$MenuCategoryToJson(MenuCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'order': instance.order,
      'items': instance.items,
      'isActive': instance.isActive,
    };

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
      preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'image': instance.image,
      'allergens': instance.allergens,
      'tags': instance.tags,
      'isAvailable': instance.isAvailable,
      'isVegetarian': instance.isVegetarian,
      'isVegan': instance.isVegan,
      'isGlutenFree': instance.isGlutenFree,
      'preparationTime': instance.preparationTime,
      'order': instance.order,
    };

CreateMenuRequest _$CreateMenuRequestFromJson(Map<String, dynamic> json) =>
    CreateMenuRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      barId: json['barId'] as String,
    );

Map<String, dynamic> _$CreateMenuRequestToJson(CreateMenuRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'barId': instance.barId,
    };

MenuFilters _$MenuFiltersFromJson(Map<String, dynamic> json) => MenuFilters(
      search: json['search'] as String?,
      barId: json['barId'] as String?,
      isActive: json['isActive'] as bool?,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$MenuFiltersToJson(MenuFilters instance) =>
    <String, dynamic>{
      'search': instance.search,
      'barId': instance.barId,
      'isActive': instance.isActive,
      'page': instance.page,
      'limit': instance.limit,
    };

MenusListResponse _$MenusListResponseFromJson(Map<String, dynamic> json) =>
    MenusListResponse(
      menus: (json['menus'] as List<dynamic>)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$MenusListResponseToJson(MenusListResponse instance) =>
    <String, dynamic>{
      'menus': instance.menus,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };
