import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Forgot password flow (real browser)', () {
    testWidgets('shows a validation error on empty submit', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Send reset link'));
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email address.'), findsOneWidget);
    });

    testWidgets(
        'submitting a valid email without Supabase configured '
        '(run this file without --dart-define-from-file)', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'jasmine+integration@example.com',
      );

      await tester.ensureVisible(find.text('Send reset link'));
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Supabase isn't configured"),
        findsOneWidget,
      );
    });
  });
}
