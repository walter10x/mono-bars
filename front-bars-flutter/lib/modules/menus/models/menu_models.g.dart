// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'photoUrl': instance.photoUrl,
    };

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      barId: json['barId'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'barId': instance.barId,
      'items': instance.items,
      'photoUrl': instance.photoUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CreateMenuRequest _$CreateMenuRequestFromJson(Map<String, dynamic> json) =>
    CreateMenuRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      barId: json['barId'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$CreateMenuRequestToJson(CreateMenuRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'barId': instance.barId,
      'items': instance.items,
      'photoUrl': instance.photoUrl,
    };

UpdateMenuRequest _$UpdateMenuRequestFromJson(Map<String, dynamic> json) =>
    UpdateMenuRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$UpdateMenuRequestToJson(UpdateMenuRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'items': instance.items,
      'photoUrl': instance.photoUrl,
    };
