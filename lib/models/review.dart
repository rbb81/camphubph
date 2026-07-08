import 'dart:typed_data';

class Review {
  const Review({
    required this.id,
    required this.campId,
    required this.authorName,
    required this.authorInitials,
    required this.rating,
    required this.visitDate,
    required this.postedAgo,
    this.pros = const [],
    this.cons = const [],
    this.tip,
    this.photoBytes,
  });

  final String id;
  final String campId;
  final String authorName;
  final String authorInitials;
  final int rating;
  final DateTime visitDate;
  final String postedAgo;
  final List<String> pros;
  final List<String> cons;
  final String? tip;
  final Uint8List? photoBytes;
}
