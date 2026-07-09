enum NotificationType { followRequest, like, comment }

enum FollowRequestStatus { pending, accepted, declined }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.actorName,
    required this.actorInitials,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.postId,
    this.followRequestStatus,
  });

  final String id;
  final NotificationType type;
  final String actorName;
  final String actorInitials;
  final String message;
  final String timeAgo;
  final bool isRead;
  final String? postId;
  final FollowRequestStatus? followRequestStatus;

  AppNotification copyWith({
    bool? isRead,
    FollowRequestStatus? followRequestStatus,
  }) => AppNotification(
    id: id,
    type: type,
    actorName: actorName,
    actorInitials: actorInitials,
    message: message,
    timeAgo: timeAgo,
    isRead: isRead ?? this.isRead,
    postId: postId,
    followRequestStatus: followRequestStatus ?? this.followRequestStatus,
  );
}
