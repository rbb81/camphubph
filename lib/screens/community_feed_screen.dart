import 'package:flutter/material.dart';

import '../data/sample_community_members.dart';
import '../data/sample_community_posts.dart';
import '../data/sample_profile.dart';
import '../models/community.dart';
import '../models/community_member.dart';
import '../models/community_post.dart';
import '../theme/app_theme.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key, required this.community});

  final Community community;

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen>
    with SingleTickerProviderStateMixin {
  static const _tabLabels = ['Feed', 'Rules', 'Members'];

  late final TabController _tabController;
  late Community _community;
  late List<CommunityFeedPost> _posts;
  late List<CommunityMember> _members;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _community = widget.community;
    _posts = sampleCommunityPosts
        .where((p) => p.communityId == _community.id)
        .toList();
    _members = sampleCommunityMembers
        .where((m) => m.communityId == _community.id)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  void _toggleJoin() {
    if (_community.isPrivate && !_community.isJoined) {
      _toggleJoinRequest();
      return;
    }
    setState(() {
      _community = _community.copyWith(
        isJoined: !_community.isJoined,
        memberCount: _community.isJoined
            ? _community.memberCount - 1
            : _community.memberCount + 1,
      );
    });
  }

  void _toggleJoinRequest() {
    if (_community.isPending) {
      setState(() {
        _community = _community.copyWith(isPending: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Canceled your request to join ${_community.name}.'),
        ),
      );
      return;
    }

    setState(() {
      _community = _community.copyWith(isPending: true);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent to join ${_community.name}.')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (!_community.isPending) return;
      setState(() {
        _community = _community.copyWith(
          isPending: false,
          isJoined: true,
          memberCount: _community.memberCount + 1,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your request to join ${_community.name} was approved!',
          ),
        ),
      );
    });
  }

  void _toggleLike(int index) {
    final post = _posts[index];
    setState(() {
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
      );
    });
  }

  Future<void> _composePost() async {
    if (!_community.isJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Join ${_community.name} to post.')),
      );
      return;
    }
    final controller = TextEditingController();
    final body = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post to ${_community.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('composePostField'),
              controller: controller,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('submitPostButton'),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(sheetContext).pop(text);
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
    if (body == null) return;
    setState(() {
      _posts.insert(
        0,
        CommunityFeedPost(
          id: 'new-${DateTime.now().microsecondsSinceEpoch}',
          communityId: _community.id,
          authorName: sampleProfile.name,
          authorInitials: sampleProfile.initials,
          timeAgo: 'now',
          body: body,
          likeCount: 0,
          commentCount: 0,
        ),
      );
    });
  }

  Widget _buildJoinButton() {
    const key = Key('feedJoinButton');
    if (_community.isJoined) {
      return OutlinedButton(
        key: key,
        onPressed: _toggleJoin,
        child: const Text('Joined'),
      );
    }
    if (_community.isPrivate) {
      if (_community.isPending) {
        return OutlinedButton(
          key: key,
          onPressed: _toggleJoin,
          child: const Text('Requested'),
        );
      }
      return FilledButton(
        key: key,
        onPressed: _toggleJoin,
        child: const Text('Request to Join'),
      );
    }
    return FilledButton(
      key: key,
      onPressed: _toggleJoin,
      child: const Text('Join'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinned = _posts.where((p) => p.isPinned).toList();
    final regular = _posts.where((p) => !p.isPinned).toList();
    final orderedPosts = [...pinned, ...regular];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_community);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(_community.name, overflow: TextOverflow.ellipsis),
              ),
              if (_community.isPrivate) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.lock_outline,
                  key: Key('feedPrivateIcon'),
                  size: 16,
                ),
              ],
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: _buildJoinButton()),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedTab(
                    posts: orderedPosts,
                    onLike: (post) =>
                        _toggleLike(_posts.indexWhere((p) => p.id == post.id)),
                    onComment: () => _comingSoon('Comments'),
                  ),
                  _RulesTab(rules: _community.rules),
                  _MembersTab(members: _members),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: const Key('newPostButton'),
          onPressed: _composePost,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.posts,
    required this.onLike,
    required this.onComment,
  });

  final List<CommunityFeedPost> posts;
  final ValueChanged<CommunityFeedPost> onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts yet — be the first to post.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _CommunityPostCard(
          post: post,
          onLike: () => onLike(post),
          onComment: onComment,
        );
      },
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  final CommunityFeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    return Container(
      key: Key('communityPostCard_${post.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: post.isPinned
            ? accent.withValues(alpha: 0.08)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isPinned)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 14, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? AppColors.brandDark.withValues(alpha: 0.25)
                    : AppColors.brand.withValues(alpha: 0.12),
                child: Text(
                  post.authorInitials,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (post.isModerator) ...[
                          const SizedBox(width: 6),
                          _ModeratorBadge(accent: accent),
                        ],
                      ],
                    ),
                    Text(
                      post.timeAgo,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.body),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                key: Key('communityLikeButton_${post.id}'),
                onTap: onLike,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: post.isLiked ? Colors.red : null,
                  ),
                ),
              ),
              Text('${post.likeCount}'),
              const SizedBox(width: 12),
              InkWell(
                key: Key('communityCommentButton_${post.id}'),
                onTap: onComment,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.mode_comment_outlined, size: 18),
                ),
              ),
              Text('${post.commentCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeratorBadge extends StatelessWidget {
  const _ModeratorBadge({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'MOD',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}

class _RulesTab extends StatelessWidget {
  const _RulesTab({required this.rules});

  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return const Center(
        child: Text(
          'No rules posted yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rules.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(radius: 12, child: Text('${index + 1}')),
        title: Text(rules[index]),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.members});

  final List<CommunityMember> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
        child: Text(
          'No members to show yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    final moderators = members
        .where((m) => m.role == CommunityRole.moderator)
        .toList();
    final regular = members
        .where((m) => m.role == CommunityRole.member)
        .toList();
    final ordered = [...moderators, ...regular];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ordered.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final member = ordered[index];
        return ListTile(
          leading: CircleAvatar(child: Text(member.initials)),
          title: Text(member.name),
          trailing: member.role == CommunityRole.moderator
              ? _ModeratorBadge(
                  accent: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.brandDark
                      : AppColors.brand,
                )
              : null,
        );
      },
    );
  }
}
