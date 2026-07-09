import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/user_role.dart';
import 'package:camper/screens/register_screen.dart';

Future<void> pumpRegisterScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(home: RegisterScreen()),
  );
}

Future<void> tapCreateAccount(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Create account'));
  await tester.tap(find.text('Create account'));
  await tester.pumpAndSettle();
}

void main() {
  group('RegisterScreen validation', () {
    testWidgets('shows all required-field errors on empty submit', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);

      await tapCreateAccount(tester);

      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(
        find.text('You need to accept the terms to continue.'),
        findsOneWidget,
      );
    });

    testWidgets('shows an error for an invalid email address', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);

      await tester.enterText(
        find.byKey(const Key('fullNameField')),
        'Jasmine Reyes',
      );
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'not-an-email',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        'password123',
      );

      await tapCreateAccount(tester);

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('shows an error when passwords do not match', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);

      await tester.enterText(
        find.byKey(const Key('fullNameField')),
        'Jasmine Reyes',
      );
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'jasmine@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirmPasswordField')),
        'password456',
      );

      await tapCreateAccount(tester);

      expect(find.text("Passwords don't match."), findsOneWidget);
    });

    testWidgets(
      'submitting a fully valid form succeeds via the dummy auth fallback '
      'when Supabase is not configured',
      (WidgetTester tester) async {
        await pumpRegisterScreen(tester);

        await tester.enterText(
          find.byKey(const Key('fullNameField')),
          'Jasmine Reyes',
        );
        await tester.enterText(
          find.byKey(const Key('emailField')),
          'jasmine@example.com',
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

        expect(find.text('Check your email'), findsOneWidget);
      },
    );
  });

  group('RegisterScreen account type', () {
    testWidgets('defaults to Camper selected', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);

      final segmentedButton = tester.widget<SegmentedButton<UserRole>>(
        find.byKey(const Key('accountTypeField')),
      );

      expect(segmentedButton.selected, {UserRole.camper});
    });

    testWidgets(
      'selecting Camp Owner and submitting a valid form still succeeds',
      (WidgetTester tester) async {
        await pumpRegisterScreen(tester);

        await tester.ensureVisible(find.text('Camp Owner'));
        await tester.tap(find.text('Camp Owner'));
        await tester.pump();

        final segmentedButton = tester.widget<SegmentedButton<Object?>>(
          find.byKey(const Key('accountTypeField')),
        );
        expect(segmentedButton.selected, {UserRole.campOwner});

        await tester.enterText(
          find.byKey(const Key('fullNameField')),
          'Owen Reyes',
        );
        await tester.enterText(
          find.byKey(const Key('emailField')),
          'owen@example.com',
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

        expect(find.text('Check your email'), findsOneWidget);
      },
    );
  });
}
