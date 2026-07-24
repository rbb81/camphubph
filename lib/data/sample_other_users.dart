import '../models/followable_user.dart';
import '../models/profile.dart';

/// Placeholder directory of other campers — covers everyone who currently
/// appears as a post author or suggested user in `sample_feed.dart`.
/// There's no `profiles`/`follows` schema in Supabase yet.
///
/// Mutated in place (entries replaced via `copyWith` when a follow status
/// changes), not copied-then-mutated — same shared-mutable-list pattern as
/// `sample_reservations.dart`/`sample_message_threads.dart`, since Home
/// Feed and Other User Profile are independently-pushed screens that both
/// need to see and update the same follow state.
///
/// `followsMe: true` seeds this app's Followers list (see
/// `follow_list_screen.dart`) — fixed data, not a computed relationship,
/// since there's no real reverse-follow graph.
final List<FollowableUser> sampleOtherUsers = [
  const FollowableUser(
    profile: UserProfile(
      name: 'Jasmine Reyes',
      initials: 'JR',
      bio: 'Chasing sunrise summits every chance I get.',
      experienceLevel: ExperienceLevel.expert,
      favoriteStyles: ['Mountain climbing', 'Backpacking'],
      followerCount: 1240,
      followingCount: 180,
    ),
    followsMe: true,
  ),
  const FollowableUser(
    profile: UserProfile(
      name: 'Miguel Ibarra',
      initials: 'MI',
      bio: 'Lakeside camping enthusiast. Always up for a crew trip.',
      experienceLevel: ExperienceLevel.intermediate,
      favoriteStyles: ['Car camping', 'Family camping'],
      followerCount: 340,
      followingCount: 210,
    ),
  ),
  const FollowableUser(
    profile: UserProfile(
      name: 'Ate Baby',
      initials: 'AB',
      bio: 'Runs Overlanding PH. Sharing trail conditions and routes.',
      experienceLevel: ExperienceLevel.expert,
      favoriteStyles: ['Overlanding'],
      followerCount: 5200,
      followingCount: 95,
    ),
    followsMe: true,
  ),
  const FollowableUser(
    profile: UserProfile(
      name: 'Rico P.',
      initials: 'RP',
      bio: 'Weekend warrior, mostly Batangas and Rizal trails.',
      experienceLevel: ExperienceLevel.intermediate,
      favoriteStyles: ['Car camping', 'Beach camping'],
      followerCount: 610,
      followingCount: 340,
    ),
    followsMe: true,
  ),
  const FollowableUser(
    profile: UserProfile(
      name: 'Carlo D.',
      initials: 'CD',
      bio: 'New to camping, learning as I go with my family.',
      experienceLevel: ExperienceLevel.beginner,
      favoriteStyles: ['Family camping'],
      followerCount: 42,
      followingCount: 88,
    ),
  ),
];
