import 'package:flutter/material.dart';
import '../data/sample_feed.dart';
import '../models/home_feed_item.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
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
              itemCount: sampleHomeFeed.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildFeedCard(context, sampleHomeFeed[index]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('createPostButton'),
        onPressed: () => _comingSoon('Create post'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          const labels = ['Home', 'Discover', 'Map', 'Communities', 'Profile'];
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

  Widget _buildFeedCard(BuildContext context, HomeFeedItem item) {
    return switch (item) {
      FriendPostItem() => _FriendPostCard(item: item),
      RecommendedCampItem() => _RecommendedCampCard(item: item),
      CommunityPostItem() => _CommunityPostCard(item: item),
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
          ? AppColors.forestDark.withValues(alpha: 0.25)
          : AppColors.forest.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: isDark ? AppColors.forestDark : AppColors.forest,
        ),
      ),
    );
  }
}

class _FriendPostCard extends StatelessWidget {
  const _FriendPostCard({required this.item});

  final FriendPostItem item;

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 18),
              const SizedBox(width: 4),
              Text('${item.likeCount}'),
              const SizedBox(width: 16),
              const Icon(Icons.mode_comment_outlined, size: 18),
              const SizedBox(width: 4),
              Text('${item.commentCount}'),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 18),
              const SizedBox(width: 12),
              const Icon(Icons.bookmark_border, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedCampCard extends StatelessWidget {
  const _RecommendedCampCard({required this.item});

  final RecommendedCampItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _Card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.forestDark.withValues(alpha: 0.2)
                  : AppColors.forest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.terrain,
              color: isDark ? AppColors.forestDark : AppColors.forest,
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
              const Icon(Icons.star, size: 16, color: AppColors.ember),
              const SizedBox(width: 2),
              Text(item.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.item});

  final CommunityPostItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.forestDark : AppColors.forest;

    return _Card(
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
          const Icon(Icons.tips_and_updates_outlined, color: AppColors.ember),
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
