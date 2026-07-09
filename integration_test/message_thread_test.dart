import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/screens/message_thread_screen.dart';

// Normally reached via Camp Details' "Message Campsite" button (camper
// view) or the Camp Owner Dashboard's Messages section (owner view). See
// integration_test/camp_details_test.dart and camp_owner_dashboard_test.dart
// for those. Pumped directly here so this screen also gets its own
// real-browser chromedriver smoke test, matching the pattern in
// integration_test/home_test.dart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Message Thread (real browser)', () {
    late List<MessageThread> threadsSnapshot;

    setUp(() {
      threadsSnapshot = List.of(sampleMessageThreads);
    });

    tearDown(() {
      sampleMessageThreads
        ..clear()
        ..addAll(threadsSnapshot);
    });

    testWidgets('as camper, renders the seeded conversation', (tester) async {
      final thread = sampleMessageThreads.firstWhere(
        (t) => t.id == 'thread_seed_1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MessageThreadScreen(thread: thread, viewerName: 'Ana Dela Cruz'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(
        find.textContaining('Is the river crossing open'),
        findsOneWidget,
      );
    });

    testWidgets('sending a message appends it to the conversation', (
      tester,
    ) async {
      const thread = MessageThread(
        id: 'thread_integration_test',
        participantA: 'Integration Guest',
        participantB: 'Mt. Daraitan campsite',
        campId: 'daraitan',
        messages: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MessageThreadScreen(
            thread: thread,
            viewerName: 'Integration Guest',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No messages yet. Say hello!'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('messageComposerField')),
        'Do you have parking on-site?',
      );
      await tester.tap(find.byKey(const Key('sendMessageButton')));
      await tester.pumpAndSettle();

      expect(find.text('Do you have parking on-site?'), findsOneWidget);
    });
  });
}
