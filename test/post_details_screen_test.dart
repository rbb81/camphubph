import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/comment.dart';
import 'package:camper/models/home_feed_item.dart';
import 'package:camper/screens/post_details_screen.dart';

const _post = FriendPostItem(
  authorName: 'Jasmine Reyes',
  authorInitials: 'JR',
  timeAgo: '2h',
  location: 'Batangas Ridge',
  caption: 'Made it to the summit just in time for sunrise.',
  likeCount: 24,
  commentCount: 1,
  comments: [
    Comment(
      authorName: 'Miguel Ibarra',
      authorInitials: 'MI',
      text: 'Amazing shot!',
      timeAgo: '1h',
    ),
  ],
);

class _ResultCapture {
  FriendPostItem? value;
}

Future<_ResultCapture> _pumpPostDetailsHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<FriendPostItem>(
                  MaterialPageRoute(
                    builder: (_) => PostDetailsScreen(
                      post: _post,
                      currentUser: sampleProfile,
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
  group('PostDetailsScreen', () {
    testWidgets('renders the full post and existing comments', (
      tester,
    ) async {
      await _pumpPostDetailsHost(tester);

      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(
        find.text('Made it to the summit just in time for sunrise.'),
        findsOneWidget,
      );
      expect(find.text('Miguel Ibarra'), findsOneWidget);
      expect(find.text('Amazing shot!'), findsOneWidget);
    });

    testWidgets('tapping the like button fills the heart and bumps the count', (
      tester,
    ) async {
      await _pumpPostDetailsHost(tester);

      expect(find.text('24'), findsOneWidget);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pump();

      expect(find.text('25'), findsOneWidget);
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('likeButton')),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.icon, Icons.favorite);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pump();
      expect(find.text('24'), findsOneWidget);
    });

    testWidgets('submitting a comment appends it and bumps the count', (
      tester,
    ) async {
      await _pumpPostDetailsHost(tester);

      await tester.enterText(
        find.byKey(const Key('commentField')),
        'Congrats on the climb!',
      );
      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pump();

      expect(find.text('Congrats on the climb!'), findsOneWidget);
      expect(find.text(sampleProfile.name), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('an empty comment is ignored', (tester) async {
      await _pumpPostDetailsHost(tester);

      await tester.tap(find.byKey(const Key('sendCommentButton')));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('popping returns the updated post', (tester) async {
      final capture = await _pumpPostDetailsHost(tester);

      await tester.tap(find.byKey(const Key('likeButton')));
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.isLiked, isTrue);
      expect(capture.value!.likeCount, 25);
    });
  });
}
