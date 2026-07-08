import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/camp_results_screen.dart';

Future<void> pumpCampResultsScreen(
  WidgetTester tester, {
  String category = 'Mountains',
}) async {
  await tester.pumpWidget(
    MaterialApp(home: CampResultsScreen(category: category)),
  );
}

void main() {
  group('CampResultsScreen', () {
    testWidgets('renders only camps matching the category', (tester) async {
      await pumpCampResultsScreen(tester);

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      expect(find.text('Batangas Ridge'), findsOneWidget);
      expect(find.text('Nasugbu beach camp'), findsNothing);
    });

    testWidgets('shows an empty state when the minimum rating filters everything out', (
      tester,
    ) async {
      // Rivers has a single sample camp rated 4.1, so a 4.5+ filter empties it.
      await pumpCampResultsScreen(tester, category: 'Rivers');
      expect(find.text('Pagsanjan River camp'), findsOneWidget);

      await tester.tap(find.byKey(const Key('filterButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ratingChip_4.5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('applyFiltersButton')));
      await tester.pumpAndSettle();

      expect(find.text('No camps match your filters.'), findsOneWidget);
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
