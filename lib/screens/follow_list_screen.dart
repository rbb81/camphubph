import 'package:flutter/material.dart';

import '../data/sample_other_users.dart';
import '../models/followable_user.dart';
import 'other_user_profile_screen.dart';

enum FollowListType { followers, following }

/// Reached via Profile's follower/following stat taps (not bottom-nav), so
/// this is a typed push rather than a named route, per this app's routing
/// convention. Both lists are drawn from the same `sampleOtherUsers`
/// directory (see its doc comment) — there's no real follow graph, so
/// Followers is filtered by the fixed-seed `followsMe` flag and Following
/// by the existing `FollowStatus.following`.
class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key, required this.type});

  final FollowListType type;

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late List<FollowableUser> _users;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  void _sync() {
    _users = sampleOtherUsers
        .where(
          (u) => widget.type == FollowListType.followers
              ? u.followsMe
              : u.followStatus == FollowStatus.following,
        )
        .toList();
  }

  void _setStatus(FollowableUser user, FollowStatus status) {
    final index = sampleOtherUsers.indexWhere(
      (u) => u.profile.name == user.profile.name,
    );
    if (index != -1) {
      sampleOtherUsers[index] = sampleOtherUsers[index].copyWith(
        followStatus: status,
      );
    }
    setState(_sync);
  }

  // Mirrors OtherUserProfileScreen's exact follow state machine: tap while
  // not following sends a request that auto-approves after a delay; tap
  // while requested cancels it; tap while following unfollows immediately
  // with no confirmation (same as this app's other unfollow/cancel action,
  // Trip Details' Cancel Trip).
  void _toggleFollow(FollowableUser user) {
    switch (user.followStatus) {
      case FollowStatus.notFollowing:
        _setStatus(user, FollowStatus.requested);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Follow request sent to ${user.profile.name}'),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          final current = sampleOtherUsers.firstWhere(
            (u) => u.profile.name == user.profile.name,
            orElse: () => user,
          );
          if (current.followStatus != FollowStatus.requested) return;
          _setStatus(user, FollowStatus.following);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${user.profile.name} accepted your follow request.',
              ),
            ),
          );
        });
      case FollowStatus.requested:
        _setStatus(user, FollowStatus.notFollowing);
      case FollowStatus.following:
        _setStatus(user, FollowStatus.notFollowing);
    }
  }

  void _openProfile(FollowableUser user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    final isFollowers = widget.type == FollowListType.followers;
    return Scaffold(
      appBar: AppBar(title: Text(isFollowers ? 'Followers' : 'Following')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _users.isEmpty
                ? _EmptyState(isFollowers: isFollowers)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return _FollowListTile(
                        user: user,
                        isFollowersList: isFollowers,
                        onTapRow: () => _openProfile(user),
                        onTapFollow: () => _toggleFollow(user),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _FollowListTile extends StatelessWidget {
  const _FollowListTile({
    required this.user,
    required this.isFollowersList,
    required this.onTapRow,
    required this.onTapFollow,
  });

  final FollowableUser user;
  final bool isFollowersList;
  final VoidCallback onTapRow;
  final VoidCallback onTapFollow;

  String _label() => switch (user.followStatus) {
    FollowStatus.notFollowing => isFollowersList ? 'Follow Back' : 'Follow',
    FollowStatus.requested => 'Requested',
    FollowStatus.following => 'Following',
  };

  @override
  Widget build(BuildContext context) {
    final key = Key('followButton_${user.profile.name}');
    final button = user.followStatus == FollowStatus.following
        ? OutlinedButton(key: key, onPressed: onTapFollow, child: Text(_label()))
        : FilledButton(key: key, onPressed: onTapFollow, child: Text(_label()));

    return ListTile(
      key: Key('followListTile_${user.profile.name}'),
      onTap: onTapRow,
      leading: CircleAvatar(child: Text(user.profile.initials)),
      title: Text(user.profile.name),
      subtitle: Text(
        user.profile.bio,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: button,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isFollowers});

  final bool isFollowers;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isFollowers ? 'No followers yet.' : 'Not following anyone yet.',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
