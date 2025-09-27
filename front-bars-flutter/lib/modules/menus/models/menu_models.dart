import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_models.g.dart';

/// Modelo de menú
@JsonSerializable()
class Menu extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String barId;
  final List<MenuCategory> categories;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Menu({
    required this.id,
    required this.name,
    this.description,
    required this.barId,
    this.categories = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

  Map<String, dynamic> toJson() => _$MenuToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        barId,
        categories,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Modelo de categoría de menú
@JsonSerializable()
class MenuCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int order;
  final List<MenuItem> items;
  final bool isActive;

  const MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.order = 0,
    this.items = const [],
    this.isActive = true,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoryToJson(this);

  @override
  List<Object?> get props => [id, name, description, order, items, isActive];
}

/// Modelo de item de menú
@JsonSerializable()
class MenuItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final List<String> allergens;
  final List<String> tags;
  final bool isAvailable;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final int preparationTime; // en minutos
  final int order;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.allergens = const [],
    this.tags = const [],
    this.isAvailable = true,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.preparationTime = 0,
    this.order = 0,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        image,
        allergens,
        tags,
        isAvailable,
        isVegetarian,
        isVegan,
        isGlutenFree,
        preparationTime,
        order,
      ];
}

/// Request para crear menú
@JsonSerializable()
class CreateMenuRequest extends Equatable {
  final String name;
  final String? description;
  final String barId;

  const CreateMenuRequest({
    required this.name,
    this.description,
    required this.barId,
  });

  factory CreateMenuRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMenuRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMenuRequestToJson(this);

  @override
  List<Object?> get props => [name, description, barId];
}

/// Filtros para menús
@JsonSerializable()
class MenuFilters extends Equatable {
  final String? search;
  final String? barId;
  final bool? isActive;
  final int page;
  final int limit;

  const MenuFilters({
    this.search,
    this.barId,
    this.isActive,
    this.page = 1,
    this.limit = 20,
  });

  factory MenuFilters.fromJson(Map<String, dynamic> json) =>
      _$MenuFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$MenuFiltersToJson(this);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (barId != null && barId!.isNotEmpty) params['barId'] = barId;
    if (isActive != null) params['isActive'] = isActive.toString();
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    
    return params;
  }

  @override
  List<Object?> get props => [search, barId, isActive, page, limit];
}

/// Response para lista de menús
@JsonSerializable()
class MenusListResponse extends Equatable {
  final List<Menu> menus;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  const MenusListResponse({
    required this.menus,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory MenusListResponse.fromJson(Map<String, dynamic> json) =>
      _$MenusListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MenusListResponseToJson(this);

  @override
  List<Object?> get props => [menus, total, page, limit, hasNext, hasPrev];
}
