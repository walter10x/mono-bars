import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_models.g.dart';

/// Modelo de Reseña
@JsonSerializable()
class Review extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? barId;
  final String? userId;
  final int rating;
  final String comment;
  final String? ownerResponse;
  final DateTime? responseDate;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Campos poblados (cuando se hace populate en el backend)
  final ReviewUser? user;
  final ReviewBar? bar;

  const Review({
    this.id,
    this.barId,
    this.userId,
    required this.rating,
    required this.comment,
    this.ownerResponse,
    this.responseDate,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.bar,
  });

  /// Factory personalizado para manejar userId como String o como objeto poblado
  factory Review.fromJson(Map<String, dynamic> json) {
    // Manejar userId que puede ser String o Map (cuando está poblado)
    String? userId;
    ReviewUser? user;
    
    final userIdValue = json['userId'];
    if (userIdValue is String) {
      userId = userIdValue;
    } else if (userIdValue is Map<String, dynamic>) {
      userId = userIdValue['_id'] as String?;
      user = ReviewUser.fromJson(userIdValue);
    }
    
    // Manejar barId que puede ser String o Map (cuando está poblado)
    String? barId;
    ReviewBar? bar;
    
    final barIdValue = json['barId'];
    if (barIdValue is String) {
      barId = barIdValue;
    } else if (barIdValue is Map<String, dynamic>) {
      barId = barIdValue['_id'] as String?;
      bar = ReviewBar.fromJson(barIdValue);
    }
    
    return Review(
      id: json['_id'] as String?,
      barId: barId,
      userId: userId,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      ownerResponse: json['ownerResponse'] as String?,
      responseDate: json['responseDate'] != null 
          ? DateTime.parse(json['responseDate'] as String) 
          : null,
      isVisible: json['isVisible'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      user: user,
      bar: bar,
    );
  }
  
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  List<Object?> get props => [id, barId, userId, rating, comment, ownerResponse, createdAt];

  /// Verificar si tiene respuesta del owner
  bool get hasOwnerResponse => ownerResponse != null && ownerResponse!.isNotEmpty;

  /// Fecha formateada
  String get formattedDate {
    if (createdAt == null) return 'Fecha desconocida';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Hace ${diff.inMinutes} minutos';
      }
      return 'Hace ${diff.inHours} horas';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else if (diff.inDays < 30) {
      return 'Hace ${(diff.inDays / 7).floor()} semanas';
    } else {
      return 'Hace ${(diff.inDays / 30).floor()} meses';
    }
  }
}

/// Usuario simplificado para reseñas
@JsonSerializable()
class ReviewUser extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? fullName;
  final String? email;

  const ReviewUser({
    this.id,
    this.fullName,
    this.email,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) => _$ReviewUserFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewUserToJson(this);

  @override
  List<Object?> get props => [id, fullName, email];

  /// Obtener iniciales del nombre
  String get initials {
    if (fullName == null || fullName!.isEmpty) return 'U';
    final parts = fullName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName![0].toUpperCase();
  }
}

/// Bar simplificado para reseñas
@JsonSerializable()
class ReviewBar extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? nameBar;
  final String? location;
  final String? photo;

  const ReviewBar({
    this.id,
    this.nameBar,
    this.location,
    this.photo,
  });

  factory ReviewBar.fromJson(Map<String, dynamic> json) => _$ReviewBarFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewBarToJson(this);

  @override
  List<Object?> get props => [id, nameBar, location, photo];
}

/// DTO para crear reseña
@JsonSerializable()
class CreateReviewDto {
  final String barId;
  final int rating;
  final String comment;

  const CreateReviewDto({
    required this.barId,
    required this.rating,
    required this.comment,
  });

  factory CreateReviewDto.fromJson(Map<String, dynamic> json) => _$CreateReviewDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReviewDtoToJson(this);
}

/// DTO para actualizar reseña
@JsonSerializable()
class UpdateReviewDto {
  final int? rating;
  final String? comment;

  const UpdateReviewDto({
    this.rating,
    this.comment,
  });

  factory UpdateReviewDto.fromJson(Map<String, dynamic> json) => _$UpdateReviewDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateReviewDtoToJson(this);
}

/// DTO para respuesta del owner
@JsonSerializable()
class OwnerResponseDto {
  final String response;

  const OwnerResponseDto({
    required this.response,
  });

  factory OwnerResponseDto.fromJson(Map<String, dynamic> json) => _$OwnerResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerResponseDtoToJson(this);
}

/// Estadísticas de reseñas de un bar
@JsonSerializable()
class ReviewStats extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingDistribution;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) => _$ReviewStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewStatsToJson(this);

  @override
  List<Object?> get props => [averageRating, totalReviews, ratingDistribution];

  /// Porcentaje de cada rating
  double getPercentage(int rating) {
    if (totalReviews == 0) return 0;
    final count = ratingDistribution[rating.toString()] ?? 0;
    return (count / totalReviews) * 100;
  }
}
