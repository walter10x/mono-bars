import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_bars_flutter/core/network/dio_client.dart';
import 'package:front_bars_flutter/modules/reservations/models/reservation_models.dart';

class ReservationsService {
  final DioClient _dioClient;

  ReservationsService(this._dioClient);

  // Crear nueva reserva
  Future<Reservation> createReservation(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/reservations', data: data);
    return Reservation.fromJson(response.data);
  }

  // Obtener mis reservas (cliente)
  Future<List<Reservation>> getMyReservations() async {
    final response = await _dioClient.get('/reservations/my-reservations');
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  // Obtener reservas de mis bares (owner)
  Future<List<Reservation>> getOwnerReservations() async {
    final response = await _dioClient.get('/reservations/owner-reservations');
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  // Obtener una reserva específica
  Future<Reservation> getReservation(String id) async {
    final response = await _dioClient.get('/reservations/$id');
    return Reservation.fromJson(response.data);
  }

  // Actualizar reserva
  Future<Reservation> updateReservation(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.put('/reservations/$id', data: data);
    return Reservation.fromJson(response.data);
  }

  // Cancelar reserva
  Future<void> cancelReservation(String id) async {
    await _dioClient.put('/reservations/$id/cancel');
  }

  // Confirmar reserva (owner)
  Future<Reservation> confirmReservation(String id) async {
    final response = await _dioClient.put('/reservations/$id/confirm');
    return Reservation.fromJson(response.data);
  }

  // Completar reserva (owner)
  Future<Reservation> completeReservation(String id) async {
    final response = await _dioClient.put('/reservations/$id/complete');
    return Reservation.fromJson(response.data);
  }

  // Eliminar reserva
  Future<void> deleteReservation(String id) async {
    await _dioClient.delete('/reservations/$id');
  }
}

// Provider
final reservationsServiceProvider = Provider<ReservationsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReservationsService(dioClient);
});
