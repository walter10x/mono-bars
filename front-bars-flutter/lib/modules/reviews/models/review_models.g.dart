// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: json['_id'] as String?,
      barId: json['barId'] as String?,
      userId: json['userId'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      ownerResponse: json['ownerResponse'] as String?,
      responseDate: json['responseDate'] == null
          ? null
          : DateTime.parse(json['responseDate'] as String),
      isVisible: json['isVisible'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      user: json['user'] == null
          ? null
          : ReviewUser.fromJson(json['user'] as Map<String, dynamic>),
      bar: json['bar'] == null
          ? null
          : ReviewBar.fromJson(json['bar'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      '_id': instance.id,
      'barId': instance.barId,
      'userId': instance.userId,
      'rating': instance.rating,
      'comment': instance.comment,
      'ownerResponse': instance.ownerResponse,
      'responseDate': instance.responseDate?.toIso8601String(),
      'isVisible': instance.isVisible,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'user': instance.user,
      'bar': instance.bar,
    };

ReviewUser _$ReviewUserFromJson(Map<String, dynamic> json) => ReviewUser(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$ReviewUserToJson(ReviewUser instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
    };

ReviewBar _$ReviewBarFromJson(Map<String, dynamic> json) => ReviewBar(
      id: json['_id'] as String?,
      nameBar: json['nameBar'] as String?,
      location: json['location'] as String?,
      photo: json['photo'] as String?,
    );

Map<String, dynamic> _$ReviewBarToJson(ReviewBar instance) => <String, dynamic>{
      '_id': instance.id,
      'nameBar': instance.nameBar,
      'location': instance.location,
      'photo': instance.photo,
    };

CreateReviewDto _$CreateReviewDtoFromJson(Map<String, dynamic> json) =>
    CreateReviewDto(
      barId: json['barId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$CreateReviewDtoToJson(CreateReviewDto instance) =>
    <String, dynamic>{
      'barId': instance.barId,
      'rating': instance.rating,
      'comment': instance.comment,
    };

UpdateReviewDto _$UpdateReviewDtoFromJson(Map<String, dynamic> json) =>
    UpdateReviewDto(
      rating: (json['rating'] as num?)?.toInt(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$UpdateReviewDtoToJson(UpdateReviewDto instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'comment': instance.comment,
    };

OwnerResponseDto _$OwnerResponseDtoFromJson(Map<String, dynamic> json) =>
    OwnerResponseDto(
      response: json['response'] as String,
    );

Map<String, dynamic> _$OwnerResponseDtoToJson(OwnerResponseDto instance) =>
    <String, dynamic>{
      'response': instance.response,
    };

ReviewStats _$ReviewStatsFromJson(Map<String, dynamic> json) => ReviewStats(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      ratingDistribution:
          Map<String, int>.from(json['ratingDistribution'] as Map),
    );

Map<String, dynamic> _$ReviewStatsToJson(ReviewStats instance) =>
    <String, dynamic>{
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'ratingDistribution': instance.ratingDistribution,
    };
