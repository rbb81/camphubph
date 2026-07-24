import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_communities.dart';
import 'package:camper/data/sample_community_join_requests.dart';
import 'package:camper/data/sample_community_members.dart';
import 'package:camper/models/community.dart';
import 'package:camper/models/community_join_request.dart';
import 'package:camper/models/community_member.dart';
import 'package:camper/screens/pending_join_requests_screen.dart';

final _community = sampleCommunities.firstWhere(
  (c) => c.id == 'bicol-volcano-trekkers',
);

class _ResultCapture {
  Community? value;
}

Future<_ResultCapture> _pumpHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<Community>(
                  MaterialPageRoute(
                    builder: (_) =>
                        PendingJoinRequestsScreen(community: _community),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return capture;
}

void main() {
  late List<CommunityJoinRequest> requestsSnapshot;
  late List<CommunityMember> membersSnapshot;

  setUp(() {
    requestsSnapshot = List.of(sampleCommunityJoinRequests);
    membersSnapshot = List.of(sampleCommunityMembers);
  });

  tearDown(() {
    sampleCommunityJoinRequests
      ..clear()
      ..addAll(requestsSnapshot);
    sampleCommunityMembers
      ..clear()
      ..addAll(membersSnapshot);
  });

  group('PendingJoinRequestsScreen', () {
    testWidgets('renders the seeded pending requests', (tester) async {
      await _pumpHost(tester);

      expect(find.text('Carlo D.'), findsOneWidget);
      expect(find.text('Ate Baby'), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no requests', (
      tester,
    ) async {
      sampleCommunityJoinRequests.clear();
      await _pumpHost(tester);

      expect(find.text('No pending requests.'), findsOneWidget);
    });

    testWidgets(
      'Approve adds a member, bumps the count, and pops the updated community',
      (tester) async {
        final capture = await _pumpHost(tester);
        final startingCount = sampleCommunityMembers
            .where((m) => m.communityId == 'bicol-volcano-trekkers')
            .length;

        await tester.tap(
          find.byKey(const Key('approveJoinRequestButton_jr1')),
        );
        await tester.pump();

        expect(find.text('Carlo D.'), findsNothing);
        expect(
          sampleCommunityMembers
              .where((m) => m.communityId == 'bicol-volcano-trekkers')
              .length,
          startingCount + 1,
        );
        expect(
          sampleCommunityMembers.any(
            (m) =>
                m.communityId == 'bicol-volcano-trekkers' &&
                m.name == 'Carlo D.' &&
                m.role == CommunityRole.member,
          ),
          isTrue,
        );

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(capture.value, isNotNull);
        expect(capture.value!.memberCount, _community.memberCount + 1);
      },
    );

    testWidgets('Decline removes the row and pops null when unchanged', (
      tester,
    ) async {
      final capture = await _pumpHost(tester);

      await tester.tap(find.byKey(const Key('declineJoinRequestButton_jr2')));
      await tester.pump();

      expect(find.text('Ate Baby'), findsNothing);
      expect(
        sampleCommunityJoinRequests.any((r) => r.id == 'jr2'),
        isFalse,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(capture.value, isNull);
    });
  });
}
