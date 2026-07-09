import 'package:flutter/material.dart';

import '../data/sample_trips.dart';
import '../models/camp.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

class ScheduleTripScreen extends StatefulWidget {
  const ScheduleTripScreen({super.key, required this.camp});

  final Camp camp;

  @override
  State<ScheduleTripScreen> createState() => _ScheduleTripScreenState();
}

class _ScheduleTripScreenState extends State<ScheduleTripScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _errorText;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickCheckIn() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      _checkInDate = picked;
      _errorText = null;
      if (_checkOutDate != null && !_checkOutDate!.isAfter(picked)) {
        _checkOutDate = null;
      }
    });
  }

  Future<void> _pickCheckOut() async {
    final now = DateTime.now();
    final earliest = _checkInDate?.add(const Duration(days: 1)) ??
        now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? earliest,
      firstDate: earliest,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      _checkOutDate = picked;
      _errorText = null;
    });
  }

  void _submit() {
    if (_checkInDate == null || _checkOutDate == null) {
      setState(
        () => _errorText = 'Select both check-in and check-out dates.',
      );
      return;
    }

    final conflict = Trip.findConflict(
      sampleTrips,
      startDate: _checkInDate!,
      endDate: _checkOutDate!,
    );
    if (conflict != null) {
      setState(
        () => _errorText =
            'This overlaps your trip to ${conflict.campName} '
            '(${_formatDate(conflict.startDate)} to ${_formatDate(conflict.endDate)}).',
      );
      return;
    }

    final trip = Trip(
      id: 'trip_${DateTime.now().microsecondsSinceEpoch}',
      campId: widget.camp.id,
      campName: widget.camp.name,
      campLocation: widget.camp.location,
      startDate: _checkInDate!,
      endDate: _checkOutDate!,
    );
    sampleTrips.add(trip);
    Navigator.of(context).pop(trip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('cancelTripButton'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Schedule Trip'),
        actions: [
          TextButton(
            key: const Key('submitTripButton'),
            onPressed: _submit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.camp.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    widget.camp.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Check-in date'),
                  _DateField(
                    fieldKey: const Key('checkInField'),
                    date: _checkInDate,
                    hint: 'Select check-in date',
                    onTap: _pickCheckIn,
                  ),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Check-out date'),
                  _DateField(
                    fieldKey: const Key('checkOutField'),
                    date: _checkOutDate,
                    hint: 'Select check-out date',
                    onTap: _pickCheckOut,
                  ),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('submitTripBottomButton'),
                      onPressed: _submit,
                      child: const Text('Schedule trip'),
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
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.fieldKey,
    required this.date,
    required this.hint,
    required this.onTap,
  });

  final Key fieldKey;
  final DateTime? date;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = date == null
        ? hint
        : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';
    return InkWell(
      key: fieldKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: isDark ? AppColors.brandDark : AppColors.brand,
            ),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
