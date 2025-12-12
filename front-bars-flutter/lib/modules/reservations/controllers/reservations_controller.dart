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

    try {
      final reservations = await _service.getMyReservations();
      state = state.copyWith(
        reservations: reservations,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Cargar reservas de los bares del owner
  Future<void> loadOwnerReservations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reservations = await _service.getOwnerReservations();
      state = state.copyWith(
        reservations: reservations,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Cargar una reserva específica
  Future<void> loadReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reservation = await _service.getReservation(id);
      state = state.copyWith(
        selectedReservation: reservation,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Crear nueva reserva
  Future<bool> createReservation(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reservation = await _service.createReservation(data);
      state = state.copyWith(
        reservations: [...state.reservations, reservation],
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Actualizar reserva
  Future<bool> updateReservation(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedReservation = await _service.updateReservation(id, data);
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Cancelar reserva
  Future<bool> cancelReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.cancelReservation(id);
      // Recargar la reserva para obtener el estado actualizado
      await loadReservation(id);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Confirmar reserva (owner)
  Future<bool> confirmReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedReservation = await _service.confirmReservation(id);
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Completar reserva (owner)
  Future<bool> completeReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedReservation = await _service.completeReservation(id);
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Eliminar reserva
  Future<bool> deleteReservation(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.deleteReservation(id);
      final updatedList = state.reservations
          .where((reservation) => reservation.id != id)
          .toList();

      state = state.copyWith(
        reservations: updatedList,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
