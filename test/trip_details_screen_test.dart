import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_trips.dart';
import 'package:camper/models/trip.dart';
import 'package:camper/screens/trip_details_screen.dart';

final _trip = Trip(
  id: 'trip_test_details',
  campId: 'daraitan',
  campName: 'Mt. Daraitan campsite',
  campLocation: 'Tanay, Rizal',
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2026, 8, 3),
);

class _ResultCapture {
  bool? value;
}

Future<_ResultCapture> _pumpTripDetailsHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => TripDetailsScreen(trip: _trip),
                  ),
                );
              },
              child: const Text('Open Trip Details'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Trip Details'));
  await tester.pumpAndSettle();
  return capture;
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

  group('TripDetailsScreen', () {
    testWidgets('renders camp, dates, and length of stay', (tester) async {
      await _pumpTripDetailsHost(tester);

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(find.text('Tanay, Rizal'), findsOneWidget);
      expect(find.text('2026-08-01'), findsOneWidget);
      expect(find.text('2026-08-03'), findsOneWidget);
      expect(find.text('2 nights'), findsOneWidget);
    });

    testWidgets('View Camp opens Camp Details for the same camp', (
      tester,
    ) async {
      await _pumpTripDetailsHost(tester);

      await tester.tap(find.byKey(const Key('viewCampButton')));
      await tester.pumpAndSettle();

      expect(find.text('Add to Trip'), findsOneWidget);
    });

    testWidgets(
      'Cancel Trip removes it from sampleTrips and pops true',
      (tester) async {
        sampleTrips.add(_trip);

        final capture = await _pumpTripDetailsHost(tester);

        await tester.tap(find.byKey(const Key('cancelTripDetailsButton')));
        await tester.pumpAndSettle();

        expect(capture.value, isTrue);
        expect(sampleTrips.any((t) => t.id == 'trip_test_details'), isFalse);
      },
    );
  });
}
