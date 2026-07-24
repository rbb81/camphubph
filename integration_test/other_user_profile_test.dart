import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/data/sample_other_users.dart';
import 'package:camper/data/sample_reviews.dart';
import 'package:camper/models/followable_user.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/models/review.dart';
import 'package:camper/screens/other_user_profile_screen.dart';
import 'package:camper/screens/photo_lightbox_screen.dart';

FollowableUser _userNamed(String name) =>
    sampleOtherUsers.firstWhere((u) => u.profile.name == name);

// A real, minimal 1x1 transparent PNG — Image.memory needs decodable bytes.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
  'DwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

// Normally reached by tapping a friend-post author or a suggested user on
// Home (see integration_test/home_test.dart). Pumped directly here so this
// screen also gets its own real-browser chromedriver smoke test, matching
// the pattern in integration_test/home_test.dart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Other User Profile (real browser)', () {
    late List<FollowableUser> otherUsersSnapshot;
    late List<MessageThread> threadsSnapshot;
    late List<Review> reviewsSnapshot;

    setUp(() {
      otherUsersSnapshot = List.of(sampleOtherUsers);
      threadsSnapshot = List.of(sampleMessageThreads);
      reviewsSnapshot = List.of(sampleReviews);
    });

    tearDown(() {
      sampleOtherUsers
        ..clear()
        ..addAll(otherUsersSnapshot);
      sampleMessageThreads
        ..clear()
        ..addAll(threadsSnapshot);
      sampleReviews
        ..clear()
        ..addAll(reviewsSnapshot);
    });

    testWidgets('renders the identity block', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OtherUserProfileScreen(user: _userNamed('Rico P.')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rico P.'), findsWidgets);
      expect(find.text('Intermediate camper'), findsOneWidget);
    });

    testWidgets(
      'requesting to follow flips to Requested then Following',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: OtherUserProfileScreen(user: _userNamed('Rico P.')),
          ),
        );
        await tester.pumpAndSettle();

        final followButton = find.byKey(const Key('followButton'));
        await tester.tap(followButton);
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: followButton, matching: find.text('Requested')),
          findsOneWidget,
        );

        // Real wall-clock time under IntegrationTestWidgetsFlutterBinding,
        // unlike widget tests' fake-clock tester.pump(duration).
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: followButton, matching: find.text('Following')),
          findsOneWidget,
        );
      },
    );

    testWidgets('Message opens a thread and a sent message appears', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OtherUserProfileScreen(user: _userNamed('Carlo D.')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('messageUserButton')));
      await tester.pumpAndSettle();

      expect(find.text('No messages yet. Say hello!'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('messageComposerField')),
        'Welcome to camping!',
      );
      await tester.tap(find.byKey(const Key('sendMessageButton')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to camping!'), findsOneWidget);
    });

    testWidgets(
      'tapping a Photos tab tile opens the fullscreen photo lightbox',
      (tester) async {
        sampleReviews.add(
          Review(
            id: 'r_test_photo',
            campId: 'taal-lake',
            authorName: 'Rico P.',
            authorInitials: 'RP',
            rating: 5,
            visitDate: DateTime(2026, 6, 1),
            postedAgo: '1d',
            photoBytes: _pixel,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: OtherUserProfileScreen(user: _userNamed('Rico P.')),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Photos'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('profilePhotoTile_0')));
        await tester.pumpAndSettle();

        expect(find.byType(PhotoLightboxScreen), findsOneWidget);
        expect(find.text('1 of 1'), findsOneWidget);
      },
    );

    testWidgets(
      'Reviews tab shows this user\'s reviews and taps through to Camp Details',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: OtherUserProfileScreen(user: _userNamed('Rico P.')),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reviews'));
        await tester.pumpAndSettle();

        expect(find.text('Taal Lake shoreline'), findsOneWidget);

        await tester.tap(find.text('Taal Lake shoreline'));
        await tester.pumpAndSettle();

        expect(find.text('Overview'), findsOneWidget);
      },
    );
  });
}
