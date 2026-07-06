import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/main.dart' as app;

Future<void> tapCreateAccount(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Create account'));
  await tester.tap(find.text('Create account'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Registration flow (real browser)', () {
    testWidgets('shows validation errors on empty submit', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create your account'));
      await tester.pumpAndSettle();

      await tapCreateAccount(tester);

      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(
        find.text('You need to accept the terms to continue.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'submits a fully valid form without Supabase configured '
        '(run this file without --dart-define-from-file)', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create your account'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('fullNameField')),
        'Jasmine Reyes',
      );
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'jasmine+integration@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('termsCheckbox')));
      await tester.pump();

      await tapCreateAccount(tester);

      // Confirms the app fails gracefully (no crash) when Supabase isn't
      // configured, mirroring the equivalent widget test in
      // test/register_screen_test.dart but driven through a real browser.
      expect(
        find.textContaining("Supabase isn't configured"),
        findsOneWidget,
      );
    });
  });
}
