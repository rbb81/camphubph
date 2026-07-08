import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/home_feed_item.dart';
import 'package:camper/screens/create_post_screen.dart';

class _ResultCapture {
  FriendPostItem? value;
}

/// Hosts CreatePostScreen behind a button push so the popped result can be
/// captured, mirroring how HomeScreen actually opens it.
Future<_ResultCapture> _pumpCreatePostHost(WidgetTester tester) async {
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
                    builder: (_) => CreatePostScreen(author: sampleProfile),
                  ),
                );
              },
              child: const Text('Open Create Post'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Create Post'));
  await tester.pumpAndSettle();
  return capture;
}

void main() {
  group('CreatePostScreen', () {
    testWidgets('shows a validation error when caption is empty', (
      tester,
    ) async {
      await _pumpCreatePostHost(tester);

      await tester.tap(find.byKey(const Key('publishPostButton')));
      await tester.pump();

      expect(find.text('Write something to post.'), findsOneWidget);
      expect(find.text('Create Post'), findsOneWidget);
    });

    testWidgets('publishing pops with a FriendPostItem from the caption', (
      tester,
    ) async {
      final capture = await _pumpCreatePostHost(tester);

      await tester.enterText(
        find.byKey(const Key('captionField')),
        'Made it to base camp before sunset.',
      );
      await tester.enterText(
        find.byKey(const Key('locationField')),
        'Mt. Pulag',
      );
      await tester.tap(find.byKey(const Key('publishPostButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.caption, 'Made it to base camp before sunset.');
      expect(capture.value!.location, 'Mt. Pulag');
      expect(capture.value!.authorName, sampleProfile.name);
      expect(capture.value!.likeCount, 0);
      expect(capture.value!.commentCount, 0);
    });

    testWidgets('defaults location when left blank', (tester) async {
      final capture = await _pumpCreatePostHost(tester);

      await tester.enterText(
        find.byKey(const Key('captionField')),
        'Quick weekend trip.',
      );
      await tester.tap(find.byKey(const Key('publishPostButton')));
      await tester.pumpAndSettle();

      expect(capture.value!.location, 'Unknown location');
    });

    testWidgets('cancel pops without a result', (tester) async {
      final capture = await _pumpCreatePostHost(tester);

      await tester.tap(find.byKey(const Key('cancelPostButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNull);
    });

    testWidgets('add photo button is present and tappable', (tester) async {
      await _pumpCreatePostHost(tester);

      expect(find.byKey(const Key('addPhotoButton')), findsOneWidget);

      // No image_picker platform implementation is registered in widget
      // tests, so tapping just exercises the picker call without a real
      // gallery — it should complete without crashing.
      await tester.tap(find.byKey(const Key('addPhotoButton')));
      await tester.pumpAndSettle();

      expect(find.text('Create Post'), findsOneWidget);
    });
  });
}
