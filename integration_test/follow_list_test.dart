import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_other_users.dart';
import 'package:camper/models/followable_user.dart';
import 'package:camper/screens/follow_list_screen.dart';
import 'package:camper/screens/other_user_profile_screen.dart';

// Normally reached via Profile's follower/following stat taps (see
// integration_test/profile_test.dart). Pumped directly here so this screen
// also gets its own real-browser chromedriver smoke test, matching the
// pattern in integration_test/notifications_test.dart.
Future<void> _pumpFollowList(WidgetTester tester, FollowListType type) async {
  await tester.pumpWidget(MaterialApp(home: FollowListScreen(type: type)));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FollowListScreen (real browser)', () {
    late List<FollowableUser> otherUsersSnapshot;

    setUp(() {
      otherUsersSnapshot = List.of(sampleOtherUsers);
    });

    tearDown(() {
      sampleOtherUsers
        ..clear()
        ..addAll(otherUsersSnapshot);
    });

    testWidgets('Followers shows only followsMe users', (tester) async {
      await _pumpFollowList(tester, FollowListType.followers);

      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(find.text('Miguel Ibarra'), findsNothing);
    });

    testWidgets('Following shows the empty state when no one is followed', (
      tester,
    ) async {
      await _pumpFollowList(tester, FollowListType.following);

      expect(find.text('Not following anyone yet.'), findsOneWidget);
    });

    testWidgets("tapping a row opens that person's Other User Profile", (
      tester,
    ) async {
      await _pumpFollowList(tester, FollowListType.followers);

      await tester.tap(find.text('Jasmine Reyes'));
      await tester.pumpAndSettle();

      expect(find.byType(OtherUserProfileScreen), findsOneWidget);
    });

    testWidgets(
      'Follow Back cycles to Requested then auto-approves to Following',
      (tester) async {
        await _pumpFollowList(tester, FollowListType.followers);

        await tester.tap(find.byKey(const Key('followButton_Jasmine Reyes')));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('followButton_Jasmine Reyes')),
            matching: find.text('Requested'),
          ),
          findsOneWidget,
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('followButton_Jasmine Reyes')),
            matching: find.text('Following'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
