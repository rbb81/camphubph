import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

Future<void> pumpCommunityPostDetailsScreen(
  WidgetTester tester, {
  bool isModerator = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CommunityPostDetailsScreen(
        post: _post,
        currentUser: sampleProfile,
        isModerator: isModerator,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Community Post Details (real browser)', () {
    testWidgets('liking bumps the like count', (tester) async {
      await pumpCommunityPostDetailsScreen(tester);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pumpAndSettle();

      expect(find.text('43'), findsOneWidget);
    });

    testWidgets('submitting a comment appends it to the thread', (
      tester,
    ) async {
      await pumpCommunityPostDetailsScreen(tester);

      await tester.enterText(
        find.byKey(const Key('commentField')),
        'Nice one!',
      );
      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pumpAndSettle();

      expect(find.text('Nice one!'), findsOneWidget);
    });

    testWidgets('a moderator can remove a comment and then the post', (
      tester,
    ) async {
      await pumpCommunityPostDetailsScreen(tester, isModerator: true);

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

      await tester.tap(find.byKey(const Key('removePostButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmRemovePostButton')));
      await tester.pumpAndSettle();
    });
  });
}
