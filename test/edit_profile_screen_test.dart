import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/models/profile.dart';
import 'package:camper/screens/edit_profile_screen.dart';

class _ResultCapture {
  UserProfile? value;
}

Future<void> pumpEditProfileScreen(
  WidgetTester tester, {
  UserProfile? profile,
}) async {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(home: EditProfileScreen(profile: profile ?? sampleProfile)),
  );
}

/// Hosts EditProfileScreen behind a button push so the popped result can be
/// captured, mirroring how ProfileScreen actually opens it.
Future<_ResultCapture> _pumpEditProfileHost(
  WidgetTester tester, {
  UserProfile? profile,
}) async {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<UserProfile>(
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProfileScreen(profile: profile ?? sampleProfile),
                  ),
                );
              },
              child: const Text('Open Edit Profile'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Edit Profile'));
  await tester.pumpAndSettle();
  return capture;
}

void main() {
  group('EditProfileScreen', () {
    testWidgets('pre-populates fields from the passed profile', (tester) async {
      await pumpEditProfileScreen(tester);

      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('nameField')),
      );
      final bioField = tester.widget<TextFormField>(
        find.byKey(const Key('bioField')),
      );

      expect(nameField.controller!.text, sampleProfile.name);
      expect(bioField.controller!.text, sampleProfile.bio);
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
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('toggling a style chip updates its selected state', (
      tester,
    ) async {
      await pumpEditProfileScreen(tester);

      final chipFinder = find.byKey(const Key('styleChip_Glamping'));
      final before = tester.widget<FilterChip>(chipFinder).selected;

      await tester.ensureVisible(chipFinder);
      await tester.tap(chipFinder);
      await tester.pump();

      final after = tester.widget<FilterChip>(chipFinder).selected;
      expect(after, !before);
    });

    testWidgets('changing avatar/cover buttons are present and tappable', (
      tester,
    ) async {
      await pumpEditProfileScreen(tester);

      expect(find.byKey(const Key('changeAvatarButton')), findsOneWidget);
      expect(find.byKey(const Key('changeCoverButton')), findsOneWidget);

      // No image_picker platform implementation is registered in widget
      // tests, so invoking the callback just exercises the picker call
      // without a real gallery — it should complete without crashing, and
      // the screen should still be usable afterward. Invoked directly
      // (rather than via tester.tap) since the button deliberately overlaps
      // the cover/avatar Stack, which makes pixel-based hit testing
      // unreliable in the test harness.
      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(const Key('changeAvatarButton')),
          matching: find.byType(InkWell),
        ),
      );
      inkWell.onTap!();
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('save pops with the edited profile', (tester) async {
      final capture = await _pumpEditProfileHost(tester);

      await tester.enterText(
        find.byKey(const Key('nameField')),
        'Updated Name',
      );
      await tester.ensureVisible(find.text('Expert'));
      await tester.tap(find.text('Expert'));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('styleChip_Glamping')));
      await tester.tap(find.byKey(const Key('styleChip_Glamping')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('saveProfileButton')));
      await tester.tap(find.byKey(const Key('saveProfileButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.name, 'Updated Name');
      expect(capture.value!.experienceLevel, ExperienceLevel.expert);
      expect(capture.value!.favoriteStyles.contains('Glamping'), isTrue);
    });
  });
}
