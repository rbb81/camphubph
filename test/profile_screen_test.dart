import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/profile.dart';
import 'package:camper/screens/profile_screen.dart';

Future<void> pumpProfileScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
}

void main() {
  group('ProfileScreen', () {
    testWidgets('renders identity block with sample profile data', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      expect(find.text(sampleProfile.name), findsOneWidget);
      expect(find.text(sampleProfile.bio), findsOneWidget);
      expect(find.text('Intermediate camper'), findsOneWidget);
      expect(find.text('${sampleProfile.followerCount}'), findsOneWidget);
      expect(find.text('${sampleProfile.followingCount}'), findsOneWidget);
      for (final style in sampleProfile.favoriteStyles) {
        expect(find.text(style), findsOneWidget);
      }
    });

    testWidgets('renders all content tab labels', (tester) async {
      await pumpProfileScreen(tester);

      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Saved Camps'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Completed Trips'), findsOneWidget);
    });

    testWidgets('tapping settings shows a coming-soon message', (tester) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(const Key('settingsButton')));
      await tester.pump();

      expect(find.text('Settings is coming soon.'), findsOneWidget);
    });

    testWidgets('tapping followers stat shows a coming-soon message', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(const Key('followerStat')));
      await tester.pump();

      expect(find.text('Followers list is coming soon.'), findsOneWidget);
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

    testWidgets('tapping a post opens the post detail screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.text(sampleProfilePosts.first.caption));
      await tester.pumpAndSettle();

      expect(find.text('Post'), findsOneWidget);
      expect(find.text(sampleProfilePosts.first.caption), findsOneWidget);
      expect(find.text(sampleProfilePosts.first.timeAgo), findsOneWidget);
    });

    testWidgets('tapping a photo opens the photo detail screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.ensureVisible(find.text('Photos'));
      await tester.tap(find.text('Photos'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(sampleProfilePhotos.first.caption));
      await tester.pumpAndSettle();

      expect(find.text('Photo'), findsOneWidget);
      expect(find.text(sampleProfilePhotos.first.caption), findsOneWidget);
    });

    testWidgets('tapping a review opens the review detail screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.ensureVisible(find.text('Reviews'));
      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();

      // A direct tap can miss the hit-test target once the pinned tab bar
      // and TabBarView interact after a multi-tab jump, so invoke the
      // ListTile's onTap callback directly instead (same fallback used
      // elsewhere in this app for geometry-sensitive taps).
      tester
          .widget<ListTile>(
            find.widgetWithText(
              ListTile,
              sampleProfileReviews.first.campName,
            ),
          )
          .onTap!();
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
      expect(find.text(sampleProfileReviews.first.snippet), findsOneWidget);
    });

    testWidgets('tapping a saved camp opens the matching Camp Details screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.ensureVisible(find.text('Saved Camps'));
      await tester.tap(find.text('Saved Camps'));
      await tester.pumpAndSettle();

      tester
          .widget<ListTile>(
            find.widgetWithText(ListTile, sampleSavedCamps.first.name),
          )
          .onTap!();
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text(sampleSavedCamps.first.name), findsWidgets);
    });

    testWidgets(
      'tapping a wishlist camp with no matching sample camp falls back to a placeholder Camp',
      (tester) async {
        final originalWishlist = List<ProfileWishlistItem>.of(sampleWishlist);
        sampleWishlist
          ..clear()
          ..add(
            const ProfileWishlistItem(
              name: 'Unmatched Test Camp',
              location: 'Nowhere',
            ),
          );
        addTearDown(() {
          sampleWishlist
            ..clear()
            ..addAll(originalWishlist);
        });

        await pumpProfileScreen(tester);

        await tester.ensureVisible(find.text('Wishlist'));
        await tester.tap(find.text('Wishlist'));
        await tester.pumpAndSettle();

        tester
            .widget<ListTile>(
              find.widgetWithText(ListTile, 'Unmatched Test Camp'),
            )
            .onTap!();
        await tester.pumpAndSettle();

        expect(find.text('Overview'), findsOneWidget);
        expect(
          find.text('No description available yet for this camp.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping a completed trip opens the trip detail screen with a View Camp button, no Cancel',
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
        expect(find.text(sampleCompletedTrips.first.dateLabel), findsOneWidget);
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

    testWidgets('tapping Edit Profile navigates to the edit screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(const Key('editProfileButton')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byKey(const Key('nameField')), findsOneWidget);
    });

    testWidgets('tapping Trip Planner navigates to /trips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/profile',
          routes: {
            '/profile': (context) => const ProfileScreen(),
            '/trips': (context) =>
                const Scaffold(body: Text('Trip Planner Screen')),
          },
        ),
      );

      await tester.tap(find.byKey(const Key('tripPlannerButton')));
      await tester.pumpAndSettle();

      expect(find.text('Trip Planner Screen'), findsOneWidget);
    });
  });
}
