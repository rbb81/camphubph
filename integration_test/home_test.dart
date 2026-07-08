import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/home_screen.dart';

// Home is normally reached after a successful login, which would require a
// pre-seeded, confirmed Supabase test account (see .maestro/home_smoke.yaml
// for that variant). Pumped directly here so this still exercises the
// screen in a real browser via chromedriver, rather than just the
// widget-test binding.
Future<void> pumpHomeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home feed (real browser)', () {
    testWidgets('renders the feed and tab bar', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('Camper'), findsOneWidget);
      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(find.text('Recommended near you'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('search shows a coming-soon message', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('searchButton')));
      await tester.pumpAndSettle();

      expect(find.text('Search is coming soon.'), findsOneWidget);
    });

    testWidgets('create post opens the Create Post screen', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('createPostButton')));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);
    });

    testWidgets('tapping a non-Home tab shows a coming-soon message', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();

      expect(find.text('Discover is coming soon.'), findsOneWidget);
    });

    testWidgets('liking a post fills the heart and bumps the count', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('likeButton')).first);
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('tapping a post opens Post Details', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('friendPostCard')).first);
      await tester.pumpAndSettle();

      expect(find.text('Post'), findsOneWidget);
    });
  });
}
