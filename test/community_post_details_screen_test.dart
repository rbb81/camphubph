import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/comment.dart';
import 'package:camper/models/community_post.dart';
import 'package:camper/screens/community_post_details_screen.dart';

const _post = CommunityFeedPost(
  id: 'cp_test',
  communityId: 'luzon-overlanders',
  authorName: 'Rico Fernandez',
  authorInitials: 'RF',
  timeAgo: '3d',
  body: 'Reminder: tag your trip reports with route + vehicle type.',
  likeCount: 42,
  commentCount: 1,
  isPinned: true,
  isModerator: true,
  comments: [
    Comment(
      id: 'c1',
      authorName: 'Miguel Ibarra',
      authorInitials: 'MI',
      text: 'Got it, will start tagging mine from now on.',
      timeAgo: '2d',
    ),
  ],
);

class _ResultCapture {
  CommunityFeedPost? value;
}

Future<_ResultCapture> _pumpCommunityPostDetailsHost(
  WidgetTester tester, {
  bool isModerator = false,
}) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context)
                    .push<CommunityFeedPost>(
                      MaterialPageRoute(
                        builder: (_) => CommunityPostDetailsScreen(
                          post: _post,
                          currentUser: sampleProfile,
                          isModerator: isModerator,
                        ),
                      ),
                    );
              },
              child: const Text('Open Post'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Post'));
  await tester.pumpAndSettle();
  return capture;
}

void main() {
  group('CommunityPostDetailsScreen', () {
    testWidgets('renders the full post and existing comments', (
      tester,
    ) async {
      await _pumpCommunityPostDetailsHost(tester);

      expect(find.text('Rico Fernandez'), findsOneWidget);
      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('MOD'), findsOneWidget);
      expect(
        find.text('Reminder: tag your trip reports with route + vehicle type.'),
        findsOneWidget,
      );
      expect(find.text('Miguel Ibarra'), findsOneWidget);
      expect(
        find.text('Got it, will start tagging mine from now on.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping the like button fills the heart and bumps the count', (
      tester,
    ) async {
      await _pumpCommunityPostDetailsHost(tester);

      expect(find.text('42'), findsOneWidget);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pump();

      expect(find.text('43'), findsOneWidget);
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('likeButton')),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.icon, Icons.favorite);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pump();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('submitting a comment appends it and bumps the count', (
      tester,
    ) async {
      await _pumpCommunityPostDetailsHost(tester);

      await tester.enterText(
        find.byKey(const Key('commentField')),
        'Should we add a route-difficulty tag too?',
      );
      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pump();

      expect(
        find.text('Should we add a route-difficulty tag too?'),
        findsOneWidget,
      );
      expect(find.text(sampleProfile.name), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('an empty comment is ignored', (tester) async {
      await _pumpCommunityPostDetailsHost(tester);

      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no comments', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityPostDetailsScreen(
            post: _post.copyWith(comments: [], commentCount: 0),
            currentUser: sampleProfile,
          ),
        ),
      );

      expect(find.text('No comments yet.'), findsOneWidget);
    });

    testWidgets('popping returns the updated post', (tester) async {
      final capture = await _pumpCommunityPostDetailsHost(tester);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.isLiked, isTrue);
      expect(capture.value!.likeCount, 43);
    });

    testWidgets(
      'a non-moderator sees no remove controls on the post or its comments',
      (tester) async {
        await _pumpCommunityPostDetailsHost(tester);

        expect(find.byKey(const Key('removePostButton')), findsNothing);
        expect(
          find.byKey(const Key('removeCommentButton_c1')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a moderator can remove a comment',
      (tester) async {
        await _pumpCommunityPostDetailsHost(tester, isModerator: true);

        expect(
          find.text('Got it, will start tagging mine from now on.'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('removeCommentButton_c1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirmRemoveCommentButton')));
        await tester.pumpAndSettle();

        expect(
          find.text('Got it, will start tagging mine from now on.'),
          findsNothing,
        );
        expect(find.text('No comments yet.'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      },
    );

    testWidgets(
      'a moderator can remove the post, which pops null instead of the post',
      (tester) async {
        final capture = await _pumpCommunityPostDetailsHost(
          tester,
          isModerator: true,
        );

        await tester.tap(find.byKey(const Key('removePostButton')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirmRemovePostButton')));
        await tester.pumpAndSettle();

        expect(capture.value, isNull);
      },
    );
  });
}
