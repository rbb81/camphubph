import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_notifications.dart';
import 'package:camper/models/app_notification.dart';
import 'package:camper/screens/notifications_screen.dart';

// Normally reached by tapping the bell icon on Home (see
// integration_test/home_test.dart). Pumped directly here so this screen
// also gets its own real-browser chromedriver smoke test, matching the
// pattern in integration_test/other_user_profile_test.dart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notifications (real browser)', () {
    late List<AppNotification> notificationsSnapshot;

    setUp(() {
      notificationsSnapshot = List.of(sampleNotifications);
    });

    tearDown(() {
      sampleNotifications
        ..clear()
        ..addAll(notificationsSnapshot);
    });

    testWidgets('renders the seeded notifications', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Carlo D.'), findsOneWidget);
      expect(find.textContaining('wants to follow you.'), findsWidgets);
    });

    testWidgets('accepting a follow request shows an Accepted chip', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const Key('acceptFollowRequestButton_notif_follow_carlo'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accepted'), findsOneWidget);
      expect(
        find.text("You accepted Carlo D.'s follow request."),
        findsOneWidget,
      );
    });

    testWidgets('tapping a like notification opens Post Details', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('notificationTile_notif_like_miguel')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Post'), findsOneWidget);
    });

    testWidgets('Mark all as read clears the unread indicators', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('markAllReadButton')));
      await tester.pumpAndSettle();

      expect(sampleNotifications.every((n) => n.isRead), isTrue);
    });
  });
}
