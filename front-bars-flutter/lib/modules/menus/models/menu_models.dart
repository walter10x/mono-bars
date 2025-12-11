import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_models.g.dart';

/// Item del menú (producto) - Adaptado al backend
@JsonSerializable()
class MenuItem extends Equatable {
  final String name;
  final String? description;
  final double price;
  final String? photoUrl;

  const MenuItem({
    required this.name,
    this.description,
    required this.price,
    this.photoUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  @override
  List<Object?> get props => [name, description, price, photoUrl];

  MenuItem copyWith({
    String? name,
    String? description,
    double? price,
    String? photoUrl,
  }) {
    return MenuItem(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

/// Modelo principal de Menú - Adaptado al backend
@JsonSerializable()
class Menu extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String barId; // Relación con Bar
  final List<MenuItem> items;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Menu({
    required this.id,
    required this.name,
    this.description,
    required this.barId,
    this.items = const [],
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

  Map<String, dynamic> toJson() => _$MenuToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        barId,
        items,
        photoUrl,
        createdAt,
        updatedAt,
      ];

  Menu copyWith({
    String? id,
    String? name,
    String? description,
    String? barId,
    List<MenuItem>? items,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Menu(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barId: barId ?? this.barId,
      items: items ?? this.items,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Número de items en el menú
  int get itemCount => items.length;

  /// Precio promedio de items
  double get averagePrice {
    if (items.isEmpty) return 0.0;
    final total = items.fold<double>(0.0, (sum, item) => sum + item.price);
    return total / items.length;
  }
}

/// Request para crear un menú
@JsonSerializable()
class CreateMenuRequest extends Equatable {
  final String name;
  final String? description;
  final String barId; // REQUERIDO
  final List<MenuItem>? items;
  final String? photoUrl;

  const CreateMenuRequest({
    required this.name,
    this.description,
    required this.barId,
    this.items,
    this.photoUrl,
  });

  factory CreateMenuRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMenuRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMenuRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        barId,
        items,
        photoUrl,
      ];
}

/// Request para actualizar un menú
@JsonSerializable()
class UpdateMenuRequest extends Equatable {
  final String? name;
  final String? description;
  final List<MenuItem>? items;
  final String? photoUrl;

  const UpdateMenuRequest({
    this.name,
    this.description,
    this.items,
    this.photoUrl,
  });

  factory UpdateMenuRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMenuRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMenuRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        items,
        photoUrl,
      ];
}
