import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../data/sample_message_threads.dart';
import '../data/sample_profile.dart';
import '../data/sample_reviews.dart';
import '../models/camp.dart';
import '../models/message_thread.dart';
import '../models/review.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';
import 'message_thread_screen.dart';
import 'schedule_trip_screen.dart';
import 'write_review_screen.dart';

class CampDetailsScreen extends StatefulWidget {
  const CampDetailsScreen({super.key, required this.camp});

  final Camp camp;

  @override
  State<CampDetailsScreen> createState() => _CampDetailsScreenState();
}

class _CampDetailsScreenState extends State<CampDetailsScreen>
    with SingleTickerProviderStateMixin {
  static const _tabLabels = ['Overview', 'Reviews', 'Photos', 'Map'];

  late final TabController _tabController;
  late Camp _camp;
  late List<Review> _reviews;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _camp = widget.camp;
    _reviews = sampleReviews.where((r) => r.campId == _camp.id).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'Saved to your camps.' : 'Removed from saved camps.',
        ),
      ),
    );
  }

  Future<void> _writeReview() async {
    final review = await Navigator.of(context).push<Review>(
      MaterialPageRoute(
        builder: (_) =>
            WriteReviewScreen(camp: _camp, author: sampleProfile),
      ),
    );
    if (review == null) return;
    setState(() {
      _reviews = [review, ..._reviews];
      final newCount = _camp.reviewCount + 1;
      final newRating =
          ((_camp.rating * _camp.reviewCount) + review.rating) / newCount;
      _camp = _camp.copyWith(rating: newRating, reviewCount: newCount);
    });
  }

  Future<void> _addToTrip() async {
    final trip = await Navigator.of(context).push<Trip>(
      MaterialPageRoute(builder: (_) => ScheduleTripScreen(camp: _camp)),
    );
    if (trip == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${_camp.name} to your trips.')),
    );
  }

  Future<void> _messageCampsite() async {
    final guestName = sampleProfile.name;
    final thread = sampleMessageThreads.firstWhere(
      (t) => t.campId == _camp.id && t.participantA == guestName,
      orElse: () {
        final created = MessageThread(
          id: 'thread_${DateTime.now().microsecondsSinceEpoch}',
          participantA: guestName,
          participantB: _camp.name,
          campId: _camp.id,
          messages: const [],
        );
        sampleMessageThreads.add(created);
        return created;
      },
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageThreadScreen(thread: thread, viewerName: guestName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_camp);
      },
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
                        _OverviewTab(camp: _camp),
                        _ReviewsTab(
                          reviews: _reviews,
                          onWriteReview: _writeReview,
                        ),
                        _PhotosTab(reviews: _reviews),
                        _MapTab(
                          camp: _camp,
                          onOpenFullMap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MapScreen(focusCampId: _camp.id),
                            ),
                          ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.brandStrong : AppColors.brand,
                ),
                child: Center(
                  child: Icon(
                    _camp.primaryIcon,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
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
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  bottom: false,
                  child: IconButton(
                    key: const Key('bookmarkButton'),
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSave,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_camp.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _camp.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    _camp.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${_camp.reviewCount} review${_camp.reviewCount == 1 ? '' : 's'})',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Text('${_camp.distanceKm.toStringAsFixed(0)} km away'),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in _camp.categories)
                    _CategoryTag(label: category),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const Key('saveButton'),
                      onPressed: _toggleSave,
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(_isSaved ? 'Saved' : 'Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('addToTripButton'),
                      onPressed: _addToTrip,
                      icon: const Icon(Icons.add_road),
                      label: const Text('Add to Trip'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('messageCampsiteButton'),
                  onPressed: _messageCampsite,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message Campsite'),
                ),
              ),
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

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

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

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.camp});

  final Camp camp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(camp.description),
        const SizedBox(height: 20),
        _FactRow(
          icon: Icons.payments_outlined,
          label: 'Price level',
          value: '₱' * camp.priceLevel,
        ),
        _FactRow(
          icon: Icons.directions_outlined,
          label: 'Distance',
          value: '${camp.distanceKm.toStringAsFixed(0)} km away',
        ),
        _FactRow(
          icon: Icons.category_outlined,
          label: 'Categories',
          value: camp.categories.join(', '),
        ),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isDark ? AppColors.brandDark : AppColors.brand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews, required this.onWriteReview});

  final List<Review> reviews;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('writeReviewButton'),
            onPressed: onWriteReview,
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Write a review'),
          ),
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No reviews yet — be the first to share one.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          for (final review in reviews) _ReviewCard(review: review),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? AppColors.brandDark.withValues(alpha: 0.25)
                    : AppColors.brand.withValues(alpha: 0.12),
                child: Text(
                  review.authorInitials,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isDark ? AppColors.brandDark : AppColors.brand,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Visited ${review.visitDate.year}-${review.visitDate.month.toString().padLeft(2, '0')} · ${review.postedAgo}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
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
          if (review.pros.isNotEmpty || review.cons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final pro in review.pros)
                  _ProConChip(label: pro, isPro: true),
                for (final con in review.cons)
                  _ProConChip(label: con, isPro: false),
              ],
            ),
          ],
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
          if (review.photoBytes != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                review.photoBytes!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProConChip extends StatelessWidget {
  const _ProConChip({required this.label, required this.isPro});

  final String label;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPro ? Colors.green : AppColors.danger).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPro ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined,
            size: 12,
            color: isPro ? Colors.green : AppColors.danger,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final photos = [
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

class _MapTab extends StatelessWidget {
  const _MapTab({required this.camp, required this.onOpenFullMap});

  final Camp camp;
  final VoidCallback onOpenFullMap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: camp.coordinates,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.camphubph.camper',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: camp.coordinates,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        size: 36,
                        color: AppColors.brand,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('viewOnMapButton'),
          onPressed: onOpenFullMap,
          child: const Text('View on Map'),
        ),
      ],
    );
  }
}
