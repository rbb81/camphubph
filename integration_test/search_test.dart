import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/search_screen.dart';

Future<void> pumpSearchScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
  await tester.pumpAndSettle();
}

Future<void> enterQuery(WidgetTester tester, String query) async {
  await tester.enterText(find.byKey(const Key('searchQueryField')), query);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search (real browser)', () {
    testWidgets('typing a camp name and tapping it opens Camp Details', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Daraitan');
      await tester.tap(find.byKey(const Key('searchCampRow_daraitan')));
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets(
      'typing a community name and tapping it opens Community Feed',
      (tester) async {
        await pumpSearchScreen(tester);

        await enterQuery(tester, 'Overlanders');
        await tester.tap(
          find.byKey(const Key('searchCommunityRow_luzon-overlanders')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Feed'), findsOneWidget);
      },
    );

    testWidgets('typing a person name and tapping it opens their profile', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Jasmine');
      await tester.tap(find.byKey(const Key('searchPersonRow_Jasmine Reyes')));
      await tester.pumpAndSettle();

      expect(find.text('Jasmine Reyes'), findsWidgets);
    });

    testWidgets('Locations chip navigates into filtered Camp Results', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Batangas');
      await tester.tap(find.byKey(const Key('searchFacetChip_locations')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('searchLocationRow_Nasugbu, Batangas')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nasugbu beach camp'), findsOneWidget);
    });

    testWidgets('Activities chip navigates into filtered Camp Results', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Mountain');
      await tester.tap(find.byKey(const Key('searchFacetChip_activities')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('searchActivityRow_Mountains')));
      await tester.pumpAndSettle();

      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
    });
  });
}
