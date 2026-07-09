import 'package:flutter/material.dart';

import '../data/sample_trips.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import 'discover_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  late List<Trip> _trips;

  @override
  void initState() {
    super.initState();
    _trips = List.of(sampleTrips);
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  Future<void> _planNewTrip() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DiscoverScreen()));
    if (!mounted) return;
    setState(() => _trips = List.of(sampleTrips));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final upcoming = _trips.where((t) => !t.endDate.isBefore(today)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final past = _trips.where((t) => t.endDate.isBefore(today)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Planner')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _trips.isEmpty
                ? _EmptyState(onFindCamp: _planNewTrip)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        Text(
                          'Upcoming',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        for (final trip in upcoming) ...[
                          _TripCard(
                            trip: trip,
                            onTap: () => _comingSoon('Trip details'),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (past.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Past',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        for (final trip in past) ...[
                          _TripCard(
                            trip: trip,
                            onTap: () => _comingSoon('Trip details'),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onFindCamp});

  final VoidCallback onFindCamp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_travel, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No trips scheduled yet.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('findCampButton'),
              onPressed: onFindCamp,
              child: const Text('Find a camp'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      key: Key('tripCard_${trip.id}'),
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
            Text(
              trip.campName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  trip.campLocation,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: isDark ? AppColors.brandDark : AppColors.brand,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_formatDate(trip.startDate)} → ${_formatDate(trip.endDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
