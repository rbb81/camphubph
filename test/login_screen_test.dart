import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/user_role.dart';
import 'package:camper/screens/login_screen.dart';
import 'package:camper/services/auth_service.dart';

Future<void> pumpLoginScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const Scaffold(body: Text('Register page')),
        '/forgot-password': (context) =>
            const Scaffold(body: Text('Forgot password page')),
        '/home': (context) => const Scaffold(body: Text('Home page')),
        '/owner-home': (context) =>
            const Scaffold(body: Text('Owner home page')),
      },
    ),
  );
}

Future<void> tapLogIn(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Log in').last);
  await tester.tap(find.text('Log in').last);
  await tester.pumpAndSettle();
}

void main() {
  group('LoginScreen validation', () {
    testWidgets('shows required-field errors on empty submit', (
      WidgetTester tester,
    ) async {
      await pumpLoginScreen(tester);

      await tapLogIn(tester);

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets('shows an error for an invalid email address', (
      WidgetTester tester,
    ) async {
      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'not-an-email',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      await tapLogIn(tester);

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets(
      'submitting valid credentials navigates to home via the dummy auth '
      'fallback when Supabase is not configured',
      (WidgetTester tester) async {
        await pumpLoginScreen(tester);

        await tester.enterText(
          find.byKey(const Key('emailField')),
          'jasmine@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('passwordField')),
          'password123',
        );

        await tapLogIn(tester);

        expect(find.text('Home page'), findsOneWidget);
      },
    );

    testWidgets('navigates to forgot password', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot password page'), findsOneWidget);
    });

    testWidgets('navigates to register via sign up link', (
      WidgetTester tester,
    ) async {
      await pumpLoginScreen(tester);

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Register page'), findsOneWidget);
    });

    testWidgets(
      'a camp owner account routes to the owner dashboard, not home',
      (WidgetTester tester) async {
        final email =
            'owner-login-${DateTime.now().microsecondsSinceEpoch}@example.com';
        // AuthService's dummy fallback uses a real Future.delayed, which
        // never resolves under testWidgets' fake-async clock unless it's
        // driven by tester.pump(). tester.runAsync steps outside the
        // fake-async zone so this real delay actually completes.
        await tester.runAsync(
          () => AuthService.instance.signUp(
            email: email,
            password: 'password123',
            fullName: 'Owen Reyes',
            role: UserRole.campOwner,
          ),
        );

        await pumpLoginScreen(tester);

        await tester.enterText(find.byKey(const Key('emailField')), email);
        await tester.enterText(
          find.byKey(const Key('passwordField')),
          'password123',
        );

        await tapLogIn(tester);

        expect(find.text('Owner home page'), findsOneWidget);
        expect(find.text('Home page'), findsNothing);
      },
    );
  });
}
