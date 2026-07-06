import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_profile.dart';
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

    testWidgets('tapping a post shows a coming-soon message', (tester) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.text(sampleProfilePosts.first.caption));
      await tester.pump();

      expect(find.text('Post details is coming soon.'), findsOneWidget);
    });

    testWidgets('tapping Edit Profile navigates to the edit screen', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(const Key('editProfileButton')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byKey(const Key('nameField')), findsOneWidget);
    });
  });
}
