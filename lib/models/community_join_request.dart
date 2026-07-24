/// A pending request to join a private community, reviewed by a moderator.
/// No status field, unlike `AppNotification`'s follow-request chip or
/// `Reservation`'s status — nothing in this app needs to look back at
/// resolved join requests, so approving/declining just removes the request
/// from the canonical list (an ephemeral queue), matching Trip Planner's
/// Cancel Trip precedent rather than Notifications'/Reservations'.
class CommunityJoinRequest {
  const CommunityJoinRequest({
    required this.id,
    required this.communityId,
    required this.requesterName,
    required this.requesterInitials,
    required this.timeAgo,
  });

  final String id;
  final String communityId;
  final String requesterName;
  final String requesterInitials;
  final String timeAgo;
}
