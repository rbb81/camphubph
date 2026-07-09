import 'package:flutter_test/flutter_test.dart';

import 'package:camper/main.dart';

void main() {
  testWidgets('Landing screen shows CTA that navigates to registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CamperApp());

    expect(find.text('Camper'), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);

    await tester.tap(find.text('Create your account'));
    await tester.pumpAndSettle();

    expect(find.text('Start planning your next camping trip.'), findsOneWidget);
  });

  testWidgets(
    'Landing screen preview button navigates to the Camp Owner Dashboard',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CamperApp());

      await tester.tap(find.text('Preview Camp Owner View (test)'));
      await tester.pumpAndSettle();

      expect(find.text('Daraitan Basecamp'), findsOneWidget);
    },
  );
}
