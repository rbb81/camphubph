import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/data/sample_notifications.dart';
import 'package:camper/models/app_notification.dart';
import 'package:camper/screens/notifications_screen.dart';

Future<void> _pumpNotifications(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: NotificationsScreen()),
  );
}

void main() {
  late List<AppNotification> notificationsSnapshot;

  setUp(() {
    notificationsSnapshot = List.of(sampleNotifications);
  });

  tearDown(() {
    sampleNotifications
      ..clear()
      ..addAll(notificationsSnapshot);
  });

  group('NotificationsScreen', () {
    testWidgets('renders mixed read/unread rows', (tester) async {
      await _pumpNotifications(tester);

      expect(find.text('Carlo D.'), findsOneWidget);
      expect(find.text('Rico P.'), findsWidgets);
      expect(find.textContaining('wants to follow you.'), findsWidgets);
      expect(find.textContaining('liked your post.'), findsWidgets);
      expect(find.textContaining('commented:'), findsWidgets);
    });

    testWidgets('Accept flips a follow request to an Accepted chip', (
      tester,
    ) async {
      await _pumpNotifications(tester);

      final acceptButton = find.byKey(
        const Key('acceptFollowRequestButton_notif_follow_carlo'),
      );
      expect(acceptButton, findsOneWidget);

      await tester.tap(acceptButton);
      await tester.pump();

      expect(find.text('Accepted'), findsOneWidget);
      expect(
        find.text("You accepted Carlo D.'s follow request."),
        findsOneWidget,
      );
      expect(acceptButton, findsNothing);
    });

    testWidgets('Decline flips a follow request to a Declined chip', (
      tester,
    ) async {
      await _pumpNotifications(tester);

      final declineButton = find.byKey(
        const Key('declineFollowRequestButton_notif_follow_rico'),
      );
      expect(declineButton, findsOneWidget);

      await tester.tap(declineButton);
      await tester.pump();

      expect(find.text('Declined'), findsOneWidget);
      expect(
        find.text("You declined Rico P.'s follow request."),
        findsOneWidget,
      );
      expect(declineButton, findsNothing);
    });

    testWidgets('tapping a like notification marks it read and opens Post Details', (
      tester,
    ) async {
      await _pumpNotifications(tester);

      expect(
        sampleNotifications
            .firstWhere((n) => n.id == 'notif_like_miguel')
            .isRead,
        isFalse,
      );

      await tester.tap(
        find.byKey(const Key('notificationTile_notif_like_miguel')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Post'), findsOneWidget);
      expect(
        sampleNotifications
            .firstWhere((n) => n.id == 'notif_like_miguel')
            .isRead,
        isTrue,
      );
    });

    testWidgets('Mark all as read clears unread state', (tester) async {
      await _pumpNotifications(tester);

      expect(sampleNotifications.any((n) => !n.isRead), isTrue);

      await tester.tap(find.byKey(const Key('markAllReadButton')));
      await tester.pump();

      expect(sampleNotifications.every((n) => n.isRead), isTrue);
    });

    testWidgets('shows an empty state when there are no notifications', (
      tester,
    ) async {
      sampleNotifications.clear();
      await _pumpNotifications(tester);

      expect(find.text('No notifications yet.'), findsOneWidget);
    });
  });
}
