import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_community_join_requests.dart';
import 'package:camper/data/sample_community_members.dart';
import 'package:camper/models/community.dart';
import 'package:camper/models/community_join_request.dart';
import 'package:camper/models/community_member.dart';
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

const _private = Community(
  id: 'palawan-dreamers',
  name: 'Palawan Dreamers',
  description: "Planning trips to Palawan's islands and campsites.",
  icon: Icons.terrain,
  memberCount: 3021,
  isPrivate: true,
);

// Reuses the real seeded id so `_members`/pending requests resolve to the
// actual roster (Ana Dela Cruz as moderator), same trick as `_joined`.
const _moderated = Community(
  id: 'bicol-volcano-trekkers',
  name: 'Bicol Volcano Trekkers',
  description: 'Mayon and Bulusan trail conditions, permits, and meetups.',
  icon: Icons.terrain,
  memberCount: 87,
  isPrivate: true,
  isJoined: true,
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
  late List<CommunityMember> membersSnapshot;
  late List<CommunityJoinRequest> requestsSnapshot;

  setUp(() {
    membersSnapshot = List.of(sampleCommunityMembers);
    requestsSnapshot = List.of(sampleCommunityJoinRequests);
  });

  tearDown(() {
    sampleCommunityMembers
      ..clear()
      ..addAll(membersSnapshot);
    sampleCommunityJoinRequests
      ..clear()
      ..addAll(requestsSnapshot);
  });

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

    testWidgets(
      'the pending-requests entry point is absent for a non-moderator',
      (tester) async {
        await pumpCommunityFeedScreen(tester);

        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('pendingJoinRequestsTile')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'the pending-requests entry point shows the count for a moderator',
      (tester) async {
        await pumpCommunityFeedScreen(tester, community: _moderated);

        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('pendingJoinRequestsTile')), findsOneWidget);
        expect(find.text('Pending join requests'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets(
      'approving a pending request from Members updates the roster on return',
      (tester) async {
        await pumpCommunityFeedScreen(tester, community: _moderated);

        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('pendingJoinRequestsTile')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('approveJoinRequestButton_jr1')),
        );
        await tester.pump();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Carlo D.'), findsOneWidget);
      },
    );

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

    testWidgets(
      'requesting to join a private community shows Requested, then Joined after approval',
      (tester) async {
        await pumpCommunityFeedScreen(tester, community: _private);

        final joinButton = find.byKey(const Key('feedJoinButton'));
        expect(
          find.descendant(
            of: joinButton,
            matching: find.text('Request to Join'),
          ),
          findsOneWidget,
        );

        await tester.tap(joinButton);
        await tester.pump();

        expect(
          find.descendant(of: joinButton, matching: find.text('Requested')),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        expect(
          find.descendant(of: joinButton, matching: find.text('Joined')),
          findsOneWidget,
        );
      },
    );
  });
}
