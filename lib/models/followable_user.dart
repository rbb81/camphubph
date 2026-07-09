import 'profile.dart';

enum FollowStatus { notFollowing, requested, following }

/// Another camper's profile, as viewed from the current user's
/// perspective. Wraps a [UserProfile] with the follow relationship, since
/// that relationship belongs to the (camper, otherUser) pair rather than
/// to the profile itself.
class FollowableUser {
  const FollowableUser({
    required this.profile,
    this.followStatus = FollowStatus.notFollowing,
  });

  final UserProfile profile;
  final FollowStatus followStatus;

  FollowableUser copyWith({FollowStatus? followStatus}) => FollowableUser(
    profile: profile,
    followStatus: followStatus ?? this.followStatus,
  );
}
