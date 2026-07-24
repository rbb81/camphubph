import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_communities.dart';
import 'package:camper/data/sample_community_join_requests.dart';
import 'package:camper/data/sample_community_members.dart';
import 'package:camper/models/community_join_request.dart';
import 'package:camper/models/community_member.dart';
import 'package:camper/screens/pending_join_requests_screen.dart';

final _community = sampleCommunities.firstWhere(
  (c) => c.id == 'bicol-volcano-trekkers',
);

// Normally reached via Community Feed's Members tab (see
// integration_test/community_feed_test.dart). Pumped directly here so this
// screen also gets its own real-browser chromedriver smoke test, matching
// the pattern in integration_test/notifications_test.dart.
Future<void> pumpPendingJoinRequestsScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: PendingJoinRequestsScreen(community: _community)),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pending Join Requests (real browser)', () {
    late List<CommunityMember> membersSnapshot;
    late List<CommunityJoinRequest> requestsSnapshot;

    setUp(() {
      membersSnapshot = List.of(sampleCommunityMembers);
      requestsSnapshot = List.of(sampleCommunityJoinRequests);
    });

    tearDown(() {
      sampleCommunityMembers
        ..clear()
        ..addAll(membersSnapshot);
      sampleCommunityJoinRequests
        ..clear()
        ..addAll(requestsSnapshot);
    });

    testWidgets('renders the seeded pending requests', (tester) async {
      await pumpPendingJoinRequestsScreen(tester);

      expect(find.text('Carlo D.'), findsOneWidget);
      expect(find.text('Ate Baby'), findsOneWidget);
    });

    testWidgets('approving adds a member and removes the request', (
      tester,
    ) async {
      await pumpPendingJoinRequestsScreen(tester);

      await tester.tap(find.byKey(const Key('approveJoinRequestButton_jr1')));
      await tester.pumpAndSettle();

      expect(find.text('Carlo D.'), findsNothing);
      expect(
        sampleCommunityMembers.any(
          (m) =>
              m.communityId == 'bicol-volcano-trekkers' &&
              m.name == 'Carlo D.',
        ),
        isTrue,
      );
    });

    testWidgets('declining removes the request without adding a member', (
      tester,
    ) async {
      await pumpPendingJoinRequestsScreen(tester);

      await tester.tap(find.byKey(const Key('declineJoinRequestButton_jr2')));
      await tester.pumpAndSettle();

      expect(find.text('Ate Baby'), findsNothing);
      expect(
        sampleCommunityMembers.any((m) => m.name == 'Ate Baby'),
        isFalse,
      );
    });
  });
}
