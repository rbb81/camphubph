import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_reservations.dart';
import 'package:camper/models/reservation.dart';
import 'package:camper/screens/camp_owner_dashboard_screen.dart';

Future<void> _pumpDashboard(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(home: CampOwnerDashboardScreen()),
  );
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
  late List<Reservation> reservationsSnapshot;

  setUp(() {
    reservationsSnapshot = List.of(sampleReservations);
  });

  tearDown(() {
    sampleReservations
      ..clear()
      ..addAll(reservationsSnapshot);
  });

  group('CampOwnerDashboardScreen', () {
    testWidgets('renders the business header, distinct from camper Profile', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      expect(find.text('Daraitan Basecamp'), findsOneWidget);
      expect(find.text('Hosted by Mang Rodel'), findsOneWidget);
      expect(find.text('Camp Owner'), findsOneWidget);
      expect(find.text('Followers'), findsNothing);
      expect(find.text('Following'), findsNothing);
    });

    testWidgets('renders seeded reservations with guest, camp, and status', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      expect(find.text('Miguel Santos'), findsOneWidget);
      expect(find.text('Mt. Daraitan campsite'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Andrea Cruz'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('confirming a pending reservation updates its status', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await tester.ensureVisible(
        find.byKey(const Key('confirmReservationButton_res_seed_pending_1')),
      );
      await tester.tap(
        find.byKey(const Key('confirmReservationButton_res_seed_pending_1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('confirmReservationButton_res_seed_pending_1')),
        findsNothing,
      );
      expect(
        sampleReservations
            .firstWhere((r) => r.id == 'res_seed_pending_1')
            .status,
        ReservationStatus.confirmed,
      );
      expect(
        find.text("Confirmed Miguel Santos's reservation."),
        findsOneWidget,
      );
    });

    testWidgets('declining a pending reservation updates its status', (
      tester,
    ) async {
      await _pumpDashboard(tester);

      await tester.ensureVisible(
        find.byKey(const Key('declineReservationButton_res_seed_pending_1')),
      );
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
      expect(
        find.text("Declined Miguel Santos's reservation."),
        findsOneWidget,
      );
    });

    testWidgets(
      'adding a reservation appends it and shows it in the list',
      (tester) async {
        await _pumpDashboard(tester);

        await tester.tap(find.byKey(const Key('addReservationButton')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('guestNameField')),
          'New Test Guest',
        );
        await tester.tap(find.byKey(const Key('campField')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Taal Lake shoreline').last);
        await tester.pumpAndSettle();

        final today = DateTime.now();
        final checkIn = DateTime(today.year, today.month, today.day)
            .add(const Duration(days: 50));
        final checkOut = checkIn.add(const Duration(days: 2));

        await _pickDate(tester, const Key('checkInField'), checkIn);
        await _pickDate(tester, const Key('checkOutField'), checkOut);

        await tester.tap(find.byKey(const Key('submitReservationButton')));
        await tester.pumpAndSettle();

        expect(find.text('New Test Guest'), findsOneWidget);
        expect(
          sampleReservations.any((r) => r.guestName == 'New Test Guest'),
          isTrue,
        );
      },
    );
  });
}
