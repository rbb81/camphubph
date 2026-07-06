import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late ExperienceLevel _experienceLevel;
  late Set<String> _selectedStyles;
  Uint8List? _avatarBytes;
  Uint8List? _coverBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio);
    _experienceLevel = widget.profile.experienceLevel;
    _selectedStyles = widget.profile.favoriteStyles.toSet();
    _avatarBytes = widget.profile.avatarBytes;
    _coverBytes = widget.profile.coverBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() => _pickImage((bytes) => _avatarBytes = bytes);

  Future<void> _pickCover() => _pickImage((bytes) => _coverBytes = bytes);

  Future<void> _pickImage(void Function(Uint8List bytes) apply) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => apply(bytes));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not access photos.')));
    }
  }

  void _save() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    Navigator.of(context).pop(
      widget.profile.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        experienceLevel: _experienceLevel,
        favoriteStyles: _selectedStyles.toList(),
        avatarBytes: _avatarBytes,
        coverBytes: _coverBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                    _buildPhotoPickers(context),
                    const SizedBox(height: 24),
                    fieldLabel(context, 'Name'),
                    TextFormField(
                      key: const Key('nameField'),
                      controller: _nameController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter your name.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    fieldLabel(context, 'Bio'),
                    TextFormField(
                      key: const Key('bioField'),
                      controller: _bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    fieldLabel(context, 'Experience level'),
                    SegmentedButton<ExperienceLevel>(
                      key: const Key('experienceLevelField'),
                      segments: [
                        for (final level in ExperienceLevel.values)
                          ButtonSegment(value: level, label: Text(level.label)),
                      ],
                      selected: {_experienceLevel},
                      onSelectionChanged: (selection) =>
                          setState(() => _experienceLevel = selection.first),
                    ),
                    const SizedBox(height: 16),
                    fieldLabel(context, 'Favorite camping styles'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final style in kCampingStyleCatalog)
                          FilterChip(
                            key: Key('styleChip_$style'),
                            label: Text(style),
                            selected: _selectedStyles.contains(style),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _selectedStyles.add(style);
                              } else {
                                _selectedStyles.remove(style);
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('saveProfileButton'),
                        onPressed: _save,
                        child: const Text('Save changes'),
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

  Widget _buildPhotoPickers(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.brandStrong : AppColors.brand,
                  borderRadius: BorderRadius.circular(12),
                  image: _coverBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_coverBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: _PhotoEditButton(
                  key: const Key('changeCoverButton'),
                  onPressed: _pickCover,
                ),
              ),
              Positioned(
                bottom: -32,
                left: 16,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: isDark
                      ? AppColors.brandDark.withValues(alpha: 0.25)
                      : AppColors.brand.withValues(alpha: 0.12),
                  backgroundImage: _avatarBytes != null
                      ? MemoryImage(_avatarBytes!)
                      : null,
                  child: _avatarBytes == null
                      ? Text(
                          widget.profile.initials,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: isDark
                                ? AppColors.brandDark
                                : AppColors.brand,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: -36,
                left: 72,
                child: _PhotoEditButton(
                  key: const Key('changeAvatarButton'),
                  onPressed: _pickAvatar,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PhotoEditButton extends StatelessWidget {
  const _PhotoEditButton({super.key, required this.onPressed, this.size = 32});

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.camera_alt, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}
