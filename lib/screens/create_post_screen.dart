import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/home_feed_item.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.author});

  final UserProfile author;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
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

  void _publish() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    Navigator.of(context).pop(
      FriendPostItem(
        authorName: widget.author.name,
        authorInitials: widget.author.initials,
        timeAgo: 'Just now',
        location: _locationController.text.trim().isEmpty
            ? 'Unknown location'
            : _locationController.text.trim(),
        caption: _captionController.text.trim(),
        likeCount: 0,
        commentCount: 0,
        photoBytes: _photoBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('cancelPostButton'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Post'),
        actions: [
          TextButton(
            key: const Key('publishPostButton'),
            onPressed: _publish,
            child: const Text('Post'),
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
                    _buildPhotoPicker(context),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('captionField'),
                      controller: _captionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "What's happening on your trip?",
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Write something to post.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('locationField'),
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        prefixIcon: Icon(Icons.location_on_outlined),
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

  Widget _buildPhotoPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_photoBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _photoBytes!,
              height: 200,
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
                key: const Key('removePhotoButton'),
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: _removePhoto,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      key: const Key('addPhotoButton'),
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight,
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
