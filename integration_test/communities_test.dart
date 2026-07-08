import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/communities_screen.dart';

Future<void> pumpCommunitiesScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: CommunitiesScreen()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Communities (real browser)', () {
    testWidgets('renders your communities and suggested sections', (
      tester,
    ) async {
      await pumpCommunitiesScreen(tester);

      expect(find.text('Your communities'), findsOneWidget);
      expect(find.text('Suggested communities'), findsOneWidget);
      expect(find.text('Luzon Overlanders'), findsOneWidget);
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

      expect(find.text('Feed'), findsOneWidget);
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
    });

    testWidgets(
      'requesting to join a private community shows Requested, then Joined after approval',
      (tester) async {
        await pumpCommunitiesScreen(tester);

        final joinButton = find.byKey(
          const Key('joinButton_palawan-dreamers'),
        );
        expect(
          find.descendant(
            of: joinButton,
            matching: find.text('Request to Join'),
          ),
          findsOneWidget,
        );

        await tester.tap(joinButton);
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: joinButton, matching: find.text('Requested')),
          findsOneWidget,
        );

        // The approval is simulated on a real 2-second delay (this test runs
        // in a real browser, not a fake-clock harness), so wait it out.
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: joinButton, matching: find.text('Joined')),
          findsOneWidget,
        );
      },
    );
  });
}
