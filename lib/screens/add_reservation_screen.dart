import 'package:flutter/material.dart';

import '../data/sample_reservations.dart';
import '../models/reservation.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

const _ownerCampNames = [
  'Mt. Daraitan campsite',
  'Nasugbu beach camp',
  'Taal Lake shoreline',
];

class AddReservationScreen extends StatefulWidget {
  const AddReservationScreen({super.key});

  @override
  State<AddReservationScreen> createState() => _AddReservationScreenState();
}

class _AddReservationScreenState extends State<AddReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();

  String? _campName;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  ReservationStatus _status = ReservationStatus.confirmed;
  String? _errorText;

  @override
  void dispose() {
    _guestNameController.dispose();
    super.dispose();
  }

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
    final earliest =
        _checkInDate?.add(const Duration(days: 1)) ??
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
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (_campName == null) {
      setState(() => _errorText = 'Select a camp.');
      return;
    }
    if (_checkInDate == null || _checkOutDate == null) {
      setState(
        () => _errorText = 'Select both check-in and check-out dates.',
      );
      return;
    }

    final reservation = Reservation(
      id: 'res_${DateTime.now().microsecondsSinceEpoch}',
      guestName: _guestNameController.text.trim(),
      campName: _campName!,
      startDate: _checkInDate!,
      endDate: _checkOutDate!,
      status: _status,
    );
    sampleReservations.add(reservation);
    Navigator.of(context).pop(reservation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('cancelAddReservationButton'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Reservation'),
        actions: [
          TextButton(
            key: const Key('submitReservationButton'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel(context, 'Guest name'),
                    TextFormField(
                      key: const Key('guestNameField'),
                      controller: _guestNameController,
                      decoration: const InputDecoration(
                        hintText: 'Jasmine Reyes',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter the guest\'s name.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    fieldLabel(context, 'Camp'),
                    DropdownButtonFormField<String>(
                      key: const Key('campField'),
                      initialValue: _campName,
                      hint: const Text('Select a camp'),
                      items: [
                        for (final name in _ownerCampNames)
                          DropdownMenuItem(value: name, child: Text(name)),
                      ],
                      onChanged: (value) =>
                          setState(() => _campName = value),
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
                    const SizedBox(height: 20),
                    fieldLabel(context, 'Status'),
                    SegmentedButton<ReservationStatus>(
                      key: const Key('reservationStatusField'),
                      segments: const [
                        ButtonSegment(
                          value: ReservationStatus.confirmed,
                          label: Text('Confirmed'),
                        ),
                        ButtonSegment(
                          value: ReservationStatus.pending,
                          label: Text('Pending'),
                        ),
                      ],
                      selected: {_status},
                      onSelectionChanged: (selection) =>
                          setState(() => _status = selection.first),
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
                        key: const Key('submitReservationBottomButton'),
                        onPressed: _submit,
                        child: const Text('Add reservation'),
                      ),
                    ),
                  ],
                ),
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
