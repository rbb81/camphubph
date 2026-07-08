import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/camp_results_screen.dart';

Future<void> pumpCampResultsScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: CampResultsScreen(category: 'Mountains')),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camp Results (real browser)', () {
    testWidgets('renders only camps matching the category', (tester) async {
      await pumpCampResultsScreen(tester);

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(find.text('Nasugbu beach camp'), findsNothing);
    });

    testWidgets('tapping a camp card navigates to Camp Details', (
      tester,
    ) async {
      await pumpCampResultsScreen(tester);

      await tester.tap(find.text('Mt. Daraitan campsite'));
      await tester.pumpAndSettle();

      expect(find.text('Tanay, Rizal'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
    });
  });
}
