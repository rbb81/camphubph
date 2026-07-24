import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_settings.dart';
import 'package:camper/models/auth_result.dart';
import 'package:camper/models/user_role.dart';
import 'package:camper/screens/settings_screen.dart';
import 'package:camper/services/auth_service.dart';
import 'package:camper/theme/app_theme.dart';

Future<void> _pumpSettings(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      initialRoute: '/settings',
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/': (context) => const Scaffold(body: Text('Landing page')),
      },
    ),
  );
}

void main() {
  late ThemeMode themeModeSnapshot;
  late bool pushNotificationsSnapshot;
  late bool likesAndCommentsSnapshot;
  late bool followRequestsSnapshot;
  late bool communityActivitySnapshot;
  late bool shareLocationSnapshot;
  late bool allowMessagesSnapshot;
  late AuthResult? sessionSnapshot;

  setUp(() {
    themeModeSnapshot = themeModeNotifier.value;
    pushNotificationsSnapshot = sampleSettings.pushNotifications;
    likesAndCommentsSnapshot = sampleSettings.likesAndComments;
    followRequestsSnapshot = sampleSettings.followRequests;
    communityActivitySnapshot = sampleSettings.communityActivity;
    shareLocationSnapshot = sampleSettings.shareLocation;
    allowMessagesSnapshot = sampleSettings.allowMessagesFromAnyone;
    sessionSnapshot = AuthService.instance.currentSession;
    AuthService.instance.currentSession = const AuthResult(
      role: UserRole.camper,
      email: 'ana@example.com',
      fullName: 'Ana Dela Cruz',
    );
  });

  tearDown(() {
    themeModeNotifier.value = themeModeSnapshot;
    sampleSettings.pushNotifications = pushNotificationsSnapshot;
    sampleSettings.likesAndComments = likesAndCommentsSnapshot;
    sampleSettings.followRequests = followRequestsSnapshot;
    sampleSettings.communityActivity = communityActivitySnapshot;
    sampleSettings.shareLocation = shareLocationSnapshot;
    sampleSettings.allowMessagesFromAnyone = allowMessagesSnapshot;
    AuthService.instance.currentSession = sessionSnapshot;
  });

  group('SettingsScreen', () {
    testWidgets('renders all grouped sections', (tester) async {
      await _pumpSettings(tester);

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('selecting Dark updates themeModeNotifier live', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(themeModeNotifier.value, ThemeMode.system);

      await tester.tap(find.text('Dark'));
      await tester.pump();

      expect(themeModeNotifier.value, ThemeMode.dark);
    });

    testWidgets('toggling a notification switch flips sampleSettings', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(sampleSettings.likesAndComments, isTrue);

      await tester.tap(find.byKey(const Key('likesAndCommentsToggle')));
      await tester.pump();

      expect(sampleSettings.likesAndComments, isFalse);
    });

    testWidgets('toggling a privacy switch flips sampleSettings', (
      tester,
    ) async {
      await _pumpSettings(tester);

      expect(sampleSettings.shareLocation, isTrue);

      await tester.tap(find.byKey(const Key('shareLocationToggle')));
      await tester.pump();

      expect(sampleSettings.shareLocation, isFalse);
    });

    testWidgets('toggle state survives leaving and returning to Settings', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.byKey(const Key('followRequestsToggle')));
      await tester.pump();
      expect(sampleSettings.followRequests, isFalse);

      // Re-pump a fresh SettingsScreen (simulates navigating away and back)
      // and confirm the shared object retained the change.
      await _pumpSettings(tester);

      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const Key('followRequestsToggle')),
      );
      expect(toggle.value, isFalse);
    });

    testWidgets('Log Out dialog Cancel does not navigate away', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.byKey(const Key('logOutButton')));
      await tester.pumpAndSettle();

      expect(find.text('Log out?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancelLogOutButton')));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Landing page'), findsNothing);
      expect(AuthService.instance.currentSession, isNotNull);
    });

    testWidgets(
      'Log Out confirm clears the session and navigates to Landing',
      (tester) async {
        await _pumpSettings(tester);

        await tester.tap(find.byKey(const Key('logOutButton')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('confirmLogOutButton')));
        await tester.pumpAndSettle();

        expect(find.text('Landing page'), findsOneWidget);
        expect(AuthService.instance.currentSession, isNull);
      },
    );
  });
}
