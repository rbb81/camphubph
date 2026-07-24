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
    this.followsMe = false,
  });

  final UserProfile profile;
  final FollowStatus followStatus;

  /// Whether this person follows the current user. The reverse of
  /// [followStatus] — there's no real follow graph in this app, so this
  /// is fixed seed data (see `sample_other_users.dart`) rather than a
  /// computed relationship.
  final bool followsMe;

  FollowableUser copyWith({FollowStatus? followStatus, bool? followsMe}) =>
      FollowableUser(
        profile: profile,
        followStatus: followStatus ?? this.followStatus,
        followsMe: followsMe ?? this.followsMe,
      );
}
