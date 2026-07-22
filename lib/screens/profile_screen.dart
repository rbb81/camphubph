import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../data/sample_camps.dart';
import '../data/sample_profile.dart';
import '../models/camp.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_item_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _tabLabels = [
    'Posts',
    'Photos',
    'Reviews',
    'Saved Camps',
    'Wishlist',
    'Completed Trips',
  ];

  late final TabController _tabController;
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _profile = sampleProfile;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );
    if (result != null) {
      setState(() => _profile = result);
    }
  }

  void _openPost(ProfilePostItem post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSimpleDetailScreen(
          appBarTitle: 'Post',
          primaryText: post.caption,
          secondaryText: post.timeAgo,
        ),
      ),
    );
  }

  void _openPhoto(ProfilePhotoItem photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSimpleDetailScreen(
          appBarTitle: 'Photo',
          primaryText: photo.caption,
          placeholderIcon: Icons.photo_outlined,
        ),
      ),
    );
  }

  void _openReview(ProfileReviewItem review) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: review)),
    );
  }

  void _openCampByName(String name, String location) {
    final camp = sampleCamps.firstWhere(
      (c) => c.name == name,
      orElse: () => Camp(
        id: name,
        name: name,
        location: location,
        categories: const ['Camping Grounds'],
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

  void _openCompletedTrip(ProfileCompletedTripItem trip) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CompletedTripDetailScreen(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                        _PostsTab(items: sampleProfilePosts, onTap: _openPost),
                        _PhotosTab(
                          items: sampleProfilePhotos,
                          onTap: _openPhoto,
                        ),
                        _ReviewsTab(
                          items: sampleProfileReviews,
                          onTap: _openReview,
                        ),
                        _SavedCampsTab(
                          items: sampleSavedCamps,
                          onTap: (item) =>
                              _openCampByName(item.name, item.location),
                        ),
                        _WishlistTab(
                          items: sampleWishlist,
                          onTap: (item) =>
                              _openCampByName(item.name, item.location),
                        ),
                        _CompletedTripsTab(
                          items: sampleCompletedTrips,
                          onTap: _openCompletedTrip,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 204,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.brandStrong : AppColors.brand,
                  image: _profile.coverBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_profile.coverBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  bottom: false,
                  child: IconButton(
                    key: const Key('backButton'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  bottom: false,
                  child: IconButton(
                    key: const Key('settingsButton'),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () => _comingSoon('Settings'),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 16,
                child: _ProfileAvatar(
                  initials: _profile.initials,
                  imageBytes: _profile.avatarBytes,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(_profile.bio, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              _ExperienceBadge(level: _profile.experienceLevel),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final style in _profile.favoriteStyles)
                    _StyleTag(label: style),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatColumn(
                    key: const Key('followerStat'),
                    count: _profile.followerCount,
                    label: 'Followers',
                    onTap: () => _comingSoon('Followers list'),
                  ),
                  const SizedBox(width: 24),
                  _StatColumn(
                    key: const Key('followingStat'),
                    count: _profile.followingCount,
                    label: 'Following',
                    onTap: () => _comingSoon('Following list'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('editProfileButton'),
                      onPressed: _openEditProfile,
                      style: OutlinedButton.styleFrom(foregroundColor: accent),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('tripPlannerButton'),
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/trips'),
                      icon: const Icon(Icons.card_travel),
                      label: const Text('Trip Planner'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials, this.imageBytes});

  final String initials;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 44,
        backgroundColor: isDark
            ? AppColors.brandDark.withValues(alpha: 0.25)
            : AppColors.brand.withValues(alpha: 0.12),
        backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
        child: imageBytes == null
            ? Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: isDark ? AppColors.brandDark : AppColors.brand,
                ),
              )
            : null,
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
  const _StatColumn({
    super.key,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.items, required this.onTap});

  final List<ProfilePostItem> items;
  final ValueChanged<ProfilePostItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyTabState('No posts yet.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        onTap: () => onTap(items[index]),
        title: Text(items[index].caption),
        subtitle: Text(items[index].timeAgo),
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.items, required this.onTap});

  final List<ProfilePhotoItem> items;
  final ValueChanged<ProfilePhotoItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyTabState('No photos yet.');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => onTap(items[index]),
        child: Tooltip(
          message: items[index].caption,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.brandDark.withValues(alpha: 0.2)
                  : AppColors.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.photo_outlined,
              color: isDark ? AppColors.brandDark : AppColors.brand,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.items, required this.onTap});

  final List<ProfileReviewItem> items;
  final ValueChanged<ProfileReviewItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyTabState('No reviews yet.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        onTap: () => onTap(items[index]),
        title: Text(items[index].campName),
        subtitle: Text(items[index].snippet),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: AppColors.gold),
            const SizedBox(width: 2),
            Text(items[index].rating.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}

class _SavedCampsTab extends StatelessWidget {
  const _SavedCampsTab({required this.items, required this.onTap});

  final List<ProfileSavedCampItem> items;
  final ValueChanged<ProfileSavedCampItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyTabState('Nothing saved yet — start exploring.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        onTap: () => onTap(items[index]),
        leading: const Icon(Icons.terrain),
        title: Text(items[index].name),
        subtitle: Text(items[index].location),
      ),
    );
  }
}

class _WishlistTab extends StatelessWidget {
  const _WishlistTab({required this.items, required this.onTap});

  final List<ProfileWishlistItem> items;
  final ValueChanged<ProfileWishlistItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyTabState('Dream up your next trip.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        onTap: () => onTap(items[index]),
        leading: const Icon(Icons.bookmark_border),
        title: Text(items[index].name),
        subtitle: Text(items[index].location),
      ),
    );
  }
}

class _CompletedTripsTab extends StatelessWidget {
  const _CompletedTripsTab({required this.items, required this.onTap});

  final List<ProfileCompletedTripItem> items;
  final ValueChanged<ProfileCompletedTripItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyTabState('No completed trips yet.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        onTap: () => onTap(items[index]),
        leading: const Icon(Icons.check_circle_outline),
        title: Text(items[index].name),
        subtitle: Text(items[index].dateLabel),
      ),
    );
  }
}
