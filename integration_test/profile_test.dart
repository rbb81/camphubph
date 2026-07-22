import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/screens/profile_screen.dart';

// Profile is normally reached via Home's bottom nav, which itself requires a
// login. Pumped directly here (like integration_test/home_test.dart) so this
// still exercises the screen in a real browser via chromedriver.
Future<void> pumpProfileScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile (real browser)', () {
    testWidgets('renders the identity block and tabs', (tester) async {
      await pumpProfileScreen(tester);

      expect(find.text(sampleProfile.name), findsOneWidget);
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
    });

    testWidgets('settings shows a coming-soon message', (tester) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(const Key('settingsButton')));
      await tester.pumpAndSettle();

      expect(find.text('Settings is coming soon.'), findsOneWidget);
    });

    testWidgets('switching tabs shows the matching sample content', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.ensureVisible(find.text('Wishlist'));
      await tester.tap(find.text('Wishlist'));
      await tester.pumpAndSettle();

      expect(find.text(sampleWishlist.first.name), findsOneWidget);
    });

    testWidgets('tapping Edit Profile navigates to the edit screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(const Key('editProfileButton')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('tapping a post opens the post detail screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.text(sampleProfilePosts.first.caption));
      await tester.pumpAndSettle();

      expect(find.text('Post'), findsOneWidget);
      expect(find.text(sampleProfilePosts.first.caption), findsOneWidget);
    });

    testWidgets('tapping a saved camp opens Camp Details', (tester) async {
      await pumpProfileScreen(tester);

      await tester.ensureVisible(find.text('Saved Camps'));
      await tester.tap(find.text('Saved Camps'));
      await tester.pumpAndSettle();

      // Invoke the ListTile's onTap directly rather than a geometric tap —
      // multi-tab jumps through this screen's pinned TabBar can leave the
      // tapped item's hit-test position unreliable (same fallback used in
      // test/profile_screen_test.dart).
      tester
          .widget<ListTile>(
            find.widgetWithText(ListTile, sampleSavedCamps.first.name),
          )
          .onTap!();
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets(
      'tapping a completed trip opens the trip detail screen and View Camp navigates to a fallback Camp Details',
      (tester) async {
        await pumpProfileScreen(tester);

        await tester.ensureVisible(find.text('Completed Trips'));
        await tester.tap(find.text('Completed Trips'));
        await tester.pumpAndSettle();

        tester
            .widget<ListTile>(
              find.widgetWithText(ListTile, sampleCompletedTrips.first.name),
            )
            .onTap!();
        await tester.pumpAndSettle();

        expect(find.text('Trip'), findsOneWidget);
        expect(find.byKey(const Key('viewCampButton')), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);

        await tester.tap(find.byKey(const Key('viewCampButton')));
        await tester.pumpAndSettle();

        expect(find.text('Overview'), findsOneWidget);
        expect(
          find.text('No description available yet for this camp.'),
          findsOneWidget,
        );
      },
    );
  });
}
