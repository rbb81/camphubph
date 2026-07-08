import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/review.dart';
import 'package:camper/screens/write_review_screen.dart';

final _camp = sampleCamps.firstWhere((c) => c.id == 'daraitan');

class _ResultCapture {
  Review? value;
}

Future<_ResultCapture> _pumpWriteReviewHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<Review>(
                  MaterialPageRoute(
                    builder: (_) =>
                        WriteReviewScreen(camp: _camp, author: sampleProfile),
                  ),
                );
              },
              child: const Text('Open Write Review'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Write Review'));
  await tester.pumpAndSettle();
  return capture;
}

void main() {
  group('WriteReviewScreen', () {
    testWidgets('renders the camp context header', (tester) async {
      await _pumpWriteReviewHost(tester);

      expect(find.text(_camp.name), findsOneWidget);
      expect(find.text(_camp.location), findsOneWidget);
    });

    testWidgets('submitting without a rating shows a validation error', (
      tester,
    ) async {
      final capture = await _pumpWriteReviewHost(tester);

      await tester.tap(find.byKey(const Key('submitReviewButton')));
      await tester.pump();

      expect(
        find.text('Select a rating to submit your review.'),
        findsOneWidget,
      );
      expect(capture.value, isNull);
    });

    testWidgets('adding and removing a pro chip updates the list', (
      tester,
    ) async {
      await _pumpWriteReviewHost(tester);

      await tester.enterText(
        find.byKey(const Key('prosField')),
        'Great river crossing',
      );
      await tester.tap(find.byKey(const Key('addProButton')));
      await tester.pump();

      expect(find.text('Great river crossing'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('removeProChip_0')),
          matching: find.byIcon(Icons.cancel),
        ),
      );
      await tester.pump();

      expect(find.text('Great river crossing'), findsNothing);
    });

    testWidgets('submitting with a rating pops a fully-populated review', (
      tester,
    ) async {
      final capture = await _pumpWriteReviewHost(tester);

      await tester.tap(find.byKey(const Key('starButton_4')));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('prosField')),
        'Great sunrise view',
      );
      await tester.tap(find.byKey(const Key('addProButton')));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('consField')),
        'Crowded on weekends',
      );
      await tester.tap(find.byKey(const Key('addConButton')));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('tipField')),
        'Bring extra water.',
      );

      await tester.tap(find.byKey(const Key('submitReviewButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.campId, _camp.id);
      expect(capture.value!.authorName, sampleProfile.name);
      expect(capture.value!.rating, 4);
      expect(capture.value!.pros, ['Great sunrise view']);
      expect(capture.value!.cons, ['Crowded on weekends']);
      expect(capture.value!.tip, 'Bring extra water.');
    });
  });
}
