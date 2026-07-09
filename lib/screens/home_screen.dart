import 'package:flutter/material.dart';
import '../data/sample_camps.dart';
import '../data/sample_communities.dart';
import '../data/sample_feed.dart';
import '../data/sample_profile.dart';
import '../models/camp.dart';
import '../models/community.dart';
import '../models/home_feed_item.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';
import 'community_feed_screen.dart';
import 'create_post_screen.dart';
import 'post_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<HomeFeedItem> _feed = List.of(sampleHomeFeed);

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
    );
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
      ),
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: camp)));
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
            icon: const Icon(Icons.search),
            onPressed: () => _comingSoon('Search'),
          ),
          IconButton(
            key: const Key('notificationsButton'),
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _comingSoon('Notifications'),
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
          const labels = ['Home', 'Discover', 'Map', 'Communities', 'Profile'];
          if (index == 1) {
            Navigator.of(context).pushNamed('/discover');
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
          if (index != 0) _comingSoon(labels[index]);
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
      SuggestedUserItem() => _SuggestedUserCard(item: item),
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
  });

  final FriendPostItem item;
  final VoidCallback onLike;
  final VoidCallback onOpenPost;

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
            Row(
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
            const SizedBox(height: 10),
            Text(item.caption),
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
  const _SuggestedUserCard({required this.item});

  final SuggestedUserItem item;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          _Avatar(item.initials),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Following ${item.name}')),
              );
            },
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}
