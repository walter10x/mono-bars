// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bar _$BarFromJson(Map<String, dynamic> json) => Bar(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      image: json['image'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      location: json['location'] == null
          ? null
          : BarLocation.fromJson(json['location'] as Map<String, dynamic>),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      openingHours: json['openingHours'] == null
          ? null
          : BarOpeningHours.fromJson(
              json['openingHours'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BarToJson(Bar instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'image': instance.image,
      'images': instance.images,
      'rating': instance.rating,
      'isActive': instance.isActive,
      'location': instance.location,
      'amenities': instance.amenities,
      'openingHours': instance.openingHours,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

BarLocation _$BarLocationFromJson(Map<String, dynamic> json) => BarLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
    );

Map<String, dynamic> _$BarLocationToJson(BarLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postalCode': instance.postalCode,
    };

BarOpeningHours _$BarOpeningHoursFromJson(Map<String, dynamic> json) =>
    BarOpeningHours(
      schedule: (json['schedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, DaySchedule.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$BarOpeningHoursToJson(BarOpeningHours instance) =>
    <String, dynamic>{
      'schedule': instance.schedule,
    };

DaySchedule _$DayScheduleFromJson(Map<String, dynamic> json) => DaySchedule(
      isOpen: json['isOpen'] as bool? ?? true,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      breakStart: json['breakStart'] as String?,
      breakEnd: json['breakEnd'] as String?,
    );

Map<String, dynamic> _$DayScheduleToJson(DaySchedule instance) =>
    <String, dynamic>{
      'isOpen': instance.isOpen,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'breakStart': instance.breakStart,
      'breakEnd': instance.breakEnd,
    };

CreateBarRequest _$CreateBarRequestFromJson(Map<String, dynamic> json) =>
    CreateBarRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      location: json['location'] == null
          ? null
          : BarLocation.fromJson(json['location'] as Map<String, dynamic>),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      openingHours: json['openingHours'] == null
          ? null
          : BarOpeningHours.fromJson(
              json['openingHours'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateBarRequestToJson(CreateBarRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'location': instance.location,
      'amenities': instance.amenities,
      'openingHours': instance.openingHours,
    };

BarFilters _$BarFiltersFromJson(Map<String, dynamic> json) => BarFilters(
      search: json['search'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble(),
      minRating: (json['minRating'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool?,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      sortBy: json['sortBy'] as String? ?? 'name',
      sortOrder: json['sortOrder'] as String? ?? 'asc',
    );

Map<String, dynamic> _$BarFiltersToJson(BarFilters instance) =>
    <String, dynamic>{
      'search': instance.search,
      'city': instance.city,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusKm': instance.radiusKm,
      'minRating': instance.minRating,
      'amenities': instance.amenities,
      'isActive': instance.isActive,
      'page': instance.page,
      'limit': instance.limit,
      'sortBy': instance.sortBy,
      'sortOrder': instance.sortOrder,
    };

BarsListResponse _$BarsListResponseFromJson(Map<String, dynamic> json) =>
    BarsListResponse(
      bars: (json['bars'] as List<dynamic>)
          .map((e) => Bar.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$BarsListResponseToJson(BarsListResponse instance) =>
    <String, dynamic>{
      'bars': instance.bars,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };
