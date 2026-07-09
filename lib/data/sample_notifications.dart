import '../models/app_notification.dart';

/// Placeholder Notifications feed. There's no `notifications` schema in
/// Supabase yet, so these are fabricated the same way `sample_reviews.dart`/
/// `sample_other_users.dart` fabricate cross-camper activity, not generated
/// live from real likes/comments during the current session.
///
/// Shared mutable list, mutated in place (entries replaced via `copyWith`
/// when a follow request is accepted/declined or a notification is marked
/// read) — same pattern as `sample_reservations.dart`/`sample_trips.dart`,
/// since Home (for the unread badge) and Notifications independently read
/// and write this list.
///
/// Follow-request notifications model the CURRENT USER being asked to be
/// followed — the reverse direction from `FollowStatus`/`sampleOtherUsers`,
/// which only track who the current user follows. Resolving one here does
/// not touch `sampleOtherUsers`.
final List<AppNotification> sampleNotifications = [
  const AppNotification(
    id: 'notif_follow_carlo',
    type: NotificationType.followRequest,
    actorName: 'Carlo D.',
    actorInitials: 'CD',
    message: 'wants to follow you.',
    timeAgo: '10m ago',
    followRequestStatus: FollowRequestStatus.pending,
  ),
  const AppNotification(
    id: 'notif_follow_rico',
    type: NotificationType.followRequest,
    actorName: 'Rico P.',
    actorInitials: 'RP',
    message: 'wants to follow you.',
    timeAgo: '1h ago',
    followRequestStatus: FollowRequestStatus.pending,
  ),
  const AppNotification(
    id: 'notif_like_miguel',
    type: NotificationType.like,
    actorName: 'Miguel Ibarra',
    actorInitials: 'MI',
    message: 'liked your post.',
    timeAgo: '30m ago',
    postId: 'post_ana_daraitan',
  ),
  const AppNotification(
    id: 'notif_like_jasmine',
    type: NotificationType.like,
    actorName: 'Jasmine Reyes',
    actorInitials: 'JR',
    message: 'liked your post.',
    timeAgo: '3h ago',
    isRead: true,
    postId: 'post_ana_daraitan',
  ),
  const AppNotification(
    id: 'notif_comment_rico',
    type: NotificationType.comment,
    actorName: 'Rico P.',
    actorInitials: 'RP',
    message:
        'commented: "Taal Lake is criminally underrated for camping, but Daraitan is a classic too."',
    timeAgo: '5h ago',
    isRead: true,
    postId: 'post_ana_daraitan',
  ),
  const AppNotification(
    id: 'notif_comment_ate_baby',
    type: NotificationType.comment,
    actorName: 'Ate Baby',
    actorInitials: 'AB',
    message: 'commented: "Miss this trail! Who was your guide this time?"',
    timeAgo: '1d ago',
    postId: 'post_ana_daraitan',
  ),
];
