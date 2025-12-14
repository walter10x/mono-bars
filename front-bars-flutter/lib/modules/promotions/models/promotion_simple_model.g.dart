// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_simple_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionSimple _$PromotionSimpleFromJson(Map<String, dynamic> json) =>
    PromotionSimple(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      barId: json['barId'] as String,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      isActive: json['isActive'] as bool? ?? true,
      photoUrl: json['photoUrl'] as String?,
      termsAndConditions: json['termsAndConditions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PromotionSimpleToJson(PromotionSimple instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'barId': instance.barId,
      'discountPercentage': instance.discountPercentage,
      'validFrom': instance.validFrom.toIso8601String(),
      'validUntil': instance.validUntil.toIso8601String(),
      'isActive': instance.isActive,
      'photoUrl': instance.photoUrl,
      'termsAndConditions': instance.termsAndConditions,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreatePromotionSimpleRequest _$CreatePromotionSimpleRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePromotionSimpleRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      barId: json['barId'] as String,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      isActive: json['isActive'] as bool? ?? true,
      termsAndConditions: json['termsAndConditions'] as String?,
    );

Map<String, dynamic> _$CreatePromotionSimpleRequestToJson(
        CreatePromotionSimpleRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'barId': instance.barId,
      'discountPercentage': instance.discountPercentage,
      'validFrom': instance.validFrom.toIso8601String(),
      'validUntil': instance.validUntil.toIso8601String(),
      'isActive': instance.isActive,
      'termsAndConditions': instance.termsAndConditions,
    };
