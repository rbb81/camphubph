import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_other_users.dart';
import 'package:camper/models/followable_user.dart';
import 'package:camper/screens/follow_list_screen.dart';
import 'package:camper/screens/other_user_profile_screen.dart';

Future<void> _pumpFollowList(WidgetTester tester, FollowListType type) async {
  await tester.pumpWidget(MaterialApp(home: FollowListScreen(type: type)));
}

void main() {
  late List<FollowableUser> otherUsersSnapshot;

  setUp(() {
    otherUsersSnapshot = List.of(sampleOtherUsers);
  });

  tearDown(() {
    sampleOtherUsers
      ..clear()
      ..addAll(otherUsersSnapshot);
  });

  group('FollowListScreen', () {
    testWidgets('Followers shows only followsMe users', (tester) async {
      await _pumpFollowList(tester, FollowListType.followers);

      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(find.text('Ate Baby'), findsOneWidget);
      expect(find.text('Rico P.'), findsOneWidget);
      expect(find.text('Miguel Ibarra'), findsNothing);
      expect(find.text('Carlo D.'), findsNothing);
    });

    testWidgets('Following shows the empty state when no one is followed', (
      tester,
    ) async {
      await _pumpFollowList(tester, FollowListType.following);

      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Not following anyone yet.'), findsOneWidget);
    });

    testWidgets('tapping a row opens that person\'s Other User Profile', (
      tester,
    ) async {
      await _pumpFollowList(tester, FollowListType.followers);

      await tester.tap(find.text('Jasmine Reyes'));
      await tester.pumpAndSettle();

      expect(find.byType(OtherUserProfileScreen), findsOneWidget);
      expect(find.byKey(const Key('followButton')), findsOneWidget);
    });

    testWidgets(
      'Follow Back on a follower cycles to Requested then auto-approves to Following',
      (tester) async {
        await _pumpFollowList(tester, FollowListType.followers);

        final followButton = find.byKey(
          const Key('followButton_Jasmine Reyes'),
        );
        expect(
          find.descendant(of: followButton, matching: find.text('Follow Back')),
          findsOneWidget,
        );

        await tester.tap(followButton);
        await tester.pump();

        expect(
          find.descendant(of: followButton, matching: find.text('Requested')),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        expect(
          find.descendant(of: followButton, matching: find.text('Following')),
          findsOneWidget,
        );
        // Still listed under Followers — following them doesn't affect followsMe.
        expect(find.text('Jasmine Reyes'), findsOneWidget);
        expect(
          sampleOtherUsers
              .firstWhere((u) => u.profile.name == 'Jasmine Reyes')
              .followStatus,
          FollowStatus.following,
        );
      },
    );

    testWidgets('tapping Following unfollows immediately and removes them', (
      tester,
    ) async {
      // Follow Jasmine first via the Followers list, then reopen as Following.
      await _pumpFollowList(tester, FollowListType.followers);
      await tester.tap(find.byKey(const Key('followButton_Jasmine Reyes')));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      await _pumpFollowList(tester, FollowListType.following);
      expect(find.text('Jasmine Reyes'), findsOneWidget);

      await tester.tap(find.byKey(const Key('followButton_Jasmine Reyes')));
      await tester.pump();

      expect(find.text('Jasmine Reyes'), findsNothing);
      expect(find.text('Not following anyone yet.'), findsOneWidget);
      expect(
        sampleOtherUsers
            .firstWhere((u) => u.profile.name == 'Jasmine Reyes')
            .followStatus,
        FollowStatus.notFollowing,
      );
    });
  });
}
