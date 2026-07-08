import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/camp.dart';
import '../models/profile.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, required this.camp, required this.author});

  final Camp camp;
  final UserProfile author;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _picker = ImagePicker();
  final _proController = TextEditingController();
  final _conController = TextEditingController();
  final _tipController = TextEditingController();
  final List<String> _pros = [];
  final List<String> _cons = [];
  int _rating = 0;
  String? _ratingError;
  DateTime? _visitDate;
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _proController.dispose();
    _conController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not access photos.')));
    }
  }

  void _removePhoto() => setState(() => _photoBytes = null);

  void _addPro() {
    final text = _proController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _pros.add(text);
      _proController.clear();
    });
  }

  void _removePro(int index) => setState(() => _pros.removeAt(index));

  void _addCon() {
    final text = _conController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _cons.add(text);
      _conController.clear();
    });
  }

  void _removeCon(int index) => setState(() => _cons.removeAt(index));

  Future<void> _pickVisitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  void _submit() {
    if (_rating == 0) {
      setState(
        () => _ratingError = 'Select a rating to submit your review.',
      );
      return;
    }

    Navigator.of(context).pop(
      Review(
        id: 'review_${DateTime.now().microsecondsSinceEpoch}',
        campId: widget.camp.id,
        authorName: widget.author.name,
        authorInitials: widget.author.initials,
        rating: _rating,
        visitDate: _visitDate ?? DateTime.now(),
        postedAgo: 'Just now',
        pros: _pros,
        cons: _cons,
        tip: _tipController.text.trim().isEmpty
            ? null
            : _tipController.text.trim(),
        photoBytes: _photoBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('cancelReviewButton'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Write a Review'),
        actions: [
          TextButton(
            key: const Key('submitReviewButton'),
            onPressed: _submit,
            child: const Text('Submit'),
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
                  fieldLabel(context, 'Your rating'),
                  _StarRatingInput(
                    rating: _rating,
                    onChanged: (value) => setState(() {
                      _rating = value;
                      _ratingError = null;
                    }),
                  ),
                  if (_ratingError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _ratingError!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Pros'),
                  _ChipListInput(
                    fieldKey: const Key('prosField'),
                    addButtonKey: const Key('addProButton'),
                    chipKey: (i) => Key('removeProChip_$i'),
                    controller: _proController,
                    items: _pros,
                    onAdd: _addPro,
                    onRemove: _removePro,
                    hint: 'e.g. Great sunrise view',
                  ),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Cons'),
                  _ChipListInput(
                    fieldKey: const Key('consField'),
                    addButtonKey: const Key('addConButton'),
                    chipKey: (i) => Key('removeConChip_$i'),
                    controller: _conController,
                    items: _cons,
                    onAdd: _addCon,
                    onRemove: _removeCon,
                    hint: 'e.g. Muddy trail after rain',
                  ),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Tips (optional)'),
                  TextField(
                    key: const Key('tipField'),
                    controller: _tipController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any tips for other campers?',
                    ),
                  ),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Visit date'),
                  _VisitDateField(date: _visitDate, onTap: _pickVisitDate),
                  const SizedBox(height: 20),
                  fieldLabel(context, 'Photo (optional)'),
                  _buildPhotoPicker(context),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('submitReviewBottomButton'),
                      onPressed: _submit,
                      child: const Text('Submit review'),
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

  Widget _buildPhotoPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_photoBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _photoBytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('removeReviewPhotoButton'),
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: _removePhoto,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      key: const Key('addReviewPhotoButton'),
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceMutedDark
              : AppColors.surfaceMutedLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: isDark ? AppColors.brandDark : AppColors.brand,
            ),
            const SizedBox(height: 8),
            const Text('Add a photo'),
          ],
        ),
      ),
    );
  }
}

class _StarRatingInput extends StatelessWidget {
  const _StarRatingInput({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            key: Key('starButton_$i'),
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= rating ? Icons.star : Icons.star_border,
              color: AppColors.gold,
              size: 32,
            ),
          ),
      ],
    );
  }
}

class _ChipListInput extends StatelessWidget {
  const _ChipListInput({
    required this.fieldKey,
    required this.addButtonKey,
    required this.chipKey,
    required this.controller,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.hint,
  });

  final Key fieldKey;
  final Key addButtonKey;
  final Key Function(int index) chipKey;
  final TextEditingController controller;
  final List<String> items;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: fieldKey,
                controller: controller,
                decoration: InputDecoration(hintText: hint, isDense: true),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            IconButton(
              key: addButtonKey,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdd,
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < items.length; i++)
                Chip(
                  key: chipKey(i),
                  label: Text(items[i]),
                  onDeleted: () => onRemove(i),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _VisitDateField extends StatelessWidget {
  const _VisitDateField({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = date == null
        ? 'Select a date'
        : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';
    return InkWell(
      key: const Key('visitDateField'),
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
