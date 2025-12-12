import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_bars_flutter/modules/reservations/controllers/reservations_controller.dart';
import 'package:front_bars_flutter/modules/reservations/models/reservation_models.dart';
import 'package:intl/intl.dart';

/// Pantalla para que los owners gestionen las reservas de sus bares
class OwnerReservationsManagementScreen extends ConsumerStatefulWidget {
  const OwnerReservationsManagementScreen({super.key});

  @override
  ConsumerState<OwnerReservationsManagementScreen> createState() =>
      _OwnerReservationsManagementScreenState();
}

class _OwnerReservationsManagementScreenState
    extends ConsumerState<OwnerReservationsManagementScreen> {
  String _selectedFilter = 'all'; // all, pending, confirmed, completed

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reservationsControllerProvider.notifier).loadOwnerReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationsState = ref.watch(reservationsControllerProvider);
    final filteredReservations = _getFilteredReservations(reservationsState.reservations);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilterChips(),
          
          // Lista de reservas
          Expanded(
            child: reservationsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReservations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(reservationsControllerProvider.notifier)
                              .loadOwnerReservations();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredReservations.length,
                          itemBuilder: (context, index) {
                            final reservation = filteredReservations[index];
                            return _buildReservationCard(reservation);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<Reservation> _getFilteredReservations(List<Reservation> reservations) {
    switch (_selectedFilter) {
      case 'pending':
        return reservations.where((r) => r.status.isPending).toList();
      case 'confirmed':
        return reservations.where((r) => r.status.isConfirmed).toList();
      case 'completed':
        return reservations.where((r) => r.status.isCompleted).toList();
      default:
        return reservations;
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todas', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pendientes', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Confirmadas', 'confirmed'),
            const SizedBox(width: 8),
            _buildFilterChip('Completadas', 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6366F1),
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
            'No hay reservas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final barName = reservation.bar?['nameBar'] ?? 'Bar no disponible';
    final userName = reservation.user?['fullName'] ?? 'Cliente';
    final userPhone = reservation.user?['phone'] ?? reservation.customerPhone;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(reservation.status),
              ],
            ),

            const Divider(height: 24),

            // Detalles de la reserva
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.calendar_today,
                    DateFormat('dd MMM yyyy', 'es')
                        .format(reservation.reservationDate),
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
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.people,
                    '${reservation.numberOfPeople} ${reservation.numberOfPeople == 1 ? 'persona' : 'personas'}',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.phone,
                    userPhone,
                  ),
                ),
              ],
            ),

            if (reservation.comments != null && reservation.comments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservation.comments!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Botones de acción
            const SizedBox(height: 16),
            _buildActionButtons(reservation),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Reservation reservation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (reservation.status.isPending) ...[
          OutlinedButton.icon(
            onPressed: () => _showRejectDialog(reservation.id),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Rechazar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _confirmReservation(reservation.id),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirmar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
          ),
        ],
        if (reservation.status.isConfirmed) ...[
          ElevatedButton.icon(
            onPressed: () => _completeReservation(reservation.id),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Completar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
          ),
        ],
      ],
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
              fontSize: 13,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReservation(String id) async {
    final success = await ref
        .read(reservationsControllerProvider.notifier)
        .confirmReservation(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _completeReservation(String id) async {
    final success = await ref
        .read(reservationsControllerProvider.notifier)
        .completeReservation(id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva completada exitosamente'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showRejectDialog(String reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas rechazar esta reserva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
                    content: Text('Reserva rechazada'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}
