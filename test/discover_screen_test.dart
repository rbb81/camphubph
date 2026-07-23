import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/camp.dart';
import 'package:camper/screens/discover_screen.dart';

Future<void> pumpDiscoverScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
}

void main() {
  group('DiscoverScreen', () {
    testWidgets('renders every category tile', (tester) async {
      await pumpDiscoverScreen(tester);

      for (final category in kDiscoverCategories) {
        expect(find.text(category.label), findsOneWidget);
      }
    });

    testWidgets('tapping search opens the Search screen', (tester) async {
      await pumpDiscoverScreen(tester);

      await tester.tap(find.byKey(const Key('discoverSearchButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('searchQueryField')), findsOneWidget);
    });

    testWidgets('tapping a category navigates to its results list', (
      tester,
    ) async {
      await pumpDiscoverScreen(tester);

      await tester.tap(find.byKey(const Key('categoryTile_Mountains')));
      await tester.pumpAndSettle();

      expect(find.text('Mountains'), findsOneWidget);
      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
    });
  });
}
