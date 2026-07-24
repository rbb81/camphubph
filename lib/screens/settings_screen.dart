import 'package:flutter/material.dart';

import '../data/sample_profile.dart';
import '../data/sample_settings.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';

/// Reached only via Profile's gear icon (not bottom-nav), so it's a typed
/// push rather than a named route, per this app's routing convention.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _updatedProfile;

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(profile: _updatedProfile ?? sampleProfile),
      ),
    );
    if (result != null) {
      setState(() => _updatedProfile = result);
    }
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  Future<void> _confirmLogOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to sign in again to continue."),
        actions: [
          TextButton(
            key: const Key('cancelLogOutButton'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirmLogOutButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, Log Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_updatedProfile);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                children: [
                  _sectionHeader(context, 'Account'),
                  _buildAccountSection(context),
                  const Divider(height: 1),
                  _sectionHeader(context, 'Notifications'),
                  _buildNotificationsSection(),
                  const Divider(height: 1),
                  _sectionHeader(context, 'Appearance'),
                  _buildAppearanceSection(),
                  const Divider(height: 1),
                  _sectionHeader(context, 'Privacy'),
                  _buildPrivacySection(),
                  const Divider(height: 1),
                  _sectionHeader(context, 'Support'),
                  _buildSupportSection(),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ListTile(
                    key: const Key('logOutButton'),
                    leading: const Icon(Icons.logout, color: AppColors.danger),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: _confirmLogOut,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _buildAccountSection(BuildContext context) {
    final email = AuthService.instance.currentSession?.email;
    return Column(
      children: [
        if (email != null)
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(email),
          ),
        ListTile(
          key: const Key('editProfileTile'),
          leading: const Icon(Icons.person_outline),
          title: const Text('Edit Profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openEditProfile,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) => SegmentedButton<ThemeMode>(
          key: const Key('themeModeField'),
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.settings_suggest_outlined),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              themeModeNotifier.value = selection.first,
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      children: [
        SwitchListTile(
          key: const Key('pushNotificationsToggle'),
          title: const Text('Push notifications'),
          subtitle: const Text('Master switch for all app notifications'),
          value: sampleSettings.pushNotifications,
          onChanged: (value) =>
              setState(() => sampleSettings.pushNotifications = value),
        ),
        SwitchListTile(
          key: const Key('likesAndCommentsToggle'),
          title: const Text('Likes & comments'),
          value: sampleSettings.likesAndComments,
          onChanged: (value) =>
              setState(() => sampleSettings.likesAndComments = value),
        ),
        SwitchListTile(
          key: const Key('followRequestsToggle'),
          title: const Text('Follow requests'),
          value: sampleSettings.followRequests,
          onChanged: (value) =>
              setState(() => sampleSettings.followRequests = value),
        ),
        SwitchListTile(
          key: const Key('communityActivityToggle'),
          title: const Text('Community activity'),
          value: sampleSettings.communityActivity,
          onChanged: (value) =>
              setState(() => sampleSettings.communityActivity = value),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      children: [
        SwitchListTile(
          key: const Key('shareLocationToggle'),
          title: const Text('Share my location'),
          subtitle: const Text(
            'Lets nearby campers see roughly where you are',
          ),
          value: sampleSettings.shareLocation,
          onChanged: (value) =>
              setState(() => sampleSettings.shareLocation = value),
        ),
        SwitchListTile(
          key: const Key('allowMessagesToggle'),
          title: const Text('Allow messages from anyone'),
          subtitle: const Text(
            'Turn off to only allow messages from people you follow',
          ),
          value: sampleSettings.allowMessagesFromAnyone,
          onChanged: (value) =>
              setState(() => sampleSettings.allowMessagesFromAnyone = value),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help Center'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _comingSoon('Help Center'),
        ),
        ListTile(
          leading: const Icon(Icons.support_agent_outlined),
          title: const Text('Contact Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _comingSoon('Contact Support'),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About Camper'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _comingSoon('About Camper'),
        ),
      ],
    );
  }
}
