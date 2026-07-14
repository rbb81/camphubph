import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/sample_camps.dart';
import '../data/sample_feed.dart';
import '../data/sample_message_threads.dart';
import '../data/sample_other_users.dart';
import '../data/sample_profile.dart';
import '../data/sample_reviews.dart';
import '../models/camp.dart';
import '../models/followable_user.dart';
import '../models/home_feed_item.dart';
import '../models/message_thread.dart';
import '../models/profile.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';
import 'message_thread_screen.dart';
import 'post_details_screen.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({super.key, required this.user});

  final FollowableUser user;

  @override
  State<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _tabLabels = ['Posts', 'Photos', 'Reviews'];

  late final TabController _tabController;
  late FollowableUser _user;
  late List<FriendPostItem> _posts;
  late List<Review> _reviews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _user = widget.user;
    _syncContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncContent() {
    _posts = sampleHomeFeed
        .whereType<FriendPostItem>()
        .where((p) => p.authorName == _user.profile.name)
        .toList();
    _reviews = sampleReviews
        .where((r) => r.authorName == _user.profile.name)
        .toList();
  }

  void _setStatus(FollowStatus status) {
    final index = sampleOtherUsers.indexWhere(
      (u) => u.profile.name == _user.profile.name,
    );
    final updated = _user.copyWith(followStatus: status);
    if (index != -1) sampleOtherUsers[index] = updated;
    setState(() => _user = updated);
  }

  void _toggleFollow() {
    switch (_user.followStatus) {
      case FollowStatus.notFollowing:
        _setStatus(FollowStatus.requested);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Follow request sent to ${_user.profile.name}')),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          if (_user.followStatus != FollowStatus.requested) return;
          _setStatus(FollowStatus.following);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_user.profile.name} accepted your follow request.'),
            ),
          );
        });
      case FollowStatus.requested:
        _setStatus(FollowStatus.notFollowing);
      case FollowStatus.following:
        _setStatus(FollowStatus.notFollowing);
    }
  }

  Future<void> _message() async {
    final myName = sampleProfile.name;
    final otherName = _user.profile.name;
    final thread = sampleMessageThreads.firstWhere(
      (t) =>
          t.campId == null &&
          ((t.participantA == myName && t.participantB == otherName) ||
              (t.participantA == otherName && t.participantB == myName)),
      orElse: () {
        final created = MessageThread(
          id: 'thread_${DateTime.now().microsecondsSinceEpoch}',
          participantA: myName,
          participantB: otherName,
          messages: const [],
        );
        sampleMessageThreads.add(created);
        return created;
      },
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageThreadScreen(thread: thread, viewerName: myName),
      ),
    );
  }

  Future<void> _openPost(FriendPostItem post) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailsScreen(post: post, currentUser: sampleProfile),
      ),
    );
  }

  void _openCamp(String campId, String fallbackName) {
    final camp = sampleCamps.firstWhere(
      (c) => c.id == campId,
      orElse: () => Camp(
        id: campId,
        name: fallbackName,
        location: '',
        categories: const [],
        rating: 0,
        reviewCount: 0,
        distanceKm: 0,
        priceLevel: 1,
        description: 'No description available yet for this camp.',
        coordinates: const LatLng(12.8797, 121.7740),
      ),
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: camp)));
  }

  String _followLabel() => switch (_user.followStatus) {
    FollowStatus.notFollowing => 'Follow',
    FollowStatus.requested => 'Requested',
    FollowStatus.following => 'Following',
  };

  @override
  Widget build(BuildContext context) {
    final profile = _user.profile;

    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PostsTab(posts: _posts, onOpenPost: _openPost),
                      _PhotosTab(posts: _posts, reviews: _reviews),
                      _ReviewsTab(reviews: _reviews, onOpenCamp: _openCamp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final profile = _user.profile;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(initials: profile.initials),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    _ExperienceBadge(level: profile.experienceLevel),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(profile.bio),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final style in profile.favoriteStyles)
                _StyleTag(label: style),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatColumn(
                key: const Key('followerCountStat'),
                value: profile.followerCount,
                label: 'Followers',
              ),
              const SizedBox(width: 24),
              _StatColumn(
                key: const Key('followingCountStat'),
                value: profile.followingCount,
                label: 'Following',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _user.followStatus == FollowStatus.following
                    ? OutlinedButton(
                        key: const Key('followButton'),
                        onPressed: _toggleFollow,
                        child: Text(_followLabel()),
                      )
                    : FilledButton(
                        key: const Key('followButton'),
                        onPressed: _toggleFollow,
                        child: Text(_followLabel()),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('messageUserButton'),
                  onPressed: _message,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.posts, required this.onOpenPost});

  final List<FriendPostItem> posts;
  final ValueChanged<FriendPostItem> onOpenPost;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Text('No posts yet.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final post in posts) ...[
          _PostCard(post: post, onTap: () => onOpenPost(post)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onTap});

  final FriendPostItem post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${post.location} · ${post.timeAgo}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.caption),
            if (post.photoBytes != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  post.photoBytes!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.posts, required this.reviews});

  final List<FriendPostItem> posts;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final photos = [
      for (final post in posts)
        if (post.photoBytes != null) post.photoBytes!,
      for (final review in reviews)
        if (review.photoBytes != null) review.photoBytes!,
    ];
    if (photos.isEmpty) {
      return const Center(
        child: Text('No photos yet.', style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(photos[index], fit: BoxFit.cover),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews, required this.onOpenCamp});

  final List<Review> reviews;
  final void Function(String campId, String fallbackName) onOpenCamp;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final review in reviews) _ReviewCard(review: review, onOpenCamp: onOpenCamp),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onOpenCamp});

  final Review review;
  final void Function(String campId, String fallbackName) onOpenCamp;

  String _campName() => sampleCamps
      .firstWhere(
        (c) => c.id == review.campId,
        orElse: () => Camp(
          id: review.campId,
          name: review.campId,
          location: '',
          categories: const [],
          rating: 0,
          reviewCount: 0,
          distanceKm: 0,
          priceLevel: 1,
          description: '',
          coordinates: const LatLng(12.8797, 121.7740),
        ),
      )
      .name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campName = _campName();

    return Container(
      key: Key('reviewCard_${review.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onOpenCamp(review.campId, campName),
                  child: Text(
                    campName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: AppColors.gold,
                    ),
                ],
              ),
            ],
          ),
          Text(
            'Visited ${review.visitDate.year}-${review.visitDate.month.toString().padLeft(2, '0')} · ${review.postedAgo}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          if (review.tip != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: 16,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(review.tip!)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    return CircleAvatar(
      radius: 32,
      backgroundColor: accent.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: accent,
        ),
      ),
    );
  }
}

class _ExperienceBadge extends StatelessWidget {
  const _ExperienceBadge({required this.level});

  final ExperienceLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${level.label} camper',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
}

class _StyleTag extends StatelessWidget {
  const _StyleTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceMutedDark
            : AppColors.surfaceMutedLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
