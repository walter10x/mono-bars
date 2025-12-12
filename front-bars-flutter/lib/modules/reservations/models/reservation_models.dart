import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_models.freezed.dart';
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
@freezed
class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String userId,
    required String barId,
    required DateTime reservationDate,
    required int numberOfPeople,
    required String customerName,
    required String customerPhone,
    String? comments,
    required ReservationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Datos populados (opcional)
    Map<String, dynamic>? bar,
    Map<String, dynamic>? user,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

/// Estado para la gestión de reservas
@freezed
class ReservationsState with _$ReservationsState {
  const factory ReservationsState({
    @Default([]) List<Reservation> reservations,
    Reservation? selectedReservation,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ReservationsState;

  const ReservationsState._();

  bool get hasError => errorMessage != null;
  bool get isEmpty => reservations.isEmpty;
  int get count => reservations.length;
}
