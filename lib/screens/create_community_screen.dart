import 'package:flutter/material.dart';

import '../models/community.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _create() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    Navigator.of(context).pop(
      Community(
        id: 'community-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: Icons.groups,
        memberCount: 1,
        isJoined: true,
        isPrivate: _isPrivate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('cancelCreateCommunityButton'),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Community'),
        actions: [
          TextButton(
            key: const Key('createCommunitySubmitButton'),
            onPressed: _create,
            child: const Text('Create'),
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
                    TextFormField(
                      key: const Key('communityNameField'),
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Give your community a name.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('communityDescriptionField'),
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Describe what this community is about.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Privacy',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      key: const Key('communityPrivacyField'),
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Public'),
                          icon: Icon(Icons.public),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Private'),
                          icon: Icon(Icons.lock_outline),
                        ),
                      ],
                      selected: {_isPrivate},
                      onSelectionChanged: (selection) =>
                          setState(() => _isPrivate = selection.first),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isPrivate
                          ? 'Only people you approve can join and see posts.'
                          : 'Anyone can find and join this community.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
