import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reservation_models.g.dart';

/// Estados de una reserva
enum ReservationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

/// Extensión para ReservationStatus
extension ReservationStatusExtension on ReservationStatus {
  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pendiente';
      case ReservationStatus.confirmed:
        return 'Confirmada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
      case ReservationStatus.completed:
        return 'Completada';
    }
  }

  bool get isPending => this == ReservationStatus.pending;
  bool get isConfirmed => this == ReservationStatus.confirmed;
  bool get isCancelled => this == ReservationStatus.cancelled;
  bool get isCompleted => this == ReservationStatus.completed;
}

/// Modelo de Reserva
@JsonSerializable()
class Reservation extends Equatable {
  final String id;
  final String userId;
  final String barId;
  final DateTime reservationDate;
  final int numberOfPeople;
  final String customerName;
  final String customerPhone;
  final String? comments;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Datos populados (opcional)
  final Map<String, dynamic>? bar;
  final Map<String, dynamic>? user;

  const Reservation({
    required this.id,
    required this.userId,
    required this.barId,
    required this.reservationDate,
    required this.numberOfPeople,
    required this.customerName,
    required this.customerPhone,
    this.comments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.bar,
    this.user,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        barId,
        reservationDate,
        numberOfPeople,
        customerName,
        customerPhone,
        comments,
        status,
        createdAt,
        updatedAt,
        bar,
        user,
      ];

  Reservation copyWith({
    String? id,
    String? userId,
    String? barId,
    DateTime? reservationDate,
    int? numberOfPeople,
    String? customerName,
    String? customerPhone,
    String? comments,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? bar,
    Map<String, dynamic>? user,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barId: barId ?? this.barId,
      reservationDate: reservationDate ?? this.reservationDate,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bar: bar ?? this.bar,
      user: user ?? this.user,
    );
  }
}

/// Estado para la gestión de reservas
class ReservationsState extends Equatable {
  final List<Reservation> reservations;
  final Reservation? selectedReservation;
  final bool isLoading;
  final String? errorMessage;

  const ReservationsState({
    this.reservations = const [],
    this.selectedReservation,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        reservations,
        selectedReservation,
        isLoading,
        errorMessage,
      ];

  bool get hasError => errorMessage != null;
  bool get isEmpty => reservations.isEmpty;
  int get count => reservations.length;

  ReservationsState copyWith({
    List<Reservation>? reservations,
    Reservation? selectedReservation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReservationsState(
      reservations: reservations ?? this.reservations,
      selectedReservation: selectedReservation ?? this.selectedReservation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
