import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/forgot_password_screen.dart';

Future<void> pumpForgotPasswordScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: const ForgotPasswordScreen(),
      routes: {
        '/login': (context) => const Scaffold(body: Text('Login page')),
      },
    ),
  );
}

Future<void> tapSendResetLink(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Send reset link'));
  await tester.tap(find.text('Send reset link'));
  await tester.pumpAndSettle();
}

void main() {
  group('ForgotPasswordScreen validation', () {
    testWidgets('shows an error on empty submit', (WidgetTester tester) async {
      await pumpForgotPasswordScreen(tester);

      await tapSendResetLink(tester);

      expect(find.text('Enter your email address.'), findsOneWidget);
    });

    testWidgets('shows an error for an invalid email address', (
      WidgetTester tester,
    ) async {
      await pumpForgotPasswordScreen(tester);

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'not-an-email',
      );

      await tapSendResetLink(tester);

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets(
      'submitting a valid email without Supabase configured shows a config error',
      (WidgetTester tester) async {
        await pumpForgotPasswordScreen(tester);

        await tester.enterText(
          find.byKey(const Key('emailField')),
          'jasmine@example.com',
        );

        await tapSendResetLink(tester);

        expect(
          find.textContaining("Supabase isn't configured"),
          findsOneWidget,
        );
      },
    );

    testWidgets('navigates back to login', (WidgetTester tester) async {
      await pumpForgotPasswordScreen(tester);

      await tester.tap(find.text('Back to log in'));
      await tester.pumpAndSettle();

      expect(find.text('Login page'), findsOneWidget);
    });
  });
}
