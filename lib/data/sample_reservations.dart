import '../models/reservation.dart';

/// Placeholder reservation list. There's no `reservations` schema in
/// Supabase yet, and no real camp-owner-to-camp linkage (see
/// docs/ux/wireframes.md "Camp Owner Dashboard").
///
/// Mutated in place (`sampleReservations.add(...)`, entries replaced via
/// `copyWith` on confirm/decline), not copied-then-mutated — following the
/// same pattern as `sample_trips.dart`. The Camp Owner Dashboard is
/// currently the only screen that reads and mutates this list, but it's
/// still the canonical mutable source (rather than screen-local State) so
/// Confirm/Decline and Add Reservation stay consistent with how every
/// other cross-mutation dataset in this app behaves.
final List<Reservation> sampleReservations = [
  Reservation(
    id: 'res_seed_pending_1',
    guestName: 'Miguel Santos',
    campName: 'Mt. Daraitan campsite',
    startDate: DateTime.now().add(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 7)),
    status: ReservationStatus.pending,
  ),
  Reservation(
    id: 'res_seed_confirmed_1',
    guestName: 'Andrea Cruz',
    campName: 'Nasugbu beach camp',
    startDate: DateTime.now().add(const Duration(days: 12)),
    endDate: DateTime.now().add(const Duration(days: 14)),
    status: ReservationStatus.confirmed,
  ),
  Reservation(
    id: 'res_seed_pending_2',
    guestName: 'Paolo Ramos',
    campName: 'Taal Lake shoreline',
    startDate: DateTime.now().add(const Duration(days: 20)),
    endDate: DateTime.now().add(const Duration(days: 21)),
    status: ReservationStatus.pending,
  ),
  Reservation(
    id: 'res_seed_declined_1',
    guestName: 'Liza Fernandez',
    campName: 'Mt. Daraitan campsite',
    startDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().subtract(const Duration(days: 1)),
    status: ReservationStatus.declined,
  ),
];
