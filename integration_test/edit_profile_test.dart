import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/screens/edit_profile_screen.dart';

Future<void> pumpEditProfileScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: EditProfileScreen(profile: sampleProfile)),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Profile (real browser)', () {
    testWidgets('pre-populates the form from the current profile', (
      tester,
    ) async {
      await pumpEditProfileScreen(tester);

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('nameField')),
      );
      expect(nameField.controller!.text, sampleProfile.name);
    });

    testWidgets('shows a validation error when name is cleared', (
      tester,
    ) async {
      await pumpEditProfileScreen(tester);

      await tester.enterText(find.byKey(const Key('nameField')), '');
      await tester.ensureVisible(find.byKey(const Key('saveProfileButton')));
      await tester.tap(find.byKey(const Key('saveProfileButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name.'), findsOneWidget);
    });
  });
}
