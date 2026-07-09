import 'package:flutter/material.dart';

import '../data/sample_reservations.dart';
import '../models/reservation.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'add_reservation_screen.dart';

/// Shown when the dashboard is reached without a real signed-in session
/// (e.g. via Landing's "Preview Camp Owner View (test)" shortcut).
const _defaultBusinessName = 'Daraitan Basecamp';
const _defaultHostName = 'Mang Rodel';

class CampOwnerDashboardScreen extends StatefulWidget {
  const CampOwnerDashboardScreen({super.key});

  @override
  State<CampOwnerDashboardScreen> createState() =>
      _CampOwnerDashboardScreenState();
}

class _CampOwnerDashboardScreenState extends State<CampOwnerDashboardScreen> {
  late List<Reservation> _reservations;

  @override
  void initState() {
    super.initState();
    _reservations = List.of(sampleReservations);
  }

  List<Reservation> get _sorted {
    const order = {
      ReservationStatus.pending: 0,
      ReservationStatus.confirmed: 1,
      ReservationStatus.declined: 2,
    };
    final sorted = List.of(_reservations)
      ..sort((a, b) {
        final statusCompare = order[a.status]!.compareTo(order[b.status]!);
        if (statusCompare != 0) return statusCompare;
        return a.startDate.compareTo(b.startDate);
      });
    return sorted;
  }

  void _setStatus(Reservation reservation, ReservationStatus status) {
    final index = sampleReservations.indexWhere(
      (r) => r.id == reservation.id,
    );
    if (index == -1) return;
    sampleReservations[index] = reservation.copyWith(status: status);
    setState(() => _reservations = List.of(sampleReservations));

    final verb = status == ReservationStatus.confirmed
        ? 'Confirmed'
        : 'Declined';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$verb ${reservation.guestName}'s reservation.")),
    );
  }

  Future<void> _addReservation() async {
    final reservation = await Navigator.of(context).push<Reservation>(
      MaterialPageRoute(builder: (_) => const AddReservationScreen()),
    );
    if (reservation == null || !mounted) return;
    setState(() => _reservations = List.of(sampleReservations));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added ${reservation.guestName}'s reservation.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthService.instance.currentSession;
    return Scaffold(
      appBar: AppBar(title: const Text('Camp Owner Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addReservationButton'),
        onPressed: _addReservation,
        icon: const Icon(Icons.add),
        label: const Text('Add Reservation'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _BusinessHeader(
                  businessName: session?.campsiteName ?? _defaultBusinessName,
                  hostName: session?.fullName ?? _defaultHostName,
                  hostEmail: session?.email,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Reservations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_pendingCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '$_pendingCount pending',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (_reservations.isEmpty)
                  const _EmptyReservations()
                else
                  for (final reservation in _sorted) ...[
                    _ReservationCard(
                      reservation: reservation,
                      onConfirm: () =>
                          _setStatus(reservation, ReservationStatus.confirmed),
                      onDecline: () =>
                          _setStatus(reservation, ReservationStatus.declined),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  int get _pendingCount =>
      _reservations.where((r) => r.status == ReservationStatus.pending).length;
}

class _BusinessHeader extends StatelessWidget {
  const _BusinessHeader({
    required this.businessName,
    required this.hostName,
    this.hostEmail,
  });

  final String businessName;
  final String hostName;
  final String? hostEmail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    final hostedByLine = hostEmail == null
        ? 'Hosted by $hostName'
        : 'Hosted by $hostName · $hostEmail';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(Icons.storefront, color: accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  hostedByLine,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Chip(
                  avatar: const Icon(Icons.holiday_village, size: 16),
                  label: const Text('Camp Owner'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No reservations yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onConfirm,
    required this.onDecline,
  });

  final Reservation reservation;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _statusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (reservation.status) {
      case ReservationStatus.pending:
        return AppColors.gold;
      case ReservationStatus.confirmed:
        return isDark ? AppColors.brandDark : AppColors.brand;
      case ReservationStatus.declined:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(context);

    return Container(
      key: Key('reservationCard_${reservation.id}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.guestName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Chip(
                label: Text(reservation.status.label),
                backgroundColor: statusColor.withValues(alpha: 0.12),
                labelStyle: TextStyle(color: statusColor, fontSize: 12),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reservation.campName,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: isDark ? AppColors.brandDark : AppColors.brand,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(reservation.startDate)} → ${_formatDate(reservation.endDate)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          if (reservation.status == ReservationStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: Key('confirmReservationButton_${reservation.id}'),
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: Key('declineReservationButton_${reservation.id}'),
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
