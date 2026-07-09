import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_reservations.dart';
import 'package:camper/models/reservation.dart';
import 'package:camper/screens/add_reservation_screen.dart';

class _ResultCapture {
  Reservation? value;
}

Future<_ResultCapture> _pumpAddReservationHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<Reservation>(
                  MaterialPageRoute(
                    builder: (_) => const AddReservationScreen(),
                  ),
                );
              },
              child: const Text('Open Add Reservation'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Add Reservation'));
  await tester.pumpAndSettle();
  return capture;
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

  group('AddReservationScreen', () {
    testWidgets('submitting an empty form shows validation errors', (
      tester,
    ) async {
      final capture = await _pumpAddReservationHost(tester);

      await tester.tap(find.byKey(const Key('submitReservationButton')));
      await tester.pump();

      expect(find.text("Enter the guest's name."), findsOneWidget);
      expect(capture.value, isNull);
    });

    testWidgets('submitting without a camp or dates shows their errors', (
      tester,
    ) async {
      final capture = await _pumpAddReservationHost(tester);

      await tester.enterText(
        find.byKey(const Key('guestNameField')),
        'Test Guest',
      );

      await tester.tap(find.byKey(const Key('submitReservationButton')));
      await tester.pump();

      expect(find.text('Select a camp.'), findsOneWidget);
      expect(capture.value, isNull);
    });

    testWidgets(
      'a fully valid form pops a Reservation and appends it to sampleReservations',
      (tester) async {
        final today = DateTime.now();
        final base = DateTime(today.year, today.month, today.day);
        final checkIn = base.add(const Duration(days: 40));
        final checkOut = base.add(const Duration(days: 42));

        final capture = await _pumpAddReservationHost(tester);

        await tester.enterText(
          find.byKey(const Key('guestNameField')),
          'Test Guest',
        );

        await tester.tap(find.byKey(const Key('campField')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mt. Daraitan campsite').last);
        await tester.pumpAndSettle();

        await _pickDate(tester, const Key('checkInField'), checkIn);
        await _pickDate(tester, const Key('checkOutField'), checkOut);

        await tester.tap(find.byKey(const Key('submitReservationButton')));
        await tester.pumpAndSettle();

        expect(capture.value, isNotNull);
        expect(capture.value!.guestName, 'Test Guest');
        expect(capture.value!.campName, 'Mt. Daraitan campsite');
        expect(capture.value!.startDate, checkIn);
        expect(capture.value!.endDate, checkOut);
        expect(capture.value!.status, ReservationStatus.confirmed);
        expect(sampleReservations, contains(capture.value));
      },
    );
  });
}
