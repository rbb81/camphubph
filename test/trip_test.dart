import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/trip.dart';

Trip _trip(String id, DateTime start, DateTime end) => Trip(
  id: id,
  campId: 'camp_$id',
  campName: 'Camp $id',
  campLocation: 'Somewhere',
  startDate: start,
  endDate: end,
);

void main() {
  group('Trip.rangesOverlap', () {
    test('identical ranges conflict', () {
      final a = DateTime(2026, 8, 1);
      final b = DateTime(2026, 8, 3);
      expect(Trip.rangesOverlap(a, b, a, b), isTrue);
    });

    test('disjoint ranges do not conflict', () {
      expect(
        Trip.rangesOverlap(
          DateTime(2026, 8, 1),
          DateTime(2026, 8, 3),
          DateTime(2026, 8, 10),
          DateTime(2026, 8, 12),
        ),
        isFalse,
      );
    });

    test('back-to-back ranges (checkout == other check-in) do not conflict', () {
      expect(
        Trip.rangesOverlap(
          DateTime(2026, 8, 1),
          DateTime(2026, 8, 3),
          DateTime(2026, 8, 3),
          DateTime(2026, 8, 5),
        ),
        isFalse,
      );
    });

    test('overlapping ranges sharing a night conflict', () {
      expect(
        Trip.rangesOverlap(
          DateTime(2026, 8, 1),
          DateTime(2026, 8, 3),
          DateTime(2026, 8, 2),
          DateTime(2026, 8, 5),
        ),
        isTrue,
      );
    });
  });

  group('Trip.findConflict', () {
    test('returns null when no trips overlap', () {
      final trips = [
        _trip('a', DateTime(2026, 8, 1), DateTime(2026, 8, 3)),
        _trip('b', DateTime(2026, 8, 10), DateTime(2026, 8, 12)),
      ];
      final conflict = Trip.findConflict(
        trips,
        startDate: DateTime(2026, 8, 5),
        endDate: DateTime(2026, 8, 7),
      );
      expect(conflict, isNull);
    });

    test('returns the matching trip when one overlaps', () {
      final trips = [
        _trip('a', DateTime(2026, 8, 1), DateTime(2026, 8, 3)),
        _trip('b', DateTime(2026, 8, 10), DateTime(2026, 8, 12)),
      ];
      final conflict = Trip.findConflict(
        trips,
        startDate: DateTime(2026, 8, 11),
        endDate: DateTime(2026, 8, 14),
      );
      expect(conflict?.id, 'b');
    });
  });
}
