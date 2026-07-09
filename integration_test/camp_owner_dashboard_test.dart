import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/camp_owner_dashboard_screen.dart';

// Normally reached after a camp-owner login, which is exercised end to end
// in integration_test/login_test.dart. Pumped directly here so this screen
// also gets its own real-browser chromedriver smoke test, matching the
// pattern in integration_test/home_test.dart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camp Owner Dashboard (real browser)', () {
    testWidgets('renders the welcome content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CampOwnerDashboardScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camp Owner Dashboard'), findsOneWidget);
      expect(find.text('Welcome, camp owner!'), findsOneWidget);
    });
  });
}
