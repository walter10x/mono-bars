import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:front_bars_flutter/modules/reservations/models/reservation_models.dart';
import 'package:front_bars_flutter/modules/reservations/services/reservations_service.dart';

part 'reservations_controller.g.dart';

@riverpod
class ReservationsController extends _$ReservationsController {
  late final ReservationsService _service;

  @override
  ReservationsState build() {
    _service = ref.watch(reservationsServiceProvider);
    return const ReservationsState();
  }

  // Cargar mis reservas (cliente)
  Future<void> loadMyReservations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.getMyReservations();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (reservations) {
        state = state.copyWith(
          reservations: reservations,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  // Cargar reservas de los bares del owner
  Future<void> loadOwnerReservations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.getOwnerReservations();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (reservations) {
        state = state.copyWith(
          reservations: reservations,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  // Cargar una reserva específica
  Future<void> loadReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.getReservation(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (reservation) {
        state = state.copyWith(
          selectedReservation: reservation,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  // Crear nueva reserva
  Future<bool> createReservation(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.createReservation(data);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (reservation) {
        state = state.copyWith(
          reservations: [...state.reservations, reservation],
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  // Actualizar reserva
  Future<bool> updateReservation(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.updateReservation(id, data);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedReservation) {
        final updatedList = state.reservations.map((reservation) {
          return reservation.id == id ? updatedReservation : reservation;
        }).toList();

        state = state.copyWith(
          reservations: updatedList,
          selectedReservation: updatedReservation,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  // Cancelar reserva
  Future<bool> cancelReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.cancelReservation(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        // Recargar la reserva para obtener el estado actualizado
        loadReservation(id);
        return true;
      },
    );
  }

  // Confirmar reserva (owner)
  Future<bool> confirmReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.confirmReservation(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedReservation) {
        final updatedList = state.reservations.map((reservation) {
          return reservation.id == id ? updatedReservation : reservation;
        }).toList();

        state = state.copyWith(
          reservations: updatedList,
          selectedReservation: updatedReservation,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  // Completar reserva (owner)
  Future<bool> completeReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.completeReservation(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedReservation) {
        final updatedList = state.reservations.map((reservation) {
          return reservation.id == id ? updatedReservation : reservation;
        }).toList();

        state = state.copyWith(
          reservations: updatedList,
          selectedReservation: updatedReservation,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  // Eliminar reserva
  Future<bool> deleteReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.deleteReservation(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final updatedList = state.reservations
            .where((reservation) => reservation.id != id)
            .toList();

        state = state.copyWith(
          reservations: updatedList,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
