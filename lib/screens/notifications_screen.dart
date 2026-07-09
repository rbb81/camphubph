import 'package:flutter/material.dart';

import '../data/sample_feed.dart';
import '../data/sample_notifications.dart';
import '../data/sample_profile.dart';
import '../models/app_notification.dart';
import '../models/home_feed_item.dart';
import '../theme/app_theme.dart';
import 'post_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications = List.of(sampleNotifications);

  FriendPostItem? _findPost(String? postId) {
    if (postId == null) return null;
    for (final item in sampleHomeFeed) {
      if (item is FriendPostItem && item.id == postId) return item;
    }
    return null;
  }

  void _markRead(AppNotification notification) {
    if (notification.isRead) return;
    final index = sampleNotifications.indexWhere(
      (n) => n.id == notification.id,
    );
    if (index == -1) return;
    sampleNotifications[index] = sampleNotifications[index].copyWith(
      isRead: true,
    );
    setState(() => _notifications = List.of(sampleNotifications));
  }

  void _markAllRead() {
    for (var i = 0; i < sampleNotifications.length; i++) {
      if (!sampleNotifications[i].isRead) {
        sampleNotifications[i] = sampleNotifications[i].copyWith(
          isRead: true,
        );
      }
    }
    setState(() => _notifications = List.of(sampleNotifications));
  }

  void _resolveFollowRequest(AppNotification notification, FollowRequestStatus status) {
    final index = sampleNotifications.indexWhere(
      (n) => n.id == notification.id,
    );
    if (index == -1) return;
    sampleNotifications[index] = sampleNotifications[index].copyWith(
      isRead: true,
      followRequestStatus: status,
    );
    setState(() => _notifications = List.of(sampleNotifications));

    final verb = status == FollowRequestStatus.accepted
        ? 'accepted'
        : 'declined';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You $verb ${notification.actorName}'s follow request.")),
    );
  }

  Future<void> _openTarget(AppNotification notification) async {
    _markRead(notification);
    final post = _findPost(notification.postId);
    if (post == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This post is no longer available.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailsScreen(post: post, currentUser: sampleProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            key: const Key('markAllReadButton'),
            onPressed: _notifications.any((n) => !n.isRead) ? _markAllRead : null,
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _notifications.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: notification.type == NotificationType.followRequest
                            ? null
                            : () => _openTarget(notification),
                        onAccept: () => _resolveFollowRequest(
                          notification,
                          FollowRequestStatus.accepted,
                        ),
                        onDecline: () => _resolveFollowRequest(
                          notification,
                          FollowRequestStatus.declined,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No notifications yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  IconData get _typeIcon => switch (notification.type) {
    NotificationType.followRequest => Icons.person_add_alt,
    NotificationType.like => Icons.favorite,
    NotificationType.comment => Icons.mode_comment_outlined,
  };

  Color _typeIconColor(Color accent) => switch (notification.type) {
    NotificationType.followRequest => accent,
    NotificationType.like => Colors.red,
    NotificationType.comment => accent,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    final isUnread = !notification.isRead;

    return InkWell(
      key: Key('notificationTile_${notification.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? accent.withValues(alpha: 0.08)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Text(
                    notification.actorInitials,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: accent,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _typeIcon,
                      size: 12,
                      color: _typeIconColor(accent),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.actorName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(notification.message),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  if (notification.type == NotificationType.followRequest)
                    _FollowRequestAction(
                      notification: notification,
                      onAccept: onAccept,
                      onDecline: onDecline,
                    ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _FollowRequestAction extends StatelessWidget {
  const _FollowRequestAction({
    required this.notification,
    required this.onAccept,
    required this.onDecline,
  });

  final AppNotification notification;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final status = notification.followRequestStatus ?? FollowRequestStatus.pending;

    if (status != FollowRequestStatus.pending) {
      final isAccepted = status == FollowRequestStatus.accepted;
      final color = isAccepted ? AppColors.brand : AppColors.danger;
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Chip(
          label: Text(isAccepted ? 'Accepted' : 'Declined'),
          backgroundColor: color.withValues(alpha: 0.12),
          labelStyle: TextStyle(color: color, fontSize: 12),
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              key: Key('acceptFollowRequestButton_${notification.id}'),
              onPressed: onAccept,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accept'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              key: Key('declineFollowRequestButton_${notification.id}'),
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Decline'),
            ),
          ),
        ],
      ),
    );
  }
}
