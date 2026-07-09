import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/data/sample_other_users.dart';
import 'package:camper/models/followable_user.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/screens/other_user_profile_screen.dart';

FollowableUser _userNamed(String name) =>
    sampleOtherUsers.firstWhere((u) => u.profile.name == name);

// Normally reached by tapping a friend-post author or a suggested user on
// Home (see integration_test/home_test.dart). Pumped directly here so this
// screen also gets its own real-browser chromedriver smoke test, matching
// the pattern in integration_test/home_test.dart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Other User Profile (real browser)', () {
    late List<FollowableUser> otherUsersSnapshot;
    late List<MessageThread> threadsSnapshot;

    setUp(() {
      otherUsersSnapshot = List.of(sampleOtherUsers);
      threadsSnapshot = List.of(sampleMessageThreads);
    });

    tearDown(() {
      sampleOtherUsers
        ..clear()
        ..addAll(otherUsersSnapshot);
      sampleMessageThreads
        ..clear()
        ..addAll(threadsSnapshot);
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
  });
}
