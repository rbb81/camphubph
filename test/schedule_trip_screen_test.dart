import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_trips.dart';
import 'package:camper/models/trip.dart';
import 'package:camper/screens/schedule_trip_screen.dart';

final _camp = sampleCamps.firstWhere((c) => c.id == 'daraitan');

class _ResultCapture {
  Trip? value;
}

Future<_ResultCapture> _pumpScheduleTripHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<Trip>(
                  MaterialPageRoute(
                    builder: (_) => ScheduleTripScreen(camp: _camp),
                  ),
                );
              },
              child: const Text('Open Schedule Trip'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Schedule Trip'));
  await tester.pumpAndSettle();
  return capture;
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
  late List<Trip> tripsSnapshot;

  setUp(() {
    tripsSnapshot = List.of(sampleTrips);
  });

  tearDown(() {
    sampleTrips
      ..clear()
      ..addAll(tripsSnapshot);
  });

  group('ScheduleTripScreen', () {
    testWidgets('renders the camp context header', (tester) async {
      await _pumpScheduleTripHost(tester);

      expect(find.text(_camp.name), findsOneWidget);
      expect(find.text(_camp.location), findsOneWidget);
    });

    testWidgets('submitting without dates shows a validation error', (
      tester,
    ) async {
      final capture = await _pumpScheduleTripHost(tester);

      await tester.tap(find.byKey(const Key('submitTripButton')));
      await tester.pump();

      expect(
        find.text('Select both check-in and check-out dates.'),
        findsOneWidget,
      );
      expect(capture.value, isNull);
    });

    testWidgets('an overlapping range shows a named conflict error', (
      tester,
    ) async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      final conflictTrip = Trip(
        id: 'trip_test_conflict',
        campId: 'test-camp',
        campName: 'Test Conflict Camp',
        campLocation: 'Test Location',
        startDate: base.add(const Duration(days: 30)),
        endDate: base.add(const Duration(days: 32)),
      );
      sampleTrips.add(conflictTrip);

      final capture = await _pumpScheduleTripHost(tester);

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
      await tester.pump();

      expect(find.textContaining('Test Conflict Camp'), findsOneWidget);
      expect(capture.value, isNull);
    });

    testWidgets('a non-conflicting range pops a Trip and appends it', (
      tester,
    ) async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      final checkIn = base.add(const Duration(days: 100));
      final checkOut = base.add(const Duration(days: 102));

      final capture = await _pumpScheduleTripHost(tester);

      await _pickDate(tester, const Key('checkInField'), checkIn);
      await _pickDate(tester, const Key('checkOutField'), checkOut);

      await tester.tap(find.byKey(const Key('submitTripButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.campId, _camp.id);
      expect(capture.value!.campName, _camp.name);
      expect(capture.value!.startDate, checkIn);
      expect(capture.value!.endDate, checkOut);
      expect(sampleTrips, contains(capture.value));
    });
  });
}
