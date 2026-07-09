import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Landing screen (real browser)', () {
    testWidgets('shows the brand and CTA that navigates to registration', (
      tester,
    ) async {
      await app.main();
      await tester.pumpAndSettle();

      expect(find.text('Camper'), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);

      await tester.tap(find.text('Create your account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Start planning your next camping trip.'),
        findsOneWidget,
      );
    });

    testWidgets('the "Log in" link navigates to the login screen', (
      tester,
    ) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('name@example.com'), findsOneWidget);
    });

    testWidgets(
      'the "Preview Camp Owner View (test)" button reaches the dashboard',
      (tester) async {
        await app.main();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Preview Camp Owner View (test)'));
        await tester.pumpAndSettle();

        expect(find.text('Daraitan Basecamp'), findsOneWidget);
      },
    );
  });
}
