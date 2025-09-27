import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bar_models.g.dart';

/// Modelo de bar
@JsonSerializable()
class Bar extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? image;
  final List<String> images;
  final double? rating;
  final bool isActive;
  final BarLocation? location;
  final List<String> amenities;
  final BarOpeningHours? openingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bar({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.image,
    this.images = const [],
    this.rating,
    this.isActive = true,
    this.location,
    this.amenities = const [],
    this.openingHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bar.fromJson(Map<String, dynamic> json) => _$BarFromJson(json);

  Map<String, dynamic> toJson() => _$BarToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        phone,
        email,
        website,
        image,
        images,
        rating,
        isActive,
        location,
        amenities,
        openingHours,
        createdAt,
        updatedAt,
      ];

  Bar copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? image,
    List<String>? images,
    double? rating,
    bool? isActive,
    BarLocation? location,
    List<String>? amenities,
    BarOpeningHours? openingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bar(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      image: image ?? this.image,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      amenities: amenities ?? this.amenities,
      openingHours: openingHours ?? this.openingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de ubicación del bar
@JsonSerializable()
class BarLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  const BarLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory BarLocation.fromJson(Map<String, dynamic> json) =>
      _$BarLocationFromJson(json);

  Map<String, dynamic> toJson() => _$BarLocationToJson(this);

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        city,
        state,
        country,
        postalCode,
      ];
}

/// Modelo de horarios de apertura
@JsonSerializable()
class BarOpeningHours extends Equatable {
  final Map<String, DaySchedule> schedule;

  const BarOpeningHours({
    required this.schedule,
  });

  factory BarOpeningHours.fromJson(Map<String, dynamic> json) =>
      _$BarOpeningHoursFromJson(json);

  Map<String, dynamic> toJson() => _$BarOpeningHoursToJson(this);

  @override
  List<Object?> get props => [schedule];
}

/// Horario de un día específico
@JsonSerializable()
class DaySchedule extends Equatable {
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final String? breakStart;
  final String? breakEnd;

  const DaySchedule({
    this.isOpen = true,
    this.openTime,
    this.closeTime,
    this.breakStart,
    this.breakEnd,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) =>
      _$DayScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$DayScheduleToJson(this);

  @override
  List<Object?> get props => [isOpen, openTime, closeTime, breakStart, breakEnd];
}

/// Request para crear/actualizar bar
@JsonSerializable()
class CreateBarRequest extends Equatable {
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final BarLocation? location;
  final List<String> amenities;
  final BarOpeningHours? openingHours;

  const CreateBarRequest({
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.location,
    this.amenities = const [],
    this.openingHours,
  });

  factory CreateBarRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBarRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBarRequestToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        address,
        phone,
        email,
        website,
        location,
        amenities,
        openingHours,
      ];
}

/// Filtros para buscar bares
@JsonSerializable()
class BarFilters extends Equatable {
  final String? search;
  final String? city;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final double? minRating;
  final List<String>? amenities;
  final bool? isActive;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  const BarFilters({
    this.search,
    this.city,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.minRating,
    this.amenities,
    this.isActive,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
  });

  factory BarFilters.fromJson(Map<String, dynamic> json) =>
      _$BarFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$BarFiltersToJson(this);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (city != null && city!.isNotEmpty) params['city'] = city;
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    if (radiusKm != null) params['radiusKm'] = radiusKm.toString();
    if (minRating != null) params['minRating'] = minRating.toString();
    if (amenities != null && amenities!.isNotEmpty) params['amenities'] = amenities!.join(',');
    if (isActive != null) params['isActive'] = isActive.toString();
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    
    return params;
  }

  @override
  List<Object?> get props => [
        search,
        city,
        latitude,
        longitude,
        radiusKm,
        minRating,
        amenities,
        isActive,
        page,
        limit,
        sortBy,
        sortOrder,
      ];

  BarFilters copyWith({
    String? search,
    String? city,
    double? latitude,
    double? longitude,
    double? radiusKm,
    double? minRating,
    List<String>? amenities,
    bool? isActive,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return BarFilters(
      search: search ?? this.search,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      amenities: amenities ?? this.amenities,
      isActive: isActive ?? this.isActive,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Response para lista de bares
@JsonSerializable()
class BarsListResponse extends Equatable {
  final List<Bar> bars;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  const BarsListResponse({
    required this.bars,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory BarsListResponse.fromJson(Map<String, dynamic> json) =>
      _$BarsListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BarsListResponseToJson(this);

  @override
  List<Object?> get props => [bars, total, page, limit, hasNext, hasPrev];
}
