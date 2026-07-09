import 'package:flutter/material.dart';

import '../data/sample_communities.dart';
import '../models/community.dart';
import '../theme/app_theme.dart';
import 'community_feed_screen.dart';
import 'create_community_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final List<Community> _communities = List.of(sampleCommunities);

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  void _toggleJoin(Community community) {
    if (community.isPrivate && !community.isJoined) {
      _toggleJoinRequest(community);
      return;
    }
    setState(() {
      final index = _communities.indexWhere((c) => c.id == community.id);
      _communities[index] = community.copyWith(
        isJoined: !community.isJoined,
        memberCount: community.isJoined
            ? community.memberCount - 1
            : community.memberCount + 1,
      );
    });
  }

  void _toggleJoinRequest(Community community) {
    if (community.isPending) {
      setState(() {
        final index = _communities.indexWhere((c) => c.id == community.id);
        _communities[index] = community.copyWith(isPending: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Canceled your request to join ${community.name}.'),
        ),
      );
      return;
    }

    setState(() {
      final index = _communities.indexWhere((c) => c.id == community.id);
      _communities[index] = community.copyWith(isPending: true);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Request sent to join ${community.name}.')));

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final index = _communities.indexWhere((c) => c.id == community.id);
      if (index == -1 || !_communities[index].isPending) return;
      setState(() {
        _communities[index] = _communities[index].copyWith(
          isPending: false,
          isJoined: true,
          memberCount: _communities[index].memberCount + 1,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your request to join ${community.name} was approved!',
          ),
        ),
      );
    });
  }

  Future<void> _openCommunity(Community community) async {
    final updated = await Navigator.of(context).push<Community>(
      MaterialPageRoute(
        builder: (_) => CommunityFeedScreen(community: community),
      ),
    );
    if (updated == null) return;
    setState(() {
      final index = _communities.indexWhere((c) => c.id == updated.id);
      if (index != -1) _communities[index] = updated;
    });
  }

  Future<void> _createCommunity() async {
    final created = await Navigator.of(
      context,
    ).push<Community>(MaterialPageRoute(builder: (_) => const CreateCommunityScreen()));
    if (created == null) return;
    setState(() => _communities.insert(0, created));
  }

  @override
  Widget build(BuildContext context) {
    final joined = _communities.where((c) => c.isJoined).toList();
    final suggested = _communities.where((c) => !c.isJoined).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            key: const Key('communitiesSearchButton'),
            icon: const Icon(Icons.search),
            onPressed: () => _comingSoon('Search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Your communities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (joined.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "You haven't joined any communities yet — check out "
                      'these suggestions.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  for (final community in joined) ...[
                    _CommunityCard(
                      community: community,
                      onTap: () => _openCommunity(community),
                      onToggleJoin: () => _toggleJoin(community),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 12),
                Text(
                  'Suggested communities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final community in suggested) ...[
                  _CommunityCard(
                    community: community,
                    onTap: () => _openCommunity(community),
                    onToggleJoin: () => _toggleJoin(community),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('createCommunityButton'),
        tooltip: 'Create community',
        onPressed: _createCommunity,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({
    required this.community,
    required this.onTap,
    required this.onToggleJoin,
  });

  final Community community;
  final VoidCallback onTap;
  final VoidCallback onToggleJoin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      key: Key('communityCard_${community.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.brandDark.withValues(alpha: 0.2)
                    : AppColors.brand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                community.icon,
                color: isDark ? AppColors.brandDark : AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          community.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (community.isPrivate) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.lock_outline,
                          key: Key('privateIcon_${community.id}'),
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${community.memberCount} members',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildJoinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    final key = Key('joinButton_${community.id}');
    if (community.isJoined) {
      return OutlinedButton(
        key: key,
        onPressed: onToggleJoin,
        child: const Text('Joined'),
      );
    }
    if (community.isPrivate) {
      if (community.isPending) {
        return OutlinedButton(
          key: key,
          onPressed: onToggleJoin,
          child: const Text('Requested'),
        );
      }
      return FilledButton(
        key: key,
        onPressed: onToggleJoin,
        child: const Text('Request to Join'),
      );
    }
    return FilledButton(
      key: key,
      onPressed: onToggleJoin,
      child: const Text('Join'),
    );
  }
}
