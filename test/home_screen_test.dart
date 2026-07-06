import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/home_screen.dart';

Future<void> pumpHomeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows the app bar and bottom tab bar', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('Camper'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Communities'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders the mixed feed with sample content', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('Jasmine Reyes'), findsOneWidget);
      expect(find.text('Recommended near you'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Follow'),
        200,
        scrollable: find.byType(Scrollable),
      );

      expect(find.textContaining('Overlanding PH'), findsWidgets);
      expect(find.text('Follow'), findsWidgets);
    });

    testWidgets('tapping a non-Home tab shows a coming-soon message', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Discover'));
      await tester.pump();

      expect(find.text('Discover is coming soon.'), findsOneWidget);
    });

    testWidgets('tapping create post shows a coming-soon message', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('createPostButton')));
      await tester.pump();

      expect(find.text('Create post is coming soon.'), findsOneWidget);
    });

    testWidgets('tapping search shows a coming-soon message', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byKey(const Key('searchButton')));
      await tester.pump();

      expect(find.text('Search is coming soon.'), findsOneWidget);
    });
  });
}
