import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/data/sample_trips.dart';
import 'package:camper/models/camp.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/models/trip.dart';
import 'package:camper/screens/camp_details_screen.dart';

final _campWithReviews = sampleCamps.firstWhere((c) => c.id == 'daraitan');
final _campWithoutReviews = sampleCamps.firstWhere(
  (c) => c.id == 'batangas-ridge',
);

class _ResultCapture {
  Camp? value;
}

Future<_ResultCapture> _pumpCampDetailsHost(
  WidgetTester tester, {
  required Camp camp,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<Camp>(
                  MaterialPageRoute(
                    builder: (_) => CampDetailsScreen(camp: camp),
                  ),
                );
              },
              child: const Text('Open Camp'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Camp'));
  await tester.pumpAndSettle();
  return capture;
}

String _fmt(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

Future<void> _pickDate(WidgetTester tester, Key fieldKey, DateTime date) async {
  await tester.tap(find.byKey(fieldKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), _fmt(date));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  late List<Trip> tripsSnapshot;
  late List<MessageThread> threadsSnapshot;

  setUp(() {
    tripsSnapshot = List.of(sampleTrips);
    threadsSnapshot = List.of(sampleMessageThreads);
  });

  tearDown(() {
    sampleTrips
      ..clear()
      ..addAll(tripsSnapshot);
    sampleMessageThreads
      ..clear()
      ..addAll(threadsSnapshot);
  });

  group('CampDetailsScreen', () {
    testWidgets('renders the identity block with camp data', (tester) async {
      await _pumpCampDetailsHost(tester, camp: _campWithReviews);

      expect(find.text(_campWithReviews.name), findsOneWidget);
      expect(find.text(_campWithReviews.location), findsOneWidget);
      expect(find.text('4.6'), findsOneWidget);
      expect(find.text('(2 reviews)'), findsOneWidget);
      expect(find.text('Mountains'), findsOneWidget);
    });

    testWidgets('tapping the bookmark toggles saved state', (tester) async {
      await _pumpCampDetailsHost(tester, camp: _campWithReviews);

      await tester.tap(find.byKey(const Key('bookmarkButton')));
      await tester.pump();

      expect(find.text('Saved to your camps.'), findsOneWidget);
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('bookmarkButton')),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.icon, Icons.bookmark);
    });

    testWidgets('Reviews tab lists existing reviews for the camp', (
      tester,
    ) async {
      await _pumpCampDetailsHost(tester, camp: _campWithReviews);

      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Dela Cruz'), findsOneWidget);
      expect(find.text('Miguel Ibarra'), findsOneWidget);
    });

    testWidgets('Reviews tab shows an empty state for a camp with none', (
      tester,
    ) async {
      await _pumpCampDetailsHost(tester, camp: _campWithoutReviews);

      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();

      expect(
        find.text('No reviews yet — be the first to share one.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'writing a review appends it, updates the rating, and returns the updated camp',
      (tester) async {
        final capture = await _pumpCampDetailsHost(
          tester,
          camp: _campWithoutReviews,
        );

        await tester.tap(find.text('Reviews'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('writeReviewButton')));
        await tester.pumpAndSettle();

        expect(find.text('Write a Review'), findsOneWidget);

        await tester.tap(find.byKey(const Key('starButton_5')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('submitReviewButton')));
        await tester.pumpAndSettle();

        expect(find.text('5.0'), findsOneWidget);
        expect(find.text('(1 review)'), findsOneWidget);
        expect(
          find.text('No reviews yet — be the first to share one.'),
          findsNothing,
        );

        await tester.tap(find.byKey(const Key('backButton')));
        await tester.pumpAndSettle();

        expect(capture.value, isNotNull);
        expect(capture.value!.reviewCount, 1);
        expect(capture.value!.rating, 5.0);
      },
    );

    testWidgets(
      'Add to Trip schedules a trip and shows a confirmation snackbar',
      (tester) async {
        await _pumpCampDetailsHost(tester, camp: _campWithReviews);

        await tester.tap(find.byKey(const Key('addToTripButton')));
        await tester.pumpAndSettle();

        expect(find.text('Schedule Trip'), findsOneWidget);

        final today = DateTime.now();
        final base = DateTime(today.year, today.month, today.day);
        await _pickDate(
          tester,
          const Key('checkInField'),
          base.add(const Duration(days: 200)),
        );
        await _pickDate(
          tester,
          const Key('checkOutField'),
          base.add(const Duration(days: 202)),
        );

        await tester.tap(find.byKey(const Key('submitTripButton')));
        await tester.pumpAndSettle();

        expect(
          find.text('Added ${_campWithReviews.name} to your trips.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Message Campsite reuses an existing thread for this guest and camp',
      (tester) async {
        await _pumpCampDetailsHost(tester, camp: _campWithReviews);

        await tester.tap(find.byKey(const Key('messageCampsiteButton')));
        await tester.pumpAndSettle();

        expect(find.text(_campWithReviews.name), findsOneWidget);
        expect(
          find.textContaining('Is the river crossing open'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Message Campsite starts a new empty thread when none exists yet',
      (tester) async {
        await _pumpCampDetailsHost(tester, camp: _campWithoutReviews);

        await tester.tap(find.byKey(const Key('messageCampsiteButton')));
        await tester.pumpAndSettle();

        expect(find.text(_campWithoutReviews.name), findsOneWidget);
        expect(find.text('No messages yet. Say hello!'), findsOneWidget);
        expect(
          sampleMessageThreads.any(
            (t) =>
                t.campId == _campWithoutReviews.id &&
                t.participantA == 'Ana Dela Cruz',
          ),
          isTrue,
        );
      },
    );
  });
}
