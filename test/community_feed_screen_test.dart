import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/community.dart';
import 'package:camper/screens/community_feed_screen.dart';

const _joined = Community(
  id: 'luzon-overlanders',
  name: 'Luzon Overlanders',
  description: 'Off-road and overlanding trips across Luzon.',
  icon: Icons.directions_car,
  memberCount: 1284,
  isJoined: true,
  rules: ['Be respectful.', 'Tag trip reports with the route.'],
);

const _notJoined = Community(
  id: 'batangas-beach-campers',
  name: 'Batangas Beach Campers',
  description: 'Beach camping spots.',
  icon: Icons.beach_access,
  memberCount: 942,
);

Future<void> pumpCommunityFeedScreen(
  WidgetTester tester, {
  Community community = _joined,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(home: CommunityFeedScreen(community: community)),
  );
}

void main() {
  group('CommunityFeedScreen', () {
    testWidgets('shows the pinned post above regular posts', (tester) async {
      await pumpCommunityFeedScreen(tester);

      expect(find.text('Pinned'), findsOneWidget);

      final pinnedCardY = tester
          .getTopLeft(find.byKey(const Key('communityPostCard_cp1')))
          .dy;
      final regularCardY = tester
          .getTopLeft(find.byKey(const Key('communityPostCard_cp2')))
          .dy;
      expect(pinnedCardY, lessThan(regularCardY));
    });

    testWidgets('switching to Rules tab shows the community rules', (
      tester,
    ) async {
      await pumpCommunityFeedScreen(tester);

      await tester.tap(find.text('Rules'));
      await tester.pumpAndSettle();

      expect(find.text('Be respectful.'), findsOneWidget);
    });

    testWidgets('switching to Members tab shows members with role badges', (
      tester,
    ) async {
      await pumpCommunityFeedScreen(tester);

      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      expect(find.text('Rico Fernandez'), findsOneWidget);
      expect(find.text('MOD'), findsWidgets);
    });

    testWidgets('liking a post fills the heart and bumps the count', (
      tester,
    ) async {
      await pumpCommunityFeedScreen(tester);

      final likeButton = find.byKey(const Key('communityLikeButton_cp1'));
      expect(find.text('42'), findsOneWidget);

      await tester.tap(likeButton);
      await tester.pump();

      expect(find.text('43'), findsOneWidget);
    });

    testWidgets('leaving via the app bar button updates the pop result', (
      tester,
    ) async {
      Community? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await Navigator.of(context).push<Community>(
                      MaterialPageRoute(
                        builder: (_) =>
                            const CommunityFeedScreen(community: _joined),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('feedJoinButton')));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isJoined, isFalse);
    });

    testWidgets('composing a post (when joined) adds it to the top of the feed', (
      tester,
    ) async {
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

    testWidgets('composing a post when not joined prompts to join first', (
      tester,
    ) async {
      await pumpCommunityFeedScreen(tester, community: _notJoined);

      await tester.tap(find.byKey(const Key('newPostButton')));
      await tester.pump();

      expect(
        find.text('Join Batangas Beach Campers to post.'),
        findsOneWidget,
      );
    });
  });
}
