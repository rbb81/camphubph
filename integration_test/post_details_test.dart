import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/home_feed_item.dart';
import 'package:camper/screens/post_details_screen.dart';

const _post = FriendPostItem(
  id: 'post_test',
  authorName: 'Jasmine Reyes',
  authorInitials: 'JR',
  timeAgo: '2h',
  location: 'Batangas Ridge',
  caption: 'Made it to the summit just in time for sunrise.',
  likeCount: 24,
  commentCount: 0,
);

Future<void> pumpPostDetailsScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PostDetailsScreen(post: _post, currentUser: sampleProfile),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Post Details (real browser)', () {
    testWidgets('liking bumps the like count', (tester) async {
      await pumpPostDetailsScreen(tester);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('submitting a comment appends it to the thread', (
      tester,
    ) async {
      await pumpPostDetailsScreen(tester);

      await tester.enterText(
        find.byKey(const Key('commentField')),
        'Nice one!',
      );
      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pumpAndSettle();

      expect(find.text('Nice one!'), findsOneWidget);
    });
  });
}
