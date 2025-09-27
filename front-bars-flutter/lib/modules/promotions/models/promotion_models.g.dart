// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promotion _$PromotionFromJson(Map<String, dynamic> json) => Promotion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PromotionTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$PromotionStatusEnumMap, json['status']) ??
          PromotionStatus.draft,
      barId: json['barId'] as String,
      image: json['image'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      applicableItems: (json['applicableItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      applicableCategories: (json['applicableCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      maxUses: (json['maxUses'] as num?)?.toInt(),
      currentUses: (json['currentUses'] as num?)?.toInt() ?? 0,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      requiresCode: json['requiresCode'] as bool? ?? false,
      promotionCode: json['promotionCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PromotionToJson(Promotion instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$PromotionTypeEnumMap[instance.type]!,
      'status': _$PromotionStatusEnumMap[instance.status]!,
      'barId': instance.barId,
      'image': instance.image,
      'images': instance.images,
      'discountPercentage': instance.discountPercentage,
      'discountAmount': instance.discountAmount,
      'minimumPurchase': instance.minimumPurchase,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'applicableItems': instance.applicableItems,
      'applicableCategories': instance.applicableCategories,
      'maxUses': instance.maxUses,
      'currentUses': instance.currentUses,
      'daysOfWeek': instance.daysOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'requiresCode': instance.requiresCode,
      'promotionCode': instance.promotionCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PromotionTypeEnumMap = {
  PromotionType.discount: 'discount',
  PromotionType.buyOneGetOne: 'buy_one_get_one',
  PromotionType.happyHour: 'happy_hour',
  PromotionType.freeItem: 'free_item',
  PromotionType.combo: 'combo',
};

const _$PromotionStatusEnumMap = {
  PromotionStatus.draft: 'draft',
  PromotionStatus.active: 'active',
  PromotionStatus.paused: 'paused',
  PromotionStatus.expired: 'expired',
};

CreatePromotionRequest _$CreatePromotionRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePromotionRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PromotionTypeEnumMap, json['type']),
      barId: json['barId'] as String,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      applicableItems: (json['applicableItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      applicableCategories: (json['applicableCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      maxUses: (json['maxUses'] as num?)?.toInt(),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      requiresCode: json['requiresCode'] as bool? ?? false,
      promotionCode: json['promotionCode'] as String?,
    );

Map<String, dynamic> _$CreatePromotionRequestToJson(
        CreatePromotionRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': _$PromotionTypeEnumMap[instance.type]!,
      'barId': instance.barId,
      'discountPercentage': instance.discountPercentage,
      'discountAmount': instance.discountAmount,
      'minimumPurchase': instance.minimumPurchase,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'applicableItems': instance.applicableItems,
      'applicableCategories': instance.applicableCategories,
      'maxUses': instance.maxUses,
      'daysOfWeek': instance.daysOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'requiresCode': instance.requiresCode,
      'promotionCode': instance.promotionCode,
    };

PromotionFilters _$PromotionFiltersFromJson(Map<String, dynamic> json) =>
    PromotionFilters(
      search: json['search'] as String?,
      barId: json['barId'] as String?,
      type: $enumDecodeNullable(_$PromotionTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$PromotionStatusEnumMap, json['status']),
      isActive: json['isActive'] as bool?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$PromotionFiltersToJson(PromotionFilters instance) =>
    <String, dynamic>{
      'search': instance.search,
      'barId': instance.barId,
      'type': _$PromotionTypeEnumMap[instance.type],
      'status': _$PromotionStatusEnumMap[instance.status],
      'isActive': instance.isActive,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'page': instance.page,
      'limit': instance.limit,
    };

PromotionsListResponse _$PromotionsListResponseFromJson(
        Map<String, dynamic> json) =>
    PromotionsListResponse(
      promotions: (json['promotions'] as List<dynamic>)
          .map((e) => Promotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$PromotionsListResponseToJson(
        PromotionsListResponse instance) =>
    <String, dynamic>{
      'promotions': instance.promotions,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };
