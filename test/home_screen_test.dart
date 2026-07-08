import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/home_screen.dart';

Future<void> pumpHomeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows the app bar and bottom tab bar', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('Camper'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Communities'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders the mixed feed with sample content', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(find.text('Recommended near you'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Follow'),
        200,
        scrollable: find.byType(Scrollable),
      );

      expect(find.textContaining('Overlanding PH'), findsWidgets);
      expect(find.text('Follow'), findsWidgets);
    });

    testWidgets('tapping a non-Home tab shows a coming-soon message', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Discover'));
      await tester.pump();

      expect(find.text('Discover is coming soon.'), findsOneWidget);
    });

    testWidgets('tapping create post opens the Create Post screen', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('createPostButton')));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);
    });

    testWidgets('publishing a post adds it to the top of the feed', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('createPostButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('captionField')),
        'Fresh air and good company.',
      );
      await tester.tap(find.byKey(const Key('publishPostButton')));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsNothing);
      expect(find.text('Fresh air and good company.'), findsOneWidget);
    });

    testWidgets('tapping search shows a coming-soon message', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('searchButton')));
      await tester.pump();

      expect(find.text('Search is coming soon.'), findsOneWidget);
    });

    testWidgets('liking the first friend post fills the heart and bumps the count', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      final likeButton = find.byKey(const Key('likeButton')).first;
      expect(find.text('24'), findsOneWidget);

      await tester.tap(likeButton);
      await tester.pump();

      expect(find.text('25'), findsOneWidget);
      final icon = tester.widget<Icon>(
        find.descendant(of: likeButton, matching: find.byType(Icon)),
      );
      expect(icon.icon, Icons.favorite);
    });

    testWidgets('tapping a friend post opens Post Details', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('friendPostCard')).first);
      await tester.pumpAndSettle();

      expect(find.text('Post'), findsOneWidget);
      expect(find.text('Jasmine Reyes'), findsOneWidget);
    });

    testWidgets('adding a comment in Post Details updates the feed count', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('friendPostCard')).first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('commentField')),
        'Great trip!',
      );
      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });
  });
}
