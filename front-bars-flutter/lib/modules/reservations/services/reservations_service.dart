import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_bars_flutter/core/network/dio_client.dart';
import 'package:front_bars_flutter/core/utils/either.dart';
import 'package:front_bars_flutter/core/errors/failure.dart';
import 'package:front_bars_flutter/modules/reservations/models/reservation_models.dart';

class ReservationsService {
  final DioClient _dioClient;

  ReservationsService(this._dioClient);

  // Crear nueva reserva
  Future<Either<Failure, Reservation>> createReservation(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.post('/reservations', data: data);
      return Right(Reservation.fromJson(response.data));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Obtener mis reservas (cliente)
  Future<Either<Failure, List<Reservation>>> getMyReservations() async {
    try {
      final response = await _dioClient.get('/reservations/my-reservations');
      final List<dynamic> data = response.data;
      final reservations = data.map((json) => Reservation.fromJson(json)).toList();
      return Right(reservations);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Obtener reservas de mis bares (owner)
  Future<Either<Failure, List<Reservation>>> getOwnerReservations() async {
    try {
      final response = await _dioClient.get('/reservations/owner-reservations');
      final List<dynamic> data = response.data;
      final reservations = data.map((json) => Reservation.fromJson(json)).toList();
      return Right(reservations);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Obtener una reserva específica
  Future<Either<Failure, Reservation>> getReservation(String id) async {
    try {
      final response = await _dioClient.get('/reservations/$id');
      return Right(Reservation.fromJson(response.data));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Actualizar reserva
  Future<Either<Failure, Reservation>> updateReservation(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.patch('/reservations/$id', data: data);
      return Right(Reservation.fromJson(response.data));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Cancelar reserva
  Future<Either<Failure, void>> cancelReservation(String id) async {
    try {
      await _dioClient.patch('/reservations/$id/cancel');
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Confirmar reserva (owner)
  Future<Either<Failure, Reservation>> confirmReservation(String id) async {
    try {
      final response = await _dioClient.patch('/reservations/$id/confirm');
      return Right(Reservation.fromJson(response.data));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Completar reserva (owner)
  Future<Either<Failure, Reservation>> completeReservation(String id) async {
    try {
      final response = await _dioClient.patch('/reservations/$id/complete');
      return Right(Reservation.fromJson(response.data));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  // Eliminar reserva
  Future<Either<Failure, void>> deleteReservation(String id) async {
    try {
      await _dioClient.delete('/reservations/$id');
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}

// Provider
final reservationsServiceProvider = Provider<ReservationsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReservationsService(dioClient);
});
