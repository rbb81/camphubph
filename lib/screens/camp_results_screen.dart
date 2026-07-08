import 'package:flutter/material.dart';

import '../data/sample_camps.dart';
import '../models/camp.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';

enum _SortOption { distance, rating, price }

extension on _SortOption {
  String get label => switch (this) {
    _SortOption.distance => 'Distance',
    _SortOption.rating => 'Rating',
    _SortOption.price => 'Price',
  };
}

class CampResultsScreen extends StatefulWidget {
  const CampResultsScreen({super.key, required this.category});

  final String category;

  @override
  State<CampResultsScreen> createState() => _CampResultsScreenState();
}

class _CampResultsScreenState extends State<CampResultsScreen> {
  late List<Camp> _camps;
  _SortOption _sortBy = _SortOption.distance;
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _camps = sampleCamps
        .where((c) => c.categories.contains(widget.category))
        .toList()
      ..sort(_compareCamps);
  }

  int _compareCamps(Camp a, Camp b) => switch (_sortBy) {
    _SortOption.distance => a.distanceKm.compareTo(b.distanceKm),
    _SortOption.rating => b.rating.compareTo(a.rating),
    _SortOption.price => a.priceLevel.compareTo(b.priceLevel),
  };

  List<Camp> get _visibleCamps =>
      _camps.where((c) => c.rating >= _minRating).toList();

  Future<void> _openFilters() async {
    var sortBy = _sortBy;
    var minRating = _minRating;
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in _SortOption.values)
                    ChoiceChip(
                      key: Key('sortChip_${option.name}'),
                      label: Text(option.label),
                      selected: sortBy == option,
                      onSelected: (_) => setSheetState(() => sortBy = option),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Minimum rating',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final threshold in const [0.0, 3.0, 4.0, 4.5])
                    ChoiceChip(
                      key: Key('ratingChip_$threshold'),
                      label: Text(threshold == 0 ? 'Any' : '$threshold+'),
                      selected: minRating == threshold,
                      onSelected: (_) =>
                          setSheetState(() => minRating = threshold),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('applyFiltersButton'),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    setState(() {
      _sortBy = sortBy;
      _minRating = minRating;
      _camps.sort(_compareCamps);
    });
  }

  Future<void> _openCamp(Camp camp) async {
    final updated = await Navigator.of(
      context,
    ).push<Camp>(MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: camp)));
    if (updated != null) {
      setState(() {
        final i = _camps.indexWhere((c) => c.id == updated.id);
        if (i != -1) _camps[i] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final camps = _visibleCamps;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            key: const Key('filterButton'),
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: camps.isEmpty
                ? const Center(
                    child: Text(
                      'No camps match your filters.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: camps.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final camp = camps[index];
                      return _CampResultCard(
                        camp: camp,
                        onTap: () => _openCamp(camp),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _CampResultCard extends StatelessWidget {
  const _CampResultCard({required this.camp, required this.onTap});

  final Camp camp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      key: Key('campCard_${camp.id}'),
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.brandDark.withValues(alpha: 0.2)
                    : AppColors.brand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                camp.primaryIcon,
                color: isDark ? AppColors.brandDark : AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    camp.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${camp.location} · ${camp.distanceKm.toStringAsFixed(0)} km away',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱' * camp.priceLevel,
                    style: TextStyle(
                      color: isDark ? AppColors.brandDark : AppColors.brand,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.gold),
                    const SizedBox(width: 2),
                    Text(camp.rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${camp.reviewCount} reviews',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
