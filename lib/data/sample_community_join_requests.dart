import '../models/community_join_request.dart';

/// Pending join requests for private communities, keyed by `Community.id`.
/// Shared mutable list, same pattern as `sampleReservations` — mutated in
/// place (removed on approve/decline) rather than copied-then-mutated,
/// since `CommunityFeedScreen` (for a pending-count badge) and
/// `PendingJoinRequestsScreen` (for review) are independently-pushed
/// screens that both need to see/update the same canonical queue.
/// Requester names/initials are copied as plain strings (not
/// `FollowableUser` references), matching `sample_community_posts.dart`'s
/// existing convention for author identity.
final List<CommunityJoinRequest> sampleCommunityJoinRequests = [
  const CommunityJoinRequest(
    id: 'jr1',
    communityId: 'bicol-volcano-trekkers',
    requesterName: 'Carlo D.',
    requesterInitials: 'CD',
    timeAgo: '2h',
  ),
  const CommunityJoinRequest(
    id: 'jr2',
    communityId: 'bicol-volcano-trekkers',
    requesterName: 'Ate Baby',
    requesterInitials: 'AB',
    timeAgo: '1d',
  ),
];
