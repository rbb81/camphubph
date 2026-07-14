import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/screens/map_screen.dart';

Future<void> pumpMapScreen(WidgetTester tester, {String? focusCampId}) async {
  await tester.pumpWidget(
    MaterialApp(home: MapScreen(focusCampId: focusCampId)),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('MapScreen', () {
    testWidgets('renders one marker per sample camp', (tester) async {
      await pumpMapScreen(tester);

      for (final camp in sampleCamps) {
        expect(find.byKey(Key('mapMarker_${camp.id}')), findsOneWidget);
      }
    });

    testWidgets('tapping a marker opens a bottom sheet with camp details', (
      tester,
    ) async {
      await pumpMapScreen(tester);
      final camp = sampleCamps.first;

      // flutter_map positions markers via a paint-time transform, so the
      // widget tree's geometric center (used by tester.tap) doesn't line up
      // with where the marker is actually painted. Invoke the marker's
      // onTap callback directly instead, sidestepping geometry entirely.
      final gestureDetector = tester.widget<GestureDetector>(
        find.byKey(Key('mapMarker_${camp.id}')),
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      expect(find.text(camp.name), findsOneWidget);
      expect(find.text(camp.location), findsOneWidget);
      expect(find.byKey(const Key('viewCampDetailsButton')), findsOneWidget);
    });

    testWidgets('tapping View Details navigates to Camp Details', (
      tester,
    ) async {
      await pumpMapScreen(tester);
      final camp = sampleCamps.first;

      final gestureDetector = tester.widget<GestureDetector>(
        find.byKey(Key('mapMarker_${camp.id}')),
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('viewCampDetailsButton')));
      await tester.pumpAndSettle();

      expect(find.text(camp.location), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('opening with a focusCampId does not throw', (tester) async {
      final camp = sampleCamps.first;
      await pumpMapScreen(tester, focusCampId: camp.id);

      expect(find.byKey(Key('mapMarker_${camp.id}')), findsOneWidget);
    });
  });
}
