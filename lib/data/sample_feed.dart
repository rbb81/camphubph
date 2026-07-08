import '../models/comment.dart';
import '../models/home_feed_item.dart';

/// Placeholder Home Feed content. There's no posts/camps schema in Supabase
/// yet, so this stands in for what the real feed query will eventually
/// return — see docs/ux/wireframes.md for the Home Feed content mix.
final List<HomeFeedItem> sampleHomeFeed = [
  const FriendPostItem(
    authorName: 'Jasmine Reyes',
    authorInitials: 'JR',
    timeAgo: '2h',
    location: 'Batangas Ridge',
    caption:
        'Perfect weather for a weekend climb — made it to the summit just in time for sunrise.',
    likeCount: 24,
    commentCount: 2,
    comments: [
      Comment(
        authorName: 'Miguel Ibarra',
        authorInitials: 'MI',
        text: 'That sunrise shot is unreal, where exactly is this?',
        timeAgo: '1h',
      ),
      Comment(
        authorName: 'Ate Baby',
        authorInitials: 'AB',
        text: 'Adding this to the wishlist immediately.',
        timeAgo: '45m',
      ),
    ],
  ),
  const RecommendedCampItem(
    name: 'Mt. Daraitan campsite',
    location: 'Tanay, Rizal',
    rating: 4.6,
    distanceKm: 62,
  ),
  const CommunityPostItem(
    communityName: 'Overlanding PH',
    authorName: 'Rico P.',
    snippet:
        'Trail conditions at Nasugbu after the rain — still passable, some mud near the river crossing.',
  ),
  const TipItem(
    'Pack a dry bag for river crossings — even a light drizzle can turn a trail muddy fast this time of year.',
  ),
  const FriendPostItem(
    authorName: 'Miguel Ibarra',
    authorInitials: 'MI',
    timeAgo: '5h',
    location: 'Taal Lake',
    caption: 'Finally tried camping by the lake with the whole crew. 10/10, would recommend.',
    likeCount: 41,
    commentCount: 1,
    comments: [
      Comment(
        authorName: 'Rico P.',
        authorInitials: 'RP',
        text: 'Taal Lake is criminally underrated for camping.',
        timeAgo: '3h',
      ),
    ],
  ),
  const RecommendedCampItem(
    name: 'Nasugbu beach camp',
    location: 'Nasugbu, Batangas',
    rating: 4.3,
    distanceKm: 105,
  ),
  const SuggestedUserItem(
    name: 'Ate Baby',
    initials: 'AB',
    subtitle: 'Runs Overlanding PH · 5.2k followers',
  ),
  const CommunityPostItem(
    communityName: 'Beginner Campers',
    authorName: 'Carlo D.',
    snippet: 'First time camping next weekend — any tips for a family with two kids?',
  ),
];
