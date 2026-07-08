import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/communities_screen.dart';

Future<void> pumpCommunitiesScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: CommunitiesScreen()));
}

void main() {
  group('CommunitiesScreen', () {
    testWidgets('renders your communities and suggested sections', (
      tester,
    ) async {
      await pumpCommunitiesScreen(tester);

      expect(find.text('Your communities'), findsOneWidget);
      expect(find.text('Suggested communities'), findsOneWidget);
      expect(find.text('Luzon Overlanders'), findsOneWidget);
      expect(find.text('Budget Backpackers PH'), findsOneWidget);
    });

    testWidgets('joining a suggested community flips its button to Joined', (
      tester,
    ) async {
      await pumpCommunitiesScreen(tester);

      await tester.tap(
        find.byKey(const Key('joinButton_budget-backpackers-ph')),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('communityCard_budget-backpackers-ph')),
          matching: find.text('Joined'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a community row opens its Community Feed', (
      tester,
    ) async {
      await pumpCommunitiesScreen(tester);

      await tester.tap(
        find.byKey(const Key('communityCard_luzon-overlanders')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Luzon Overlanders'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
    });

    testWidgets('tapping search shows a coming-soon message', (tester) async {
      await pumpCommunitiesScreen(tester);

      await tester.tap(find.byKey(const Key('communitiesSearchButton')));
      await tester.pump();

      expect(find.text('Search is coming soon.'), findsOneWidget);
    });
  });
}
