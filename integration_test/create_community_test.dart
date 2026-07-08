import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/create_community_screen.dart';

Future<void> pumpCreateCommunityScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: CreateCommunityScreen()));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create Community (real browser)', () {
    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      await pumpCreateCommunityScreen(tester);

      await tester.tap(find.byKey(const Key('createCommunitySubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Give your community a name.'), findsOneWidget);
      expect(
        find.text('Describe what this community is about.'),
        findsOneWidget,
      );
    });

    testWidgets('selecting Private updates the helper text', (tester) async {
      await pumpCreateCommunityScreen(tester);

      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();

      expect(
        find.text('Only people you approve can join and see posts.'),
        findsOneWidget,
      );
    });
  });
}
