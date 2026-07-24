import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../data/sample_camps.dart';
import '../data/sample_communities.dart';
import '../data/sample_feed.dart';
import '../data/sample_notifications.dart';
import '../data/sample_other_users.dart';
import '../data/sample_profile.dart';
import '../models/camp.dart';
import '../models/community.dart';
import '../models/followable_user.dart';
import '../models/home_feed_item.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../widgets/hashtag_mention_text.dart';
import 'camp_details_screen.dart';
import 'community_feed_screen.dart';
import 'create_post_screen.dart';
import 'notifications_screen.dart';
import 'other_user_profile_screen.dart';
import 'post_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<HomeFeedItem> _feed = List.of(sampleHomeFeed);

  int get _unreadNotificationCount =>
      sampleNotifications.where((n) => !n.isRead).length;

  Future<void> _openNotifications() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _createPost() async {
    final post = await Navigator.of(context).push<FriendPostItem>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(author: sampleProfile),
      ),
    );
    if (post != null) {
      setState(() => _feed.insert(0, post));
    }
  }

  void _toggleLike(int index, FriendPostItem item) {
    setState(() {
      _feed[index] = item.copyWith(
        isLiked: !item.isLiked,
        likeCount: item.isLiked ? item.likeCount - 1 : item.likeCount + 1,
      );
    });
  }

  Future<void> _openPost(int index, FriendPostItem item) async {
    final updated = await Navigator.of(context).push<FriendPostItem>(
      MaterialPageRoute(
        builder: (_) =>
            PostDetailsScreen(post: item, currentUser: sampleProfile),
      ),
    );
    if (updated != null) {
      setState(() => _feed[index] = updated);
    }
  }

  void _openCamp(RecommendedCampItem item) {
    final camp = sampleCamps.firstWhere(
      (c) => c.name == item.name,
      orElse: () => Camp(
        id: item.name,
        name: item.name,
        location: item.location,
        categories: const ['Camping Grounds'],
        rating: item.rating,
        reviewCount: 0,
        distanceKm: item.distanceKm,
        priceLevel: 1,
        description: 'No description available yet for this camp.',
        coordinates: const LatLng(12.8797, 121.7740),
      ),
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: camp)));
  }

  void _openUserProfile(String name, String initials) {
    final user = sampleOtherUsers.firstWhere(
      (u) => u.profile.name == name,
      orElse: () => FollowableUser(
        profile: UserProfile(
          name: name,
          initials: initials,
          bio: '',
          experienceLevel: ExperienceLevel.beginner,
          favoriteStyles: const [],
          followerCount: 0,
          followingCount: 0,
        ),
      ),
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: user)));
  }

  void _toggleFollowFromSuggestion(SuggestedUserItem item) {
    final index = sampleOtherUsers.indexWhere(
      (u) => u.profile.name == item.name,
    );
    if (index == -1) return;
    final current = sampleOtherUsers[index];

    if (current.followStatus != FollowStatus.notFollowing) {
      setState(
        () => sampleOtherUsers[index] = current.copyWith(
          followStatus: FollowStatus.notFollowing,
        ),
      );
      return;
    }

    setState(
      () => sampleOtherUsers[index] = current.copyWith(
        followStatus: FollowStatus.requested,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Follow request sent to ${item.name}')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final i = sampleOtherUsers.indexWhere(
        (u) => u.profile.name == item.name,
      );
      if (i == -1 || sampleOtherUsers[i].followStatus != FollowStatus.requested) {
        return;
      }
      setState(
        () => sampleOtherUsers[i] = sampleOtherUsers[i].copyWith(
          followStatus: FollowStatus.following,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} accepted your follow request.'),
        ),
      );
    });
  }

  void _openCommunity(CommunityPostItem item) {
    final community = sampleCommunities.firstWhere(
      (c) => c.name == item.communityName,
      orElse: () => Community(
        id: item.communityName,
        name: item.communityName,
        description: '',
        icon: Icons.groups_outlined,
        memberCount: 0,
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CommunityFeedScreen(community: community)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camper'),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('searchButton'),
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            key: const Key('notificationsButton'),
            tooltip: 'Notifications',
            icon: Badge(
              label: Text('$_unreadNotificationCount'),
              isLabelVisible: _unreadNotificationCount > 0,
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: _openNotifications,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _feed.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildFeedCard(context, index, _feed[index]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('createPostButton'),
        tooltip: 'Create post',
        onPressed: _createPost,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed('/discover');
            return;
          }
          if (index == 2) {
            Navigator.of(context).pushNamed('/map');
            return;
          }
          if (index == 3) {
            Navigator.of(context).pushNamed('/communities');
            return;
          }
          if (index == 4) {
            Navigator.of(context).pushNamed('/profile');
            return;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Communities'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context, int index, HomeFeedItem item) {
    return switch (item) {
      FriendPostItem() => _FriendPostCard(
        item: item,
        onLike: () => _toggleLike(index, item),
        onOpenPost: () => _openPost(index, item),
        onTapAuthor: () => _openUserProfile(item.authorName, item.authorInitials),
      ),
      RecommendedCampItem() => _RecommendedCampCard(
        item: item,
        onTap: () => _openCamp(item),
      ),
      CommunityPostItem() => _CommunityPostCard(
        item: item,
        onTap: () => _openCommunity(item),
      ),
      TipItem() => _TipCard(item: item),
      SuggestedUserItem() => _SuggestedUserCard(
        item: item,
        onTapUser: () => _openUserProfile(item.name, item.initials),
        onToggleFollow: () => _toggleFollowFromSuggestion(item),
      ),
    };
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.initials);

  final String initials;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: 18,
      backgroundColor: isDark
          ? AppColors.brandDark.withValues(alpha: 0.25)
          : AppColors.brand.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: isDark ? AppColors.brandDark : AppColors.brand,
        ),
      ),
    );
  }
}

class _FriendPostCard extends StatelessWidget {
  const _FriendPostCard({
    required this.item,
    required this.onLike,
    required this.onOpenPost,
    required this.onTapAuthor,
  });

  final FriendPostItem item;
  final VoidCallback onLike;
  final VoidCallback onOpenPost;
  final VoidCallback onTapAuthor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('friendPostCard'),
      onTap: onOpenPost,
      borderRadius: BorderRadius.circular(12),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              key: const Key('friendPostAuthorTap'),
              onTap: onTapAuthor,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  _Avatar(item.authorInitials),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${item.location} · ${item.timeAgo}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            HashtagMentionText(
              item.caption,
              onHashtagTap: (tag) => openHashtagSearch(context, tag),
              onMentionTap: (handle) => openMentionedProfile(context, handle),
            ),
            if (item.photoBytes != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  item.photoBytes!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                InkWell(
                  key: const Key('likeButton'),
                  onTap: onLike,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      item.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: item.isLiked ? Colors.red : null,
                    ),
                  ),
                ),
                Text('${item.likeCount}'),
                const SizedBox(width: 12),
                InkWell(
                  key: const Key('commentButton'),
                  onTap: onOpenPost,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.mode_comment_outlined, size: 18),
                  ),
                ),
                Text('${item.commentCount}'),
                const Spacer(),
                const Icon(Icons.share_outlined, size: 18),
                const SizedBox(width: 12),
                const Icon(Icons.bookmark_border, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCampCard extends StatelessWidget {
  const _RecommendedCampCard({required this.item, required this.onTap});

  final RecommendedCampItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      key: const Key('recommendedCampCard'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: _Card(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.brandDark.withValues(alpha: 0.2)
                    : AppColors.brand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.terrain,
                color: isDark ? AppColors.brandDark : AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended near you',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('${item.location} · ${item.distanceKm.toStringAsFixed(0)} km away'),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.gold),
                const SizedBox(width: 2),
                Text(item.rating.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.item, required this.onTap});

  final CommunityPostItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;

    return InkWell(
      key: const Key('communityPostCard'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined, size: 16, color: accent),
                const SizedBox(width: 6),
                Text(
                  '${item.communityName} · ${item.authorName}',
                  style: TextStyle(fontWeight: FontWeight.w500, color: accent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.snippet),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.item});

  final TipItem item;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(item.tip)),
        ],
      ),
    );
  }
}

class _SuggestedUserCard extends StatelessWidget {
  const _SuggestedUserCard({
    required this.item,
    required this.onTapUser,
    required this.onToggleFollow,
  });

  final SuggestedUserItem item;
  final VoidCallback onTapUser;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final followStatus = sampleOtherUsers
        .firstWhere(
          (u) => u.profile.name == item.name,
          orElse: () => FollowableUser(
            profile: UserProfile(
              name: item.name,
              initials: item.initials,
              bio: '',
              experienceLevel: ExperienceLevel.beginner,
              favoriteStyles: const [],
              followerCount: 0,
              followingCount: 0,
            ),
          ),
        )
        .followStatus;
    final label = switch (followStatus) {
      FollowStatus.notFollowing => 'Follow',
      FollowStatus.requested => 'Requested',
      FollowStatus.following => 'Following',
    };

    return _Card(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: const Key('suggestedUserTap'),
              onTap: onTapUser,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  _Avatar(item.initials),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          item.subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            key: const Key('suggestedUserFollowButton'),
            onPressed: onToggleFollow,
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
