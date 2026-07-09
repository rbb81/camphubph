import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/screens/message_thread_screen.dart';

Future<void> _pumpThreadScreen(
  WidgetTester tester, {
  required MessageThread thread,
  required String viewerName,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MessageThreadScreen(thread: thread, viewerName: viewerName),
    ),
  );
}

void main() {
  late List<MessageThread> threadsSnapshot;

  setUp(() {
    threadsSnapshot = List.of(sampleMessageThreads);
  });

  tearDown(() {
    sampleMessageThreads
      ..clear()
      ..addAll(threadsSnapshot);
  });

  group('MessageThreadScreen', () {
    testWidgets('as camper, title is the camp name and messages render', (
      tester,
    ) async {
      final thread = sampleMessageThreads.firstWhere(
        (t) => t.id == 'thread_seed_1',
      );

      await _pumpThreadScreen(
        tester,
        thread: thread,
        viewerName: 'Ana Dela Cruz',
      );

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(
        find.textContaining('Is the river crossing open'),
        findsOneWidget,
      );
    });

    testWidgets('as owner, title is the guest name', (tester) async {
      final thread = sampleMessageThreads.firstWhere(
        (t) => t.id == 'thread_seed_1',
      );

      await _pumpThreadScreen(
        tester,
        thread: thread,
        viewerName: 'Mang Rodel',
      );

      expect(find.text('Ana Dela Cruz'), findsOneWidget);
    });

    testWidgets('for a user-to-user thread, title is the other person', (
      tester,
    ) async {
      final thread = sampleMessageThreads.firstWhere(
        (t) => t.id == 'thread_seed_2',
      );

      await _pumpThreadScreen(
        tester,
        thread: thread,
        viewerName: 'Ana Dela Cruz',
      );

      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(
        find.textContaining('That sunrise shot'),
        findsOneWidget,
      );
    });

    testWidgets('an empty thread shows the empty state', (tester) async {
      const thread = MessageThread(
        id: 'thread_empty',
        participantA: 'New Guest',
        participantB: 'Mt. Daraitan campsite',
        campId: 'daraitan',
        messages: [],
      );

      await _pumpThreadScreen(
        tester,
        thread: thread,
        viewerName: 'New Guest',
      );

      expect(find.text('No messages yet. Say hello!'), findsOneWidget);
    });

    testWidgets(
      'sending a message appends it, clears the field, and updates sampleMessageThreads',
      (tester) async {
        const thread = MessageThread(
          id: 'thread_send_test',
          participantA: 'Send Test Guest',
          participantB: 'Mt. Daraitan campsite',
          campId: 'daraitan',
          messages: [],
        );
        sampleMessageThreads.add(thread);

        await _pumpThreadScreen(
          tester,
          thread: thread,
          viewerName: 'Send Test Guest',
        );

        await tester.enterText(
          find.byKey(const Key('messageComposerField')),
          'Do you allow campfires?',
        );
        await tester.tap(find.byKey(const Key('sendMessageButton')));
        await tester.pump();

        expect(find.text('Do you allow campfires?'), findsOneWidget);
        expect(
          find.text('No messages yet. Say hello!'),
          findsNothing,
        );

        final composer = tester.widget<TextField>(
          find.byKey(const Key('messageComposerField')),
        );
        expect(composer.controller?.text, isEmpty);

        final updated = sampleMessageThreads.firstWhere(
          (t) => t.id == 'thread_send_test',
        );
        expect(updated.messages, hasLength(1));
        expect(updated.messages.first.text, 'Do you allow campfires?');
        expect(updated.messages.first.senderName, 'Send Test Guest');
      },
    );
  });
}
