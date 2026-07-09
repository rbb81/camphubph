import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_other_users.dart';
import 'package:camper/models/followable_user.dart';
import 'package:camper/screens/communities_screen.dart';
import 'package:camper/screens/discover_screen.dart';
import 'package:camper/screens/home_screen.dart';

Future<void> pumpHomeScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      routes: {
        '/discover': (context) => const DiscoverScreen(),
        '/communities': (context) => const CommunitiesScreen(),
      },
    ),
  );
}

void main() {
  late List<FollowableUser> otherUsersSnapshot;

  setUp(() {
    otherUsersSnapshot = List.of(sampleOtherUsers);
  });

  tearDown(() {
    sampleOtherUsers
      ..clear()
      ..addAll(otherUsersSnapshot);
  });

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

      await tester.tap(find.text('Map'));
      await tester.pump();

      expect(find.text('Map is coming soon.'), findsOneWidget);
    });

    testWidgets('tapping Discover navigates to the Discover screen', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();

      expect(find.text('Mountains'), findsOneWidget);
    });

    testWidgets('tapping Communities navigates to the Communities screen', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Communities'));
      await tester.pumpAndSettle();

      expect(find.text('Suggested communities'), findsOneWidget);
    });

    testWidgets('tapping a community post card opens its Community Feed', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('communityPostCard')).first);
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
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

    testWidgets('tapping a friend post author opens their profile', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('friendPostAuthorTap')).first);
      await tester.pumpAndSettle();

      expect(find.text('Jasmine Reyes'), findsWidgets);
      expect(find.byKey(const Key('followButton')), findsOneWidget);
      expect(find.byKey(const Key('messageUserButton')), findsOneWidget);
    });

    testWidgets('tapping a suggested user opens their profile', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('suggestedUserTap')),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.byKey(const Key('suggestedUserTap')));
      await tester.pumpAndSettle();

      expect(find.text('Ate Baby'), findsWidgets);
    });

    testWidgets(
      'requesting to follow a suggested user shows Requested, then Following after approval',
      (tester) async {
        await pumpHomeScreen(tester);

        await tester.scrollUntilVisible(
          find.byKey(const Key('suggestedUserFollowButton')),
          200,
          scrollable: find.byType(Scrollable),
        );

        final followButton = find.byKey(
          const Key('suggestedUserFollowButton'),
        );
        expect(
          find.descendant(of: followButton, matching: find.text('Follow')),
          findsOneWidget,
        );

        await tester.tap(followButton);
        await tester.pump();

        expect(
          find.descendant(
            of: followButton,
            matching: find.text('Requested'),
          ),
          findsOneWidget,
        );
        expect(
          find.text('Follow request sent to Ate Baby'),
          findsOneWidget,
        );

        // The auto-approval snackbar queues behind the still-showing
        // "request sent" one, so assert on the button state instead of the
        // second snackbar's text — same convention as communities_screen_test.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        expect(
          find.descendant(
            of: followButton,
            matching: find.text('Following'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
