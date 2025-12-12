// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      barId: json['barId'] as String,
      reservationDate: DateTime.parse(json['reservationDate'] as String),
      numberOfPeople: (json['numberOfPeople'] as num).toInt(),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      comments: json['comments'] as String?,
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bar: json['bar'] as Map<String, dynamic>?,
      user: json['user'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'barId': instance.barId,
      'reservationDate': instance.reservationDate.toIso8601String(),
      'numberOfPeople': instance.numberOfPeople,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'comments': instance.comments,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'bar': instance.bar,
      'user': instance.user,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.completed: 'completed',
};
