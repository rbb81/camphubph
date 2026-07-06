sealed class HomeFeedItem {
  const HomeFeedItem();
}

class FriendPostItem extends HomeFeedItem {
  const FriendPostItem({
    required this.authorName,
    required this.authorInitials,
    required this.timeAgo,
    required this.location,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
  });

  final String authorName;
  final String authorInitials;
  final String timeAgo;
  final String location;
  final String caption;
  final int likeCount;
  final int commentCount;
}

class CommunityPostItem extends HomeFeedItem {
  const CommunityPostItem({
    required this.communityName,
    required this.authorName,
    required this.snippet,
  });

  final String communityName;
  final String authorName;
  final String snippet;
}

class RecommendedCampItem extends HomeFeedItem {
  const RecommendedCampItem({
    required this.name,
    required this.location,
    required this.rating,
    required this.distanceKm,
  });

  final String name;
  final String location;
  final double rating;
  final double distanceKm;
}

class TipItem extends HomeFeedItem {
  const TipItem(this.tip);

  final String tip;
}

class SuggestedUserItem extends HomeFeedItem {
  const SuggestedUserItem({
    required this.name,
    required this.initials,
    required this.subtitle,
  });

  final String name;
  final String initials;
  final String subtitle;
}
