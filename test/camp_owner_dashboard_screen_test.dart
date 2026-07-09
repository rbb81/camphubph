import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/camp_owner_dashboard_screen.dart';

void main() {
  testWidgets('CampOwnerDashboardScreen renders welcome content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CampOwnerDashboardScreen()),
    );

    expect(find.text('Camp Owner Dashboard'), findsOneWidget);
    expect(find.text('Welcome, camp owner!'), findsOneWidget);
    expect(find.byIcon(Icons.holiday_village), findsOneWidget);
  });
}
