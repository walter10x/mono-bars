import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'promotion_models.g.dart';

/// Tipo de promoción
enum PromotionType {
  @JsonValue('discount')
  discount,
  @JsonValue('buy_one_get_one')
  buyOneGetOne,
  @JsonValue('happy_hour')
  happyHour,
  @JsonValue('free_item')
  freeItem,
  @JsonValue('combo')
  combo,
}

/// Estado de la promoción
enum PromotionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('expired')
  expired,
}

/// Modelo de promoción
@JsonSerializable()
class Promotion extends Equatable {
  final String id;
  final String title;
  final String description;
  final PromotionType type;
  final PromotionStatus status;
  final String barId;
  final String? image;
  final List<String> images;
  final double? discountPercentage;
  final double? discountAmount;
  final double? minimumPurchase;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> applicableItems; // IDs de items del menú
  final List<String> applicableCategories; // IDs de categorías
  final int? maxUses;
  final int currentUses;
  final List<String> daysOfWeek; // Lunes, Martes, etc.
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm
  final bool requiresCode;
  final String? promotionCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = PromotionStatus.draft,
    required this.barId,
    this.image,
    this.images = const [],
    this.discountPercentage,
    this.discountAmount,
    this.minimumPurchase,
    required this.startDate,
    required this.endDate,
    this.applicableItems = const [],
    this.applicableCategories = const [],
    this.maxUses,
    this.currentUses = 0,
    this.daysOfWeek = const [],
    this.startTime,
    this.endTime,
    this.requiresCode = false,
    this.promotionCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);

  /// Verifica si la promoción está activa
  bool get isActive {
    final now = DateTime.now();
    return status == PromotionStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (maxUses == null || currentUses < maxUses!);
  }

  /// Verifica si la promoción está disponible en el día actual
  bool get isAvailableToday {
    if (daysOfWeek.isEmpty) return true;
    
    final today = DateTime.now();
    final weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 
      'Viernes', 'Sábado', 'Domingo'
    ];
    final todayName = weekdays[today.weekday - 1];
    
    return daysOfWeek.contains(todayName);
  }

  /// Verifica si la promoción está disponible en la hora actual
  bool get isAvailableNow {
    if (startTime == null || endTime == null) return true;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return currentTime.compareTo(startTime!) >= 0 && 
           currentTime.compareTo(endTime!) <= 0;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        barId,
        image,
        images,
        discountPercentage,
        discountAmount,
        minimumPurchase,
        startDate,
        endDate,
        applicableItems,
        applicableCategories,
        maxUses,
        currentUses,
        daysOfWeek,
        startTime,
        endTime,
        requiresCode,
        promotionCode,
        createdAt,
        updatedAt,
      ];
}

/// Request para crear promoción
@JsonSerializable()
class CreatePromotionRequest extends Equatable {
  final String title;
  final String description;
  final PromotionType type;
  final String barId;
  final double? discountPercentage;
  final double? discountAmount;
  final double? minimumPurchase;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> applicableItems;
  final List<String> applicableCategories;
  final int? maxUses;
  final List<String> daysOfWeek;
  final String? startTime;
  final String? endTime;
  final bool requiresCode;
  final String? promotionCode;

  const CreatePromotionRequest({
    required this.title,
    required this.description,
    required this.type,
    required this.barId,
    this.discountPercentage,
    this.discountAmount,
    this.minimumPurchase,
    required this.startDate,
    required this.endDate,
    this.applicableItems = const [],
    this.applicableCategories = const [],
    this.maxUses,
    this.daysOfWeek = const [],
    this.startTime,
    this.endTime,
    this.requiresCode = false,
    this.promotionCode,
  });

  factory CreatePromotionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePromotionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePromotionRequestToJson(this);

  @override
  List<Object?> get props => [
        title,
        description,
        type,
        barId,
        discountPercentage,
        discountAmount,
        minimumPurchase,
        startDate,
        endDate,
        applicableItems,
        applicableCategories,
        maxUses,
        daysOfWeek,
        startTime,
        endTime,
        requiresCode,
        promotionCode,
      ];
}

/// Filtros para promociones
@JsonSerializable()
class PromotionFilters extends Equatable {
  final String? search;
  final String? barId;
  final PromotionType? type;
  final PromotionStatus? status;
  final bool? isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  const PromotionFilters({
    this.search,
    this.barId,
    this.type,
    this.status,
    this.isActive,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 20,
  });

  factory PromotionFilters.fromJson(Map<String, dynamic> json) =>
      _$PromotionFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionFiltersToJson(this);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (barId != null && barId!.isNotEmpty) params['barId'] = barId;
    if (type != null) params['type'] = type!.name;
    if (status != null) params['status'] = status!.name;
    if (isActive != null) params['isActive'] = isActive.toString();
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    
    return params;
  }

  @override
  List<Object?> get props => [
        search,
        barId,
        type,
        status,
        isActive,
        startDate,
        endDate,
        page,
        limit,
      ];
}

/// Response para lista de promociones
@JsonSerializable()
class PromotionsListResponse extends Equatable {
  final List<Promotion> promotions;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  const PromotionsListResponse({
    required this.promotions,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PromotionsListResponse.fromJson(Map<String, dynamic> json) =>
      _$PromotionsListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionsListResponseToJson(this);

  @override
  List<Object?> get props => [promotions, total, page, limit, hasNext, hasPrev];
}
