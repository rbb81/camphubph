import '../models/community_post.dart';

/// Placeholder community posts, keyed by `Community.id`. There's no
/// `community_posts` schema in Supabase yet — see docs/ux/wireframes.md
/// "Community Feed" section. `batangas-beach-campers` is intentionally left
/// without posts to exercise the empty state.
final List<CommunityFeedPost> sampleCommunityPosts = [
  const CommunityFeedPost(
    id: 'cp1',
    communityId: 'luzon-overlanders',
    authorName: 'Rico Fernandez',
    authorInitials: 'RF',
    timeAgo: '3d',
    body:
        'Reminder: tag your trip reports with route + vehicle type so the '
        'search stays useful for everyone. Thanks for keeping this group '
        'organized!',
    likeCount: 42,
    commentCount: 5,
    isPinned: true,
    isModerator: true,
  ),
  const CommunityFeedPost(
    id: 'cp2',
    communityId: 'luzon-overlanders',
    authorName: 'Miguel Ibarra',
    authorInitials: 'MI',
    timeAgo: '5h',
    body:
        'Ran the Tanay-Daraitan loop yesterday in a stock Vitara — doable but '
        'the last river crossing needs a snorkel if it rains upstream.',
    likeCount: 18,
    commentCount: 3,
  ),
  const CommunityFeedPost(
    id: 'cp3',
    communityId: 'luzon-overlanders',
    authorName: 'Ana Dela Cruz',
    authorInitials: 'AD',
    timeAgo: '1d',
    body: 'Anyone have a good recovery gear checklist for beginners?',
    likeCount: 9,
    commentCount: 7,
  ),
  const CommunityFeedPost(
    id: 'cp4',
    communityId: 'trail-runners-ph',
    authorName: 'Carla Mendoza',
    authorInitials: 'CM',
    timeAgo: '2d',
    body:
        'Race promo posts go in the pinned megathread only from now on — '
        'keeps the main feed focused on routes and conditions.',
    likeCount: 27,
    commentCount: 2,
    isPinned: true,
    isModerator: true,
  ),
  const CommunityFeedPost(
    id: 'cp5',
    communityId: 'trail-runners-ph',
    authorName: 'Bea Villanueva',
    authorInitials: 'BV',
    timeAgo: '6h',
    body:
        'Masungi trail was in great shape this weekend, +900m gain over '
        '8km. Bring more water than you think you need.',
    likeCount: 31,
    commentCount: 4,
  ),
];
