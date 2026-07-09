import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_trips.dart';
import 'package:camper/models/trip.dart';
import 'package:camper/screens/schedule_trip_screen.dart';

final _camp = sampleCamps.firstWhere((c) => c.id == 'daraitan');

Future<void> pumpScheduleTripScreen(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: ScheduleTripScreen(camp: _camp)));
  await tester.pumpAndSettle();
}

String _fmt(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

Future<void> _pickDate(WidgetTester tester, Key fieldKey, DateTime date) async {
  await tester.tap(find.byKey(fieldKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), _fmt(date));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Schedule Trip (real browser)', () {
    late List<Trip> tripsSnapshot;

    setUp(() {
      tripsSnapshot = List.of(sampleTrips);
    });

    tearDown(() {
      sampleTrips
        ..clear()
        ..addAll(tripsSnapshot);
    });

    testWidgets('renders the camp header and validates missing dates', (
      tester,
    ) async {
      await pumpScheduleTripScreen(tester);

      expect(find.text(_camp.name), findsOneWidget);

      await tester.tap(find.byKey(const Key('submitTripButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Select both check-in and check-out dates.'),
        findsOneWidget,
      );
    });

    testWidgets('an overlapping range is blocked with a named conflict', (
      tester,
    ) async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      sampleTrips.add(
        Trip(
          id: 'trip_test_conflict',
          campId: 'test-camp',
          campName: 'Test Conflict Camp',
          campLocation: 'Test Location',
          startDate: base.add(const Duration(days: 30)),
          endDate: base.add(const Duration(days: 32)),
        ),
      );

      await pumpScheduleTripScreen(tester);

      await _pickDate(
        tester,
        const Key('checkInField'),
        base.add(const Duration(days: 31)),
      );
      await _pickDate(
        tester,
        const Key('checkOutField'),
        base.add(const Duration(days: 33)),
      );

      await tester.tap(find.byKey(const Key('submitTripButton')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Conflict Camp'), findsOneWidget);
    });

    testWidgets('a non-conflicting range schedules the trip', (tester) async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);

      await pumpScheduleTripScreen(tester);

      await _pickDate(
        tester,
        const Key('checkInField'),
        base.add(const Duration(days: 100)),
      );
      await _pickDate(
        tester,
        const Key('checkOutField'),
        base.add(const Duration(days: 102)),
      );

      await tester.tap(find.byKey(const Key('submitTripButton')));
      await tester.pumpAndSettle();

      expect(sampleTrips.any((t) => t.campId == _camp.id), isTrue);
    });
  });
}
