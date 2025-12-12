import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front_bars_flutter/modules/reservations/controllers/reservations_controller.dart';
import 'package:front_bars_flutter/modules/reservations/models/reservation_models.dart';
import 'package:intl/intl.dart';

/// Pantalla para que los clientes vean sus reservas
class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reservationsControllerProvider.notifier).loadMyReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationsState = ref.watch(reservationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: reservationsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservationsState.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(reservationsControllerProvider.notifier).loadMyReservations();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservationsState.reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservationsState.reservations[index];
                      return _buildReservationCard(reservation);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/client/reservations/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Reserva'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes reservas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera reserva',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final barName = reservation.bar?['nameBar'] ?? 'Bar no disponible';
    final barLocation = reservation.bar?['location'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Ver detalles de la reserva
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre del bar y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (barLocation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  barLocation,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusBadge(reservation.status),
                ],
              ),
              
              const Divider(height: 24),
              
              // Información de la reserva
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.calendar_today,
                      DateFormat('dd MMM yyyy', 'es').format(reservation.reservationDate),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.access_time,
                      DateFormat('HH:mm').format(reservation.reservationDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.people,
                '${reservation.numberOfPeople} ${reservation.numberOfPeople == 1 ? 'persona' : 'personas'}',
              ),
              
              // Botones de acción
              if (reservation.status.isPending || reservation.status.isConfirmed) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (reservation.status.isPending)
                      TextButton.icon(
                        onPressed: () => _showCancelDialog(reservation.id),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReservationStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case ReservationStatus.pending:
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case ReservationStatus.confirmed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case ReservationStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case ReservationStatus.completed:
        color = Colors.blue;
        icon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(String reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(reservationsControllerProvider.notifier)
                  .cancelReservation(reservationId);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva cancelada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.read(reservationsControllerProvider.notifier).loadMyReservations();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}
