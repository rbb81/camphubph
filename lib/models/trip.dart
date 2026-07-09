class Trip {
  const Trip({
    required this.id,
    required this.campId,
    required this.campName,
    required this.campLocation,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String campId;
  final String campName;
  final String campLocation;
  final DateTime startDate;
  final DateTime endDate;

  /// True if the two [startDate, endDate) ranges share at least one night.
  /// Half-open on purpose: a checkout on day N and a different trip's
  /// check-in on day N do NOT share a night, so that's not a conflict
  /// (matches real-world back-to-back booking behavior).
  static bool rangesOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) => startA.isBefore(endB) && startB.isBefore(endA);

  static Trip? findConflict(
    List<Trip> trips, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    for (final trip in trips) {
      if (rangesOverlap(startDate, endDate, trip.startDate, trip.endDate)) {
        return trip;
      }
    }
    return null;
  }
}
