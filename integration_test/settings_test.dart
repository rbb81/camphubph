import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_settings.dart';
import 'package:camper/models/auth_result.dart';
import 'package:camper/models/user_role.dart';
import 'package:camper/screens/settings_screen.dart';
import 'package:camper/services/auth_service.dart';
import 'package:camper/theme/app_theme.dart';

// Normally reached by tapping the gear icon on Profile (see
// integration_test/profile_test.dart). Pumped directly here so this screen
// also gets its own real-browser chromedriver smoke test, matching the
// pattern in integration_test/notifications_test.dart.
Future<void> _pumpSettings(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      initialRoute: '/settings',
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/': (context) => const Scaffold(body: Text('Landing page')),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings (real browser)', () {
    late ThemeMode themeModeSnapshot;
    late bool followRequestsSnapshot;
    late AuthResult? sessionSnapshot;

    setUp(() {
      themeModeSnapshot = themeModeNotifier.value;
      followRequestsSnapshot = sampleSettings.followRequests;
      sessionSnapshot = AuthService.instance.currentSession;
      AuthService.instance.currentSession = const AuthResult(
        role: UserRole.camper,
        email: 'ana@example.com',
        fullName: 'Ana Dela Cruz',
      );
    });

    tearDown(() {
      themeModeNotifier.value = themeModeSnapshot;
      sampleSettings.followRequests = followRequestsSnapshot;
      AuthService.instance.currentSession = sessionSnapshot;
    });

    testWidgets('renders all grouped sections', (tester) async {
      await _pumpSettings(tester);

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Log Out'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('selecting Dark live-updates themeModeNotifier', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Dark'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeModeNotifier.value, ThemeMode.dark);
    });

    testWidgets('toggling Follow requests flips sampleSettings', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('followRequestsToggle')),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.byKey(const Key('followRequestsToggle')));
      await tester.pumpAndSettle();

      expect(sampleSettings.followRequests, isFalse);
    });

    testWidgets('Log Out confirm clears the session and navigates away', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.byKey(const Key('logOutButton')),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.byKey(const Key('logOutButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirmLogOutButton')));
      await tester.pumpAndSettle();

      expect(find.text('Landing page'), findsOneWidget);
      expect(AuthService.instance.currentSession, isNull);
    });
  });
}
