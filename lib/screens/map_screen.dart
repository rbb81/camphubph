import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/sample_camps.dart';
import '../models/camp.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';

const LatLng kPhilippinesCenter = LatLng(12.8797, 121.7740);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.focusCampId});

  final String? focusCampId;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapReady() {
    final focusCampId = widget.focusCampId;
    if (focusCampId == null) return;
    final matches = sampleCamps.where((c) => c.id == focusCampId);
    if (matches.isEmpty) return;
    _mapController.move(matches.first.coordinates, 10);
  }

  Future<void> _openCamp(Camp camp) async {
    Navigator.of(context).pop();
    await Navigator.of(
      context,
    ).push<Camp>(MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: camp)));
  }

  void _onTapMarker(Camp camp) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => _CampPreviewSheet(
        camp: camp,
        onViewDetails: () => _openCamp(camp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: kPhilippinesCenter,
          initialZoom: 5.3,
          minZoom: 4,
          maxZoom: 18,
          onMapReady: _onMapReady,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.camphubph.camper',
          ),
          MarkerLayer(
            markers: [
              for (final camp in sampleCamps)
                Marker(
                  point: camp.coordinates,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    key: Key('mapMarker_${camp.id}'),
                    onTap: () => _onTapMarker(camp),
                    child: Tooltip(
                      message: camp.name,
                      child: Icon(
                        Icons.location_on,
                        size: 36,
                        color: camp.id == widget.focusCampId
                            ? AppColors.gold
                            : AppColors.brand,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampPreviewSheet extends StatelessWidget {
  const _CampPreviewSheet({required this.camp, required this.onViewDetails});

  final Camp camp;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(camp.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(camp.location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  camp.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${camp.reviewCount} review${camp.reviewCount == 1 ? '' : 's'})',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('viewCampDetailsButton'),
                onPressed: onViewDetails,
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
