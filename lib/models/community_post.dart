class CommunityFeedPost {
  const CommunityFeedPost({
    required this.id,
    required this.communityId,
    required this.authorName,
    required this.authorInitials,
    required this.timeAgo,
    required this.body,
    required this.likeCount,
    required this.commentCount,
    this.isPinned = false,
    this.isModerator = false,
    this.isLiked = false,
  });

  final String id;
  final String communityId;
  final String authorName;
  final String authorInitials;
  final String timeAgo;
  final String body;
  final int likeCount;
  final int commentCount;
  final bool isPinned;
  final bool isModerator;
  final bool isLiked;

  CommunityFeedPost copyWith({bool? isLiked, int? likeCount}) =>
      CommunityFeedPost(
        id: id,
        communityId: communityId,
        authorName: authorName,
        authorInitials: authorInitials,
        timeAgo: timeAgo,
        body: body,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount,
        isPinned: isPinned,
        isModerator: isModerator,
        isLiked: isLiked ?? this.isLiked,
      );
}
