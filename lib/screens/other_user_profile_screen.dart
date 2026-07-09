import 'package:flutter/material.dart';

import '../data/sample_message_threads.dart';
import '../data/sample_other_users.dart';
import '../data/sample_profile.dart';
import '../models/followable_user.dart';
import '../models/message_thread.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import 'message_thread_screen.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({super.key, required this.user});

  final FollowableUser user;

  @override
  State<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  late FollowableUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _setStatus(FollowStatus status) {
    final index = sampleOtherUsers.indexWhere(
      (u) => u.profile.name == _user.profile.name,
    );
    final updated = _user.copyWith(followStatus: status);
    if (index != -1) sampleOtherUsers[index] = updated;
    setState(() => _user = updated);
  }

  void _toggleFollow() {
    switch (_user.followStatus) {
      case FollowStatus.notFollowing:
        _setStatus(FollowStatus.requested);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Follow request sent to ${_user.profile.name}')),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          if (_user.followStatus != FollowStatus.requested) return;
          _setStatus(FollowStatus.following);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_user.profile.name} accepted your follow request.'),
            ),
          );
        });
      case FollowStatus.requested:
        _setStatus(FollowStatus.notFollowing);
      case FollowStatus.following:
        _setStatus(FollowStatus.notFollowing);
    }
  }

  Future<void> _message() async {
    final myName = sampleProfile.name;
    final otherName = _user.profile.name;
    final thread = sampleMessageThreads.firstWhere(
      (t) =>
          t.campId == null &&
          ((t.participantA == myName && t.participantB == otherName) ||
              (t.participantA == otherName && t.participantB == myName)),
      orElse: () {
        final created = MessageThread(
          id: 'thread_${DateTime.now().microsecondsSinceEpoch}',
          participantA: myName,
          participantB: otherName,
          messages: const [],
        );
        sampleMessageThreads.add(created);
        return created;
      },
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageThreadScreen(thread: thread, viewerName: myName),
      ),
    );
  }

  String _followLabel() => switch (_user.followStatus) {
    FollowStatus.notFollowing => 'Follow',
    FollowStatus.requested => 'Requested',
    FollowStatus.following => 'Following',
  };

  @override
  Widget build(BuildContext context) {
    final profile = _user.profile;

    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(initials: profile.initials),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          _ExperienceBadge(level: profile.experienceLevel),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(profile.bio),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final style in profile.favoriteStyles)
                      _StyleTag(label: style),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatColumn(
                      key: const Key('followerCountStat'),
                      value: profile.followerCount,
                      label: 'Followers',
                    ),
                    const SizedBox(width: 24),
                    _StatColumn(
                      key: const Key('followingCountStat'),
                      value: profile.followingCount,
                      label: 'Following',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _user.followStatus == FollowStatus.following
                          ? OutlinedButton(
                              key: const Key('followButton'),
                              onPressed: _toggleFollow,
                              child: Text(_followLabel()),
                            )
                          : FilledButton(
                              key: const Key('followButton'),
                              onPressed: _toggleFollow,
                              child: Text(_followLabel()),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('messageUserButton'),
                        onPressed: _message,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    return CircleAvatar(
      radius: 32,
      backgroundColor: accent.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: accent,
        ),
      ),
    );
  }
}

class _ExperienceBadge extends StatelessWidget {
  const _ExperienceBadge({required this.level});

  final ExperienceLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${level.label} camper',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
}

class _StyleTag extends StatelessWidget {
  const _StyleTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceMutedDark
            : AppColors.surfaceMutedLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
