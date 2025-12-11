import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bar_models.g.dart';

/// Modelo de redes sociales del bar
@JsonSerializable()
class SocialLinks extends Equatable {
  final String? facebook;
  final String? instagram;

  const SocialLinks({
    this.facebook,
    this.instagram,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) =>
      _$SocialLinksFromJson(json);

  Map<String, dynamic> toJson() => _$SocialLinksToJson(this);

  @override
  List<Object?> get props => [facebook, instagram];

  SocialLinks copyWith({
    String? facebook,
    String? instagram,
  }) {
    return SocialLinks(
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
    );
  }
}

/// Modelo de horario de un día
@JsonSerializable()
class DayHours extends Equatable {
  final String? open;
  final String? close;

  const DayHours({
    this.open,
    this.close,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) =>
      _$DayHoursFromJson(json);

  Map<String, dynamic> toJson() => _$DayHoursToJson(this);

  @override
  List<Object?> get props => [open, close];

  DayHours copyWith({
    String? open,
    String? close,
  }) {
    return DayHours(
      open: open ?? this.open,
      close: close ?? this.close,
    );
  }
}

/// Modelo de horarios de la semana
@JsonSerializable()
class WeekHours extends Equatable {
  final DayHours? monday;
  final DayHours? tuesday;
  final DayHours? wednesday;
  final DayHours? thursday;
  final DayHours? friday;
  final DayHours? saturday;
  final DayHours? sunday;

  const WeekHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory WeekHours.fromJson(Map<String, dynamic> json) =>
      _$WeekHoursFromJson(json);

  Map<String, dynamic> toJson() => _$WeekHoursToJson(this);

  @override
  List<Object?> get props => [
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday,
      ];

  WeekHours copyWith({
    DayHours? monday,
    DayHours? tuesday,
    DayHours? wednesday,
    DayHours? thursday,
    DayHours? friday,
    DayHours? saturday,
    DayHours? sunday,
  }) {
    return WeekHours(
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
    );
  }
}

/// Modelo principal de Bar - Adaptado al backend
@JsonSerializable()
class Bar extends Equatable {
  final String id;
  final String nameBar; // Nombre exacto del backend
  final String location; // Location es string simple en backend
  final String? description;
  final String ownerId;
  final String? phone;
  final String? photo;
  final SocialLinks? socialLinks;
  final WeekHours? hours;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Bar({
    required this.id,
    required this.nameBar,
    required this.location,
    this.description,
    required this.ownerId,
    this.phone,
    this.photo,
    this.socialLinks,
    this.hours,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Bar.fromJson(Map<String, dynamic> json) => _$BarFromJson(json);

  Map<String, dynamic> toJson() => _$BarToJson(this);

  @override
  List<Object?> get props => [
        id,
        nameBar,
        location,
        description,
        ownerId,
        phone,
        photo,
        socialLinks,
        hours,
        isActive,
        createdAt,
        updatedAt,
      ];

  Bar copyWith({
    String? id,
    String? nameBar,
    String? location,
    String? description,
    String? ownerId,
    String? phone,
    String? photo,
    SocialLinks? socialLinks,
    WeekHours? hours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bar(
      id: id ?? this.id,
      nameBar: nameBar ?? this.nameBar,
      location: location ?? this.location,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      socialLinks: socialLinks ?? this.socialLinks,
      hours: hours ?? this.hours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request para crear un bar
@JsonSerializable()
class CreateBarRequest extends Equatable {
  final String nameBar;
  final String location;
  final String? description;
  final String? phone;
  final String? photo;
  final SocialLinks? socialLinks;
  final WeekHours? hours;

  const CreateBarRequest({
    required this.nameBar,
    required this.location,
    this.description,
    this.phone,
    this.photo,
    this.socialLinks,
    this.hours,
  });

  factory CreateBarRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBarRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBarRequestToJson(this);

  @override
  List<Object?> get props => [
        nameBar,
        location,
        description,
        phone,
        photo,
        socialLinks,
        hours,
      ];
}

/// Request para actualizar un bar
@JsonSerializable()
class UpdateBarRequest extends Equatable {
  final String? nameBar;
  final String? location;
  final String? description;
  final String? phone;
  final String? photo;
  final SocialLinks? socialLinks;
  final WeekHours? hours;
  final bool? isActive;

  const UpdateBarRequest({
    this.nameBar,
    this.location,
    this.description,
    this.phone,
    this.photo,
    this.socialLinks,
    this.hours,
    this.isActive,
  });

  factory UpdateBarRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBarRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBarRequestToJson(this);

  @override
  List<Object?> get props => [
        nameBar,
        location,
        description,
        phone,
        photo,
        socialLinks,
        hours,
        isActive,
      ];
}
