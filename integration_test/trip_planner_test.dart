import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_trips.dart';
import 'package:camper/models/trip.dart';
import 'package:camper/screens/camp_details_screen.dart';
import 'package:camper/screens/trip_planner_screen.dart';

final _camp = sampleCamps.firstWhere((c) => c.id == 'daraitan');

Future<void> pumpTripPlannerScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: TripPlannerScreen()));
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

  group('Trip Planner (real browser)', () {
    late List<Trip> tripsSnapshot;

    setUp(() {
      tripsSnapshot = List.of(sampleTrips);
    });

    tearDown(() {
      sampleTrips
        ..clear()
        ..addAll(tripsSnapshot);
    });

    testWidgets('renders seeded trips grouped under Upcoming and Past', (
      tester,
    ) async {
      await pumpTripPlannerScreen(tester);

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
    });

    testWidgets(
      'scheduling a trip from Camp Details shows up on a fresh Trip Planner',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: CampDetailsScreen(camp: _camp)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('addToTripButton')));
        await tester.pumpAndSettle();

        final today = DateTime.now();
        final base = DateTime(today.year, today.month, today.day);
        await _pickDate(
          tester,
          const Key('checkInField'),
          base.add(const Duration(days: 300)),
        );
        await _pickDate(
          tester,
          const Key('checkOutField'),
          base.add(const Duration(days: 302)),
        );

        await tester.tap(find.byKey(const Key('submitTripButton')));
        await tester.pumpAndSettle();

        expect(
          find.text('Added ${_camp.name} to your trips.'),
          findsOneWidget,
        );

        expect(sampleTrips.where((t) => t.campId == _camp.id).length, 2);

        await pumpTripPlannerScreen(tester);

        expect(find.text(_camp.name), findsNWidgets(2));
      },
    );

    testWidgets(
      'canceling a trip from its details removes it from the list',
      (tester) async {
        await pumpTripPlannerScreen(tester);

        await tester.tap(find.byKey(const Key('tripCard_trip_seed_upcoming')));
        await tester.pumpAndSettle();

        expect(find.text('Trip Details'), findsOneWidget);

        await tester.tap(find.byKey(const Key('cancelTripDetailsButton')));
        await tester.pumpAndSettle();

        expect(
          find.text('Canceled your trip to Mt. Daraitan campsite.'),
          findsOneWidget,
        );
        expect(sampleTrips.any((t) => t.id == 'trip_seed_upcoming'), isFalse);
      },
    );
  });
}
