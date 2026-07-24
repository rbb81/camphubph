import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _pumpProfile(WidgetTester tester, FollowableUser user) async {
  // The Posts/Photos/Reviews tabs use sliver-based lists/grids, which only
  // mount content within the viewport — bump the test surface like
  // camp_details_screen_test.dart does for the same reason.
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(home: OtherUserProfileScreen(user: user)),
  );
}

void main() {
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

  group('OtherUserProfileScreen', () {
    testWidgets('renders identity block from the profile', (tester) async {
      await _pumpProfile(tester, _userNamed('Rico P.'));

      expect(find.text('Rico P.'), findsWidgets);
      expect(
        find.textContaining('Weekend warrior'),
        findsOneWidget,
      );
      expect(find.text('Intermediate camper'), findsOneWidget);
      expect(find.text('Car camping'), findsOneWidget);
    });

    testWidgets(
      'tapping Follow requests, then auto-approves to Following',
      (tester) async {
        await _pumpProfile(tester, _userNamed('Rico P.'));

        final followButton = find.byKey(const Key('followButton'));
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
          find.text('Follow request sent to Rico P.'),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        expect(
          find.descendant(
            of: followButton,
            matching: find.text('Following'),
          ),
          findsOneWidget,
        );
        expect(
          sampleOtherUsers
              .firstWhere((u) => u.profile.name == 'Rico P.')
              .followStatus,
          FollowStatus.following,
        );
      },
    );

    testWidgets('canceling a pending request reverts to Follow', (
      tester,
    ) async {
      await _pumpProfile(tester, _userNamed('Rico P.'));

      final followButton = find.byKey(const Key('followButton'));
      await tester.tap(followButton);
      await tester.pump();
      expect(
        find.descendant(of: followButton, matching: find.text('Requested')),
        findsOneWidget,
      );

      await tester.tap(followButton);
      await tester.pump();

      expect(
        find.descendant(of: followButton, matching: find.text('Follow')),
        findsOneWidget,
      );

      // The canceled request must not be auto-approved by the pending timer.
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.descendant(of: followButton, matching: find.text('Follow')),
        findsOneWidget,
      );
    });

    testWidgets('Message opens a thread with an existing conversation', (
      tester,
    ) async {
      await _pumpProfile(tester, _userNamed('Jasmine Reyes'));

      await tester.tap(find.byKey(const Key('messageUserButton')));
      await tester.pumpAndSettle();

      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(
        find.textContaining('That sunrise shot'),
        findsOneWidget,
      );
    });

    testWidgets('Message starts a new empty thread when none exists yet', (
      tester,
    ) async {
      await _pumpProfile(tester, _userNamed('Carlo D.'));

      await tester.tap(find.byKey(const Key('messageUserButton')));
      await tester.pumpAndSettle();

      expect(find.text('No messages yet. Say hello!'), findsOneWidget);
      expect(
        sampleMessageThreads.any(
          (t) =>
              t.campId == null &&
              (t.participantA == 'Carlo D.' || t.participantB == 'Carlo D.'),
        ),
        isTrue,
      );
    });

    testWidgets(
      'Posts tab shows this user\'s posts and taps through to Post Details',
      (tester) async {
        await _pumpProfile(tester, _userNamed('Miguel Ibarra'));

        expect(
          find.textContaining('Finally tried camping by the lake'),
          findsOneWidget,
        );

        await tester.tap(
          find.textContaining('Finally tried camping by the lake'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Post'), findsOneWidget);
      },
    );

    testWidgets('Posts tab shows an empty state for a user with no posts', (
      tester,
    ) async {
      await _pumpProfile(tester, _userNamed('Rico P.'));

      expect(find.text('No posts yet.'), findsOneWidget);
    });

    testWidgets('Photos tab shows an empty state (no sample photos yet)', (
      tester,
    ) async {
      await _pumpProfile(tester, _userNamed('Miguel Ibarra'));

      await tester.tap(find.text('Photos'));
      await tester.pumpAndSettle();

      expect(find.text('No photos yet.'), findsOneWidget);
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

        await _pumpProfile(tester, _userNamed('Rico P.'));

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
        await _pumpProfile(tester, _userNamed('Rico P.'));

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
