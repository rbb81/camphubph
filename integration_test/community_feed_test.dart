import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_communities.dart';
import 'package:camper/models/community.dart';
import 'package:camper/screens/community_feed_screen.dart';

final _joinedCommunity = sampleCommunities.firstWhere(
  (c) => c.id == 'luzon-overlanders',
);

Future<void> pumpCommunityFeedScreen(
  WidgetTester tester, {
  Community? community,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CommunityFeedScreen(community: community ?? _joinedCommunity),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Community Feed (real browser)', () {
    testWidgets('renders the pinned post and tab bar', (tester) async {
      await pumpCommunityFeedScreen(tester);

      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
    });

    testWidgets('switching to Members tab shows moderator badges', (
      tester,
    ) async {
      await pumpCommunityFeedScreen(tester);

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      expect(find.text('Rico Fernandez'), findsOneWidget);
      expect(find.text('MOD'), findsWidgets);
    });

    testWidgets('liking a post bumps the like count', (tester) async {
      await pumpCommunityFeedScreen(tester);

      await tester.tap(find.byKey(const Key('communityLikeButton_cp1')));
      await tester.pumpAndSettle();

      expect(find.text('43'), findsOneWidget);
    });

    testWidgets(
      'tapping the comment icon opens Community Post Details and a new comment updates the count',
      (tester) async {
        await pumpCommunityFeedScreen(tester);

        await tester.tap(
          find.byKey(const Key('communityCommentButton_cp1')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Miguel Ibarra'), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('commentField')),
          'Noted!',
        );
        await tester.tap(find.byKey(const Key('sendCommentButton')));
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('communityPostCard_cp1')),
            matching: find.text('6'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('composing a post adds it to the feed', (tester) async {
      await pumpCommunityFeedScreen(tester);

      await tester.tap(find.byKey(const Key('newPostButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('composePostField')),
        'Fresh trail report from today.',
      );
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle();

      expect(find.text('Fresh trail report from today.'), findsOneWidget);
    });

    testWidgets(
      'requesting to join a private community shows Requested, then Joined after approval',
      (tester) async {
        final privateCommunity = sampleCommunities.firstWhere(
          (c) => c.id == 'palawan-dreamers',
        );
        await pumpCommunityFeedScreen(tester, community: privateCommunity);

        final joinButton = find.byKey(const Key('feedJoinButton'));
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
