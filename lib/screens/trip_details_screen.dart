import 'package:flutter/material.dart';

import '../data/sample_camps.dart';
import '../data/sample_trips.dart';
import '../models/camp.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Camp _resolveCamp() => sampleCamps.firstWhere(
    (c) => c.id == trip.campId,
    orElse: () => Camp(
      id: trip.campId,
      name: trip.campName,
      location: trip.campLocation,
      categories: const ['Camping Grounds'],
      rating: 0,
      reviewCount: 0,
      distanceKm: 0,
      priceLevel: 1,
      description: 'No description available yet for this camp.',
    ),
  );

  void _viewCamp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: _resolveCamp())),
    );
  }

  void _cancelTrip(BuildContext context) {
    sampleTrips.removeWhere((t) => t.id == trip.id);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final nights = trip.endDate.difference(trip.startDate).inDays;
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  trip.campName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                      trip.campLocation,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _DetailRow(
                  icon: Icons.login,
                  label: 'Check-in',
                  value: _formatDate(trip.startDate),
                ),
                _DetailRow(
                  icon: Icons.logout,
                  label: 'Check-out',
                  value: _formatDate(trip.endDate),
                ),
                _DetailRow(
                  icon: Icons.nights_stay_outlined,
                  label: 'Length of stay',
                  value: '$nights night${nights == 1 ? '' : 's'}',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('viewCampButton'),
                    onPressed: () => _viewCamp(context),
                    icon: const Icon(Icons.terrain),
                    label: const Text('View Camp'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('cancelTripDetailsButton'),
                    onPressed: () => _cancelTrip(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel Trip'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.brandDark : AppColors.brand,
          ),
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
