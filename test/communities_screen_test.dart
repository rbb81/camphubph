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

    testWidgets('shows a private badge on a private community', (
      tester,
    ) async {
      await pumpCommunitiesScreen(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('communityCard_palawan-dreamers')),
          matching: find.byKey(const Key('privateIcon_palawan-dreamers')),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('privateIcon_luzon-overlanders')),
        findsNothing,
      );
    });

    testWidgets('creating a community adds it to Your communities', (
      tester,
    ) async {
      await pumpCommunitiesScreen(tester);

      await tester.tap(find.byKey(const Key('createCommunityButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('communityNameField')),
        'Sierra Madre Hikers',
      );
      await tester.enterText(
        find.byKey(const Key('communityDescriptionField')),
        'Trail conditions and meetups around the Sierra Madre range.',
      );
      await tester.tap(find.byKey(const Key('createCommunitySubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Sierra Madre Hikers'), findsOneWidget);
      expect(find.text('1 members'), findsOneWidget);

      final createdY = tester.getTopLeft(find.text('Sierra Madre Hikers')).dy;
      final suggestedHeaderY = tester
          .getTopLeft(find.text('Suggested communities'))
          .dy;
      expect(createdY, lessThan(suggestedHeaderY));
    });
  });
}
