// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialLinks _$SocialLinksFromJson(Map<String, dynamic> json) => SocialLinks(
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
    );

Map<String, dynamic> _$SocialLinksToJson(SocialLinks instance) =>
    <String, dynamic>{
      'facebook': instance.facebook,
      'instagram': instance.instagram,
    };

DayHours _$DayHoursFromJson(Map<String, dynamic> json) => DayHours(
      open: json['open'] as String?,
      close: json['close'] as String?,
    );

Map<String, dynamic> _$DayHoursToJson(DayHours instance) => <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
    };

WeekHours _$WeekHoursFromJson(Map<String, dynamic> json) => WeekHours(
      monday: json['monday'] == null
          ? null
          : DayHours.fromJson(json['monday'] as Map<String, dynamic>),
      tuesday: json['tuesday'] == null
          ? null
          : DayHours.fromJson(json['tuesday'] as Map<String, dynamic>),
      wednesday: json['wednesday'] == null
          ? null
          : DayHours.fromJson(json['wednesday'] as Map<String, dynamic>),
      thursday: json['thursday'] == null
          ? null
          : DayHours.fromJson(json['thursday'] as Map<String, dynamic>),
      friday: json['friday'] == null
          ? null
          : DayHours.fromJson(json['friday'] as Map<String, dynamic>),
      saturday: json['saturday'] == null
          ? null
          : DayHours.fromJson(json['saturday'] as Map<String, dynamic>),
      sunday: json['sunday'] == null
          ? null
          : DayHours.fromJson(json['sunday'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeekHoursToJson(WeekHours instance) => <String, dynamic>{
      'monday': instance.monday,
      'tuesday': instance.tuesday,
      'wednesday': instance.wednesday,
      'thursday': instance.thursday,
      'friday': instance.friday,
      'saturday': instance.saturday,
      'sunday': instance.sunday,
    };

Bar _$BarFromJson(Map<String, dynamic> json) => Bar(
      id: json['id'] as String,
      nameBar: json['nameBar'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      socialLinks: json['socialLinks'] == null
          ? null
          : SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>),
      hours: json['hours'] == null
          ? null
          : WeekHours.fromJson(json['hours'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BarToJson(Bar instance) => <String, dynamic>{
      'id': instance.id,
      'nameBar': instance.nameBar,
      'location': instance.location,
      'description': instance.description,
      'ownerId': instance.ownerId,
      'phone': instance.phone,
      'photo': instance.photo,
      'socialLinks': instance.socialLinks,
      'hours': instance.hours,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CreateBarRequest _$CreateBarRequestFromJson(Map<String, dynamic> json) =>
    CreateBarRequest(
      nameBar: json['nameBar'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      socialLinks: json['socialLinks'] == null
          ? null
          : SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>),
      hours: json['hours'] == null
          ? null
          : WeekHours.fromJson(json['hours'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateBarRequestToJson(CreateBarRequest instance) =>
    <String, dynamic>{
      'nameBar': instance.nameBar,
      'location': instance.location,
      'description': instance.description,
      'phone': instance.phone,
      'photo': instance.photo,
      'socialLinks': instance.socialLinks,
      'hours': instance.hours,
    };

UpdateBarRequest _$UpdateBarRequestFromJson(Map<String, dynamic> json) =>
    UpdateBarRequest(
      nameBar: json['nameBar'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      socialLinks: json['socialLinks'] == null
          ? null
          : SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>),
      hours: json['hours'] == null
          ? null
          : WeekHours.fromJson(json['hours'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateBarRequestToJson(UpdateBarRequest instance) =>
    <String, dynamic>{
      'nameBar': instance.nameBar,
      'location': instance.location,
      'description': instance.description,
      'phone': instance.phone,
      'photo': instance.photo,
      'socialLinks': instance.socialLinks,
      'hours': instance.hours,
      'isActive': instance.isActive,
    };
