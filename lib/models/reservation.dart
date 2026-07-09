enum ReservationStatus { pending, confirmed, declined }

extension ReservationStatusLabel on ReservationStatus {
  String get label => switch (this) {
    ReservationStatus.pending => 'Pending',
    ReservationStatus.confirmed => 'Confirmed',
    ReservationStatus.declined => 'Declined',
  };
}

/// A manual reservation log entry for a camp owner. Deliberately has no
/// camp/owner linkage field and no overlap-detection helper (unlike
/// [Trip]) — this is a record-keeping list for a solo owner to confirm,
/// decline, or log walk-in bookings by hand, not a capacity-enforcing
/// booking engine. Real booking/payments are out of scope per
/// docs/PRD.md's deferred marketplace phase.
class Reservation {
  const Reservation({
    required this.id,
    required this.guestName,
    required this.campName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final String id;
  final String guestName;
  final String campName;
  final DateTime startDate;
  final DateTime endDate;
  final ReservationStatus status;

  Reservation copyWith({ReservationStatus? status}) => Reservation(
    id: id,
    guestName: guestName,
    campName: campName,
    startDate: startDate,
    endDate: endDate,
    status: status ?? this.status,
  );
}
