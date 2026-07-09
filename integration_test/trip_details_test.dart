import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

Future<void> pumpTripDetailsScreen(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: TripDetailsScreen(trip: _trip)));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Trip Details (real browser)', () {
    late List<Trip> tripsSnapshot;

    setUp(() {
      tripsSnapshot = List.of(sampleTrips);
    });

    tearDown(() {
      sampleTrips
        ..clear()
        ..addAll(tripsSnapshot);
    });

    testWidgets('renders camp, dates, and length of stay', (tester) async {
      await pumpTripDetailsScreen(tester);

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(find.text('2026-08-01'), findsOneWidget);
      expect(find.text('2026-08-03'), findsOneWidget);
      expect(find.text('2 nights'), findsOneWidget);
    });

    testWidgets('View Camp opens Camp Details for the same camp', (
      tester,
    ) async {
      await pumpTripDetailsScreen(tester);

      await tester.tap(find.byKey(const Key('viewCampButton')));
      await tester.pumpAndSettle();

      expect(find.text('Add to Trip'), findsOneWidget);
    });

    testWidgets('Cancel Trip removes it from sampleTrips', (tester) async {
      sampleTrips.add(_trip);

      await pumpTripDetailsScreen(tester);

      await tester.tap(find.byKey(const Key('cancelTripDetailsButton')));
      await tester.pumpAndSettle();

      expect(sampleTrips.any((t) => t.id == 'trip_test_details'), isFalse);
    });
  });
}
