import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/community_post.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../widgets/hashtag_mention_text.dart';

/// Mirrors `post_details_screen.dart`'s shape (like toggle, flat comment
/// list, composer) for a `CommunityFeedPost` instead of a `FriendPostItem` —
/// kept as a separate screen rather than a shared one since the two post
/// types are unrelated models with different display needs (pinned/
/// moderator badges here, photo/location there), per this app's
/// no-shared-tile-widget convention.
class CommunityPostDetailsScreen extends StatefulWidget {
  const CommunityPostDetailsScreen({
    super.key,
    required this.post,
    required this.currentUser,
  });

  final CommunityFeedPost post;
  final UserProfile currentUser;

  @override
  State<CommunityPostDetailsScreen> createState() =>
      _CommunityPostDetailsScreenState();
}

class _CommunityPostDetailsScreenState
    extends State<CommunityPostDetailsScreen> {
  final _commentController = TextEditingController();
  late CommunityFeedPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _post = _post.copyWith(
        isLiked: !_post.isLiked,
        likeCount: _post.isLiked ? _post.likeCount - 1 : _post.likeCount + 1,
      );
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _post = _post.copyWith(
        comments: [
          ..._post.comments,
          Comment(
            authorName: widget.currentUser.name,
            authorInitials: widget.currentUser.initials,
            text: text,
            timeAgo: 'Just now',
          ),
        ],
        commentCount: _post.commentCount + 1,
      );
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_post);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildPost(context),
                        const SizedBox(height: 16),
                        const Divider(),
                        _buildComments(context),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildComposer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPost(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.brandDark : AppColors.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_post.isPinned)
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
            _Avatar(_post.authorInitials),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (_post.isModerator) ...[
                        const SizedBox(width: 6),
                        _ModeratorBadge(accent: accent),
                      ],
                    ],
                  ),
                  Text(
                    _post.timeAgo,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HashtagMentionText(
          _post.body,
          onHashtagTap: (tag) => openHashtagSearch(context, tag),
          onMentionTap: (handle) => openMentionedProfile(context, handle),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              key: const Key('likeButton'),
              onPressed: _toggleLike,
              icon: Icon(
                _post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: _post.isLiked
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            Text('${_post.likeCount}'),
            const SizedBox(width: 12),
            const Icon(Icons.mode_comment_outlined, size: 18),
            const SizedBox(width: 4),
            Text('${_post.commentCount}'),
          ],
        ),
      ],
    );
  }

  Widget _buildComments(BuildContext context) {
    if (_post.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No comments yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(
      children: [
        for (final comment in _post.comments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(comment.authorInitials),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.authorName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment.timeAgo,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      HashtagMentionText(
                        comment.text,
                        onHashtagTap: (tag) => openHashtagSearch(context, tag),
                        onMentionTap: (handle) =>
                            openMentionedProfile(context, handle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('commentField'),
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                isDense: true,
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          IconButton(
            key: const Key('sendCommentButton'),
            tooltip: 'Send comment',
            onPressed: _submitComment,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.initials);

  final String initials;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: 18,
      backgroundColor: isDark
          ? AppColors.brandDark.withValues(alpha: 0.25)
          : AppColors.brand.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: isDark ? AppColors.brandDark : AppColors.brand,
        ),
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
