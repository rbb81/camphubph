import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/main.dart' as app;
import 'package:camper/models/user_role.dart';
import 'package:camper/services/auth_service.dart';

Future<void> tapLogInButton(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Log in').last);
  await tester.tap(find.text('Log in').last);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login flow (real browser)', () {
    testWidgets('shows validation errors on empty submit', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in').first);
      await tester.pumpAndSettle();

      await tapLogInButton(tester);

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets(
        'submitting valid credentials navigates to home via the dummy auth '
        'fallback (run this file without --dart-define-from-file)',
        (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'jasmine+integration@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      await tapLogInButton(tester);

      expect(find.text('Recommended near you'), findsWidgets);
    });

    testWidgets(
        'a camp owner account routes to the owner dashboard, not home '
        '(run this file without --dart-define-from-file)', (tester) async {
      final email =
          'owen+integration-${DateTime.now().microsecondsSinceEpoch}'
          '@example.com';
      await AuthService.instance.signUp(
        email: email,
        password: 'password123',
        fullName: 'Owen Reyes',
        role: UserRole.campOwner,
      );

      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('emailField')), email);
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      await tapLogInButton(tester);

      expect(find.text('Camp Owner Dashboard'), findsOneWidget);
      expect(find.text('Recommended near you'), findsNothing);
    });
  });
}
