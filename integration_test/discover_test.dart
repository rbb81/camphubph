import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/discover_screen.dart';

Future<void> pumpDiscoverScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Discover (real browser)', () {
    testWidgets('renders the category grid', (tester) async {
      await pumpDiscoverScreen(tester);

      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Mountains'), findsOneWidget);
      expect(find.text('Beaches'), findsOneWidget);
    });

    testWidgets('tapping a category navigates to its results list', (
      tester,
    ) async {
      await pumpDiscoverScreen(tester);

      await tester.tap(find.byKey(const Key('categoryTile_Mountains')));
      await tester.pumpAndSettle();

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
    });
  });
}
