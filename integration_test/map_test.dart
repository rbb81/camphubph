import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/screens/map_screen.dart';

Future<void> pumpMapScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: MapScreen()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Map (real browser)', () {
    testWidgets('renders the app bar and a pin for every sample camp', (
      tester,
    ) async {
      await pumpMapScreen(tester);

      expect(find.widgetWithText(AppBar, 'Map'), findsOneWidget);
      for (final camp in sampleCamps) {
        expect(find.byKey(Key('mapMarker_${camp.id}')), findsOneWidget);
      }
    });

    testWidgets('tapping a marker shows a preview sheet with the camp name', (
      tester,
    ) async {
      await pumpMapScreen(tester);
      final camp = sampleCamps.first;

      final gestureDetector = tester.widget<GestureDetector>(
        find.byKey(Key('mapMarker_${camp.id}')),
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      expect(find.text(camp.name), findsOneWidget);
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

      expect(find.text('Overview'), findsOneWidget);
    });
  });
}
