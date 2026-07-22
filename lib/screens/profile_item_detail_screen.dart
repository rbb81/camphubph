import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/sample_camps.dart';
import '../models/camp.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';

class ProfileSimpleDetailScreen extends StatelessWidget {
  const ProfileSimpleDetailScreen({
    super.key,
    required this.appBarTitle,
    required this.primaryText,
    this.secondaryText,
    this.placeholderIcon,
  });

  final String appBarTitle;
  final String primaryText;
  final String? secondaryText;
  final IconData? placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (placeholderIcon != null) ...[
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.brandDark.withValues(alpha: 0.2)
                          : AppColors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      placeholderIcon,
                      size: 64,
                      color: isDark ? AppColors.brandDark : AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(primaryText, style: Theme.of(context).textTheme.bodyLarge),
                if (secondaryText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    secondaryText!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({super.key, required this.review});

  final ProfileReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  review.campName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        i <= review.rating ? Icons.star : Icons.star_border,
                        size: 18,
                        color: AppColors.gold,
                      ),
                    const SizedBox(width: 8),
                    Text(review.rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(review.snippet),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompletedTripDetailScreen extends StatelessWidget {
  const CompletedTripDetailScreen({super.key, required this.trip});

  final ProfileCompletedTripItem trip;

  Camp _resolveCamp() => sampleCamps.firstWhere(
    (c) => c.name == trip.name,
    orElse: () => Camp(
      id: trip.name,
      name: trip.name,
      location: '',
      categories: const ['Camping Grounds'],
      rating: 0,
      reviewCount: 0,
      distanceKm: 0,
      priceLevel: 1,
      description: 'No description available yet for this camp.',
      coordinates: const LatLng(12.8797, 121.7740),
    ),
  );

  void _viewCamp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: _resolveCamp())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  trip.dateLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  key: const Key('viewCampButton'),
                  onPressed: () => _viewCamp(context),
                  icon: const Icon(Icons.terrain),
                  label: const Text('View Camp'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
