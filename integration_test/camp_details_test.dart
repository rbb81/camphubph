import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/models/camp.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/screens/camp_details_screen.dart';

final _campWithReviews = sampleCamps.firstWhere((c) => c.id == 'daraitan');
final _campWithoutReviews = sampleCamps.firstWhere(
  (c) => c.id == 'batangas-ridge',
);

Future<void> pumpCampDetailsScreen(
  WidgetTester tester, {
  required Camp camp,
}) async {
  await tester.pumpWidget(MaterialApp(home: CampDetailsScreen(camp: camp)));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camp Details (real browser)', () {
    late List<MessageThread> threadsSnapshot;

    setUp(() {
      threadsSnapshot = List.of(sampleMessageThreads);
    });

    tearDown(() {
      sampleMessageThreads
        ..clear()
        ..addAll(threadsSnapshot);
    });

    testWidgets('renders the identity block and Reviews tab content', (
      tester,
    ) async {
      await pumpCampDetailsScreen(tester, camp: _campWithReviews);

      expect(find.text(_campWithReviews.name), findsOneWidget);

      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Dela Cruz'), findsOneWidget);
    });

    testWidgets('writing a review updates the rating and review count', (
      tester,
    ) async {
      await pumpCampDetailsScreen(tester, camp: _campWithoutReviews);

      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('writeReviewButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('starButton_5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submitReviewButton')));
      await tester.pumpAndSettle();

      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('(1 review)'), findsOneWidget);
    });

    testWidgets(
      'Message Campsite opens a thread and a sent message appears',
      (tester) async {
        await pumpCampDetailsScreen(tester, camp: _campWithoutReviews);

        await tester.tap(find.byKey(const Key('messageCampsiteButton')));
        await tester.pumpAndSettle();

        expect(find.text('No messages yet. Say hello!'), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('messageComposerField')),
          'What are the check-in hours?',
        );
        await tester.tap(find.byKey(const Key('sendMessageButton')));
        await tester.pumpAndSettle();

        expect(find.text('What are the check-in hours?'), findsOneWidget);
      },
    );
  });
}
