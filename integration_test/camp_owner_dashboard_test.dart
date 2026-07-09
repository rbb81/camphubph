import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_message_threads.dart';
import 'package:camper/data/sample_reservations.dart';
import 'package:camper/models/auth_result.dart';
import 'package:camper/models/message_thread.dart';
import 'package:camper/models/reservation.dart';
import 'package:camper/models/user_role.dart';
import 'package:camper/screens/camp_owner_dashboard_screen.dart';
import 'package:camper/services/auth_service.dart';

// Normally reached after a camp-owner login (see integration_test/login_test.dart)
// or the Landing screen's "Preview Camp Owner View (test)" shortcut (see
// integration_test/landing_test.dart). Pumped directly here so this screen
// also gets its own real-browser chromedriver smoke test, matching the
// pattern in integration_test/home_test.dart.
Future<void> pumpDashboard(WidgetTester tester) async {
  // The dashboard's ListView virtualizes off-screen content — with
  // Reservations + Messages both seeded, the default chromedriver browser
  // viewport isn't tall enough to build the Messages section without
  // scrolling. Match the tall viewport used in
  // test/camp_owner_dashboard_screen_test.dart.
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(home: CampOwnerDashboardScreen()),
  );
  await tester.pumpAndSettle();
}

String _fmt(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

Future<void> _pickDate(WidgetTester tester, Key fieldKey, DateTime date) async {
  await tester.tap(find.byKey(fieldKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, _fmt(date));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camp Owner Dashboard (real browser)', () {
    late List<Reservation> reservationsSnapshot;
    late List<MessageThread> threadsSnapshot;
    late AuthResult? sessionSnapshot;

    setUp(() {
      reservationsSnapshot = List.of(sampleReservations);
      threadsSnapshot = List.of(sampleMessageThreads);
      sessionSnapshot = AuthService.instance.currentSession;
    });

    tearDown(() {
      sampleReservations
        ..clear()
        ..addAll(reservationsSnapshot);
      sampleMessageThreads
        ..clear()
        ..addAll(threadsSnapshot);
      AuthService.instance.currentSession = sessionSnapshot;
    });

    testWidgets(
      'with no signed-in session, renders the demo placeholder business info',
      (tester) async {
        AuthService.instance.currentSession = null;
        await pumpDashboard(tester);

        expect(find.text('Daraitan Basecamp'), findsOneWidget);
        expect(find.text('Camp Owner'), findsOneWidget);
        expect(find.text('Miguel Santos'), findsOneWidget);
        expect(find.text('Reservations'), findsOneWidget);
      },
    );

    testWidgets(
      'with a signed-in session, renders the real campsite name and host info',
      (tester) async {
        AuthService.instance.currentSession = const AuthResult(
          role: UserRole.campOwner,
          email: 'realowner@example.com',
          fullName: 'Real Owner',
          campsiteName: 'Real Campsite',
        );
        await pumpDashboard(tester);

        expect(find.text('Real Campsite'), findsOneWidget);
        expect(
          find.text('Hosted by Real Owner · realowner@example.com'),
          findsOneWidget,
        );
      },
    );

    testWidgets('confirming a pending reservation flips its status', (
      tester,
    ) async {
      await pumpDashboard(tester);

      await tester.tap(
        find.byKey(const Key('confirmReservationButton_res_seed_pending_1')),
      );
      await tester.pumpAndSettle();

      expect(
        sampleReservations
            .firstWhere((r) => r.id == 'res_seed_pending_1')
            .status,
        ReservationStatus.confirmed,
      );
    });

    testWidgets('declining a pending reservation flips its status', (
      tester,
    ) async {
      await pumpDashboard(tester);

      await tester.tap(
        find.byKey(const Key('declineReservationButton_res_seed_pending_1')),
      );
      await tester.pumpAndSettle();

      expect(
        sampleReservations
            .firstWhere((r) => r.id == 'res_seed_pending_1')
            .status,
        ReservationStatus.declined,
      );
    });

    testWidgets('adding a reservation appends it to the list', (
      tester,
    ) async {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      final checkIn = base.add(const Duration(days: 60));
      final checkOut = base.add(const Duration(days: 62));

      await pumpDashboard(tester);

      await tester.tap(find.byKey(const Key('addReservationButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('guestNameField')),
        'Chromedriver Guest',
      );
      await tester.tap(find.byKey(const Key('campField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Taal Lake shoreline').last);
      await tester.pumpAndSettle();

      await _pickDate(tester, const Key('checkInField'), checkIn);
      await _pickDate(tester, const Key('checkOutField'), checkOut);

      await tester.tap(find.byKey(const Key('submitReservationButton')));
      await tester.pumpAndSettle();

      expect(find.text('Chromedriver Guest'), findsOneWidget);
      expect(
        sampleReservations.any((r) => r.guestName == 'Chromedriver Guest'),
        isTrue,
      );
    });

    testWidgets('renders seeded message threads with guest and preview', (
      tester,
    ) async {
      await pumpDashboard(tester);

      expect(find.text('Ana Dela Cruz'), findsOneWidget);
      expect(
        find.textContaining("It's open and calm this week"),
        findsOneWidget,
      );
    });

    testWidgets(
      'opening a thread and replying as owner updates it and the preview',
      (tester) async {
        await pumpDashboard(tester);

        await tester.tap(find.byKey(const Key('threadCard_thread_seed_1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('messageComposerField')),
          'Glad it worked out!',
        );
        await tester.tap(find.byKey(const Key('sendMessageButton')));
        await tester.pumpAndSettle();

        expect(
          sampleMessageThreads
              .firstWhere((t) => t.id == 'thread_seed_1')
              .messages
              .last
              .senderIsOwner,
          isTrue,
        );

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Glad it worked out!'), findsOneWidget);
      },
    );
  });
}
