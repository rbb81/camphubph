import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_camps.dart';
import 'package:camper/data/sample_profile.dart';
import 'package:camper/screens/write_review_screen.dart';

final _camp = sampleCamps.firstWhere((c) => c.id == 'daraitan');

Future<void> pumpWriteReviewScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WriteReviewScreen(camp: _camp, author: sampleProfile),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Write Review (real browser)', () {
    testWidgets('submitting without a rating shows a validation error', (
      tester,
    ) async {
      await pumpWriteReviewScreen(tester);

      await tester.tap(find.byKey(const Key('submitReviewButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Select a rating to submit your review.'),
        findsOneWidget,
      );
    });

    testWidgets('adding a pro chip shows it in the list', (tester) async {
      await pumpWriteReviewScreen(tester);

      await tester.enterText(
        find.byKey(const Key('prosField')),
        'Great sunrise view',
      );
      await tester.tap(find.byKey(const Key('addProButton')));
      await tester.pumpAndSettle();

      expect(find.text('Great sunrise view'), findsOneWidget);
    });
  });
}
