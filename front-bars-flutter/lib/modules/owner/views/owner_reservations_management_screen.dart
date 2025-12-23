import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_bars_flutter/modules/reservations/controllers/reservations_controller.dart';
import 'package:front_bars_flutter/modules/reservations/models/reservation_models.dart';
import 'package:intl/intl.dart';

/// Pantalla para que los owners gestionen las reservas de sus bares
/// Rediseñada con tema oscuro premium
class OwnerReservationsManagementScreen extends ConsumerStatefulWidget {
  const OwnerReservationsManagementScreen({super.key});

  @override
  ConsumerState<OwnerReservationsManagementScreen> createState() =>
      _OwnerReservationsManagementScreenState();
}

class _OwnerReservationsManagementScreenState
    extends ConsumerState<OwnerReservationsManagementScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);
  
  // Color accent para reservas (púrpura)
  static const reservationAccent = Color(0xFF8B5CF6);

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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con estilo premium
            _buildHeader(filteredReservations.length),

            // Filtros
            _buildFilterChips(),

            // Lista de reservas
            Expanded(
              child: reservationsState.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: accentAmber),
                    )
                  : filteredReservations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(reservationsControllerProvider.notifier)
                                .loadOwnerReservations();
                          },
                          color: accentAmber,
                          backgroundColor: primaryDark,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filteredReservations.length,
                            itemBuilder: (context, index) {
                              final reservation = filteredReservations[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildReservationCard(reservation),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: reservationAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: reservationAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [accentAmber, accentGold],
                  ).createShader(bounds),
                  child: const Text(
                    'Gestión de Reservas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: reservationAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: reservationAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      count == 1 ? 'reserva' : 'reservas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todas', 'all', Icons.list),
            const SizedBox(width: 10),
            _buildFilterChip('Pendientes', 'pending', Icons.schedule),
            const SizedBox(width: 10),
            _buildFilterChip('Confirmadas', 'confirmed', Icons.check_circle),
            const SizedBox(width: 10),
            _buildFilterChip('Completadas', 'completed', Icons.done_all),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [accentAmber, accentGold])
                : null,
            color: isSelected ? null : primaryDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : accentAmber.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: reservationAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 80,
              color: reservationAccent.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay reservas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las reservas de tus bares aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(reservation.status),
            ],
          ),

          Divider(
            height: 24,
            color: Colors.white.withOpacity(0.1),
          ),

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
          const SizedBox(height: 10),
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
                color: secondaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservation.comments!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
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
    );
  }

  Widget _buildActionButtons(Reservation reservation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (reservation.status.isPending) ...[
          _buildActionButton(
            icon: Icons.close,
            label: 'Rechazar',
            color: const Color(0xFFEF4444),
            onTap: () => _showRejectDialog(reservation.id),
          ),
          const SizedBox(width: 10),
          _buildPrimaryActionButton(
            icon: Icons.check,
            label: 'Confirmar',
            color: const Color(0xFF10B981),
            onTap: () => _confirmReservation(reservation.id),
          ),
        ],
        if (reservation.status.isConfirmed) ...[
          _buildPrimaryActionButton(
            icon: Icons.done_all,
            label: 'Completar',
            color: reservationAccent,
            onTap: () => _completeReservation(reservation.id),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
        color = accentAmber;
        icon = Icons.schedule;
        break;
      case ReservationStatus.confirmed:
        color = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      case ReservationStatus.cancelled:
        color = const Color(0xFFEF4444);
        icon = Icons.cancel;
        break;
      case ReservationStatus.completed:
        color = reservationAccent;
        icon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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
        Icon(
          icon,
          size: 14,
          color: Colors.white.withOpacity(0.5),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
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
        SnackBar(
          content: const Text('Reserva confirmada exitosamente'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        SnackBar(
          content: const Text('Reserva completada exitosamente'),
          backgroundColor: reservationAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showRejectDialog(String reservationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accentAmber.withOpacity(0.2),
          ),
        ),
        title: const Text(
          'Rechazar Reserva',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas rechazar esta reserva?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  Navigator.pop(dialogContext);
                  final success = await ref
                      .read(reservationsControllerProvider.notifier)
                      .cancelReservation(reservationId);

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Reserva rechazada'),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Rechazar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
