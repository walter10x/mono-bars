import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'promotion_simple_model.g.dart';

/// Modelo simple de promoción que coincide con el backend
@JsonSerializable()
class PromotionSimple extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String barId;
  final String? barName;  // Nombre del bar (viene en all-active)
  final String? barLogo;  // Logo del bar (viene en all-active)
  final double? discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? photoUrl;
  final String? termsAndConditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PromotionSimple({
    required this.id,
    required this.title,
    this.description,
    required this.barId,
    this.barName,
    this.barLogo,
    this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.photoUrl,
    this.termsAndConditions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromotionSimple.fromJson(Map<String, dynamic> json) =>
      _$PromotionSimpleFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionSimpleToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        barId,
        barName,
        barLogo,
        discountPercentage,
        validFrom,
        validUntil,
        isActive,
        photoUrl,
        termsAndConditions,
      ];
}

/// Request para crear promoción
@JsonSerializable()
class CreatePromotionSimpleRequest extends Equatable {
  final String title;
  final String? description;
  final String barId;
  final double? discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? termsAndConditions;

  const CreatePromotionSimpleRequest({
    required this.title,
    this.description,
    required this.barId,
    this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.termsAndConditions,
  });

  factory CreatePromotionSimpleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePromotionSimpleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePromotionSimpleRequestToJson(this);

  @override
  List<Object?> get props => [
        title,
        description,
        barId,
        discountPercentage,
        validFrom,
        validUntil,
        isActive,
        termsAndConditions,
      ];
}
