class Comment {
  const Comment({
    required this.authorName,
    required this.authorInitials,
    required this.text,
    required this.timeAgo,
  });

  final String authorName;
  final String authorInitials;
  final String text;
  final String timeAgo;
}
