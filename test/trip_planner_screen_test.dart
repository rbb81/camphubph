import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_trips.dart';
import 'package:camper/models/trip.dart';
import 'package:camper/screens/trip_planner_screen.dart';

Future<void> pumpTripPlannerScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: TripPlannerScreen()));
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

  group('TripPlannerScreen', () {
    testWidgets('renders seeded trips grouped under Upcoming and Past', (
      tester,
    ) async {
      await pumpTripPlannerScreen(tester);

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(find.text('Taal Lake shoreline'), findsOneWidget);
    });

    testWidgets('sorts trips within a group ascending by start date', (
      tester,
    ) async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      sampleTrips
        ..clear()
        ..addAll([
          Trip(
            id: 'later',
            campId: 'b',
            campName: 'Later Camp',
            campLocation: 'Somewhere',
            startDate: base.add(const Duration(days: 20)),
            endDate: base.add(const Duration(days: 22)),
          ),
          Trip(
            id: 'sooner',
            campId: 'a',
            campName: 'Sooner Camp',
            campLocation: 'Somewhere',
            startDate: base.add(const Duration(days: 5)),
            endDate: base.add(const Duration(days: 7)),
          ),
        ]);

      await pumpTripPlannerScreen(tester);

      final sooner = tester.getTopLeft(find.text('Sooner Camp'));
      final later = tester.getTopLeft(find.text('Later Camp'));
      expect(sooner.dy, lessThan(later.dy));
    });

    testWidgets('tapping a trip card shows a coming-soon snackbar', (
      tester,
    ) async {
      await pumpTripPlannerScreen(tester);

      await tester.tap(find.byKey(const Key('tripCard_trip_seed_upcoming')));
      await tester.pump();

      expect(find.text('Trip details is coming soon.'), findsOneWidget);
    });

    testWidgets('shows an empty state with no scheduled trips', (
      tester,
    ) async {
      sampleTrips.clear();

      await pumpTripPlannerScreen(tester);

      expect(find.text('No trips scheduled yet.'), findsOneWidget);
      expect(find.byKey(const Key('findCampButton')), findsOneWidget);
    });
  });
}
