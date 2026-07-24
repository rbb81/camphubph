import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/search_screen.dart';

Future<void> pumpSearchScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
}

Future<void> enterQuery(WidgetTester tester, String query) async {
  await tester.enterText(find.byKey(const Key('searchQueryField')), query);
  await tester.pumpAndSettle();
}

void main() {
  group('SearchScreen', () {
    testWidgets('shows a neutral prompt when the query is empty', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      expect(
        find.text(
          'Search camps, communities, people, locations, and activities.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('typing a camp name shows a matching camp result', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Daraitan');

      expect(find.byKey(const Key('searchCampRow_daraitan')), findsOneWidget);
      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
    });

    testWidgets(
      'an initialQuery pre-fills the field and shows results immediately',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          const MaterialApp(home: SearchScreen(initialQuery: 'Daraitan')),
        );

        expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      },
    );

    testWidgets('tapping a camp result opens Camp Details', (tester) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Daraitan');
      await tester.tap(find.byKey(const Key('searchCampRow_daraitan')));
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('typing a community name shows and opens Community Feed', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Overlanders');
      expect(
        find.byKey(const Key('searchCommunityRow_luzon-overlanders')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('searchCommunityRow_luzon-overlanders')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsOneWidget);
    });

    testWidgets('typing a person name shows and opens Other User Profile', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Jasmine');
      expect(
        find.byKey(const Key('searchPersonRow_Jasmine Reyes')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('searchPersonRow_Jasmine Reyes')));
      await tester.pumpAndSettle();

      expect(find.text('Jasmine Reyes'), findsWidgets);
    });

    testWidgets('matching is case-insensitive', (tester) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'JASMINE');

      expect(
        find.byKey(const Key('searchPersonRow_Jasmine Reyes')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Locations chip shows unique camp locations and opens filtered camp results',
      (tester) async {
        await pumpSearchScreen(tester);

        await enterQuery(tester, 'Batangas');
        await tester.tap(find.byKey(const Key('searchFacetChip_locations')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('searchLocationRow_Nasugbu, Batangas')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('searchLocationRow_Nasugbu, Batangas')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nasugbu, Batangas'), findsOneWidget);
        expect(find.text('Nasugbu beach camp'), findsOneWidget);
      },
    );

    testWidgets(
      'Activities chip shows matching categories and opens Camp Results',
      (tester) async {
        await pumpSearchScreen(tester);

        await enterQuery(tester, 'Mountain');
        await tester.tap(find.byKey(const Key('searchFacetChip_activities')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('searchActivityRow_Mountains')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('searchActivityRow_Mountains')));
        await tester.pumpAndSettle();

        expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
      },
    );

    testWidgets('All facet groups results with a See all affordance', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'a');

      expect(find.textContaining('Camps ('), findsOneWidget);
      expect(find.byKey(const Key('searchSeeAll_camps')), findsOneWidget);

      await tester.tap(find.byKey(const Key('searchSeeAll_camps')));
      await tester.pumpAndSettle();

      final chip = tester.widget<ChoiceChip>(
        find.byKey(const Key('searchFacetChip_camps')),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('no results shows a helpful empty state', (tester) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'zzzznotfound');

      expect(find.text("No results for 'zzzznotfound'."), findsOneWidget);
    });

    testWidgets('clearing the query returns to the empty-state prompt', (
      tester,
    ) async {
      await pumpSearchScreen(tester);

      await enterQuery(tester, 'Daraitan');
      expect(find.byKey(const Key('searchCampRow_daraitan')), findsOneWidget);

      await tester.tap(find.byKey(const Key('searchClearButton')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Search camps, communities, people, locations, and activities.',
        ),
        findsOneWidget,
      );
    });
  });
}
