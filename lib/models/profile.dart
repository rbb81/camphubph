import 'dart:typed_data';

enum ExperienceLevel { beginner, intermediate, expert }

extension ExperienceLevelLabel on ExperienceLevel {
  String get label => switch (this) {
    ExperienceLevel.beginner => 'Beginner',
    ExperienceLevel.intermediate => 'Intermediate',
    ExperienceLevel.expert => 'Expert',
  };
}

const List<String> kCampingStyleCatalog = [
  'Car camping',
  'Backpacking',
  'Overlanding',
  'Beach camping',
  'Mountain climbing',
  'Glamping',
  'Family camping',
  'Solo camping',
];

class UserProfile {
  const UserProfile({
    required this.name,
    required this.initials,
    required this.bio,
    required this.experienceLevel,
    required this.favoriteStyles,
    required this.followerCount,
    required this.followingCount,
    this.avatarBytes,
    this.coverBytes,
  });

  final String name;
  final String initials;
  final String bio;
  final ExperienceLevel experienceLevel;
  final List<String> favoriteStyles;
  final int followerCount;
  final int followingCount;
  final Uint8List? avatarBytes;
  final Uint8List? coverBytes;

  UserProfile copyWith({
    String? name,
    String? bio,
    ExperienceLevel? experienceLevel,
    List<String>? favoriteStyles,
    Uint8List? avatarBytes,
    Uint8List? coverBytes,
  }) => UserProfile(
    name: name ?? this.name,
    initials: initials,
    bio: bio ?? this.bio,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    favoriteStyles: favoriteStyles ?? this.favoriteStyles,
    followerCount: followerCount,
    followingCount: followingCount,
    avatarBytes: avatarBytes ?? this.avatarBytes,
    coverBytes: coverBytes ?? this.coverBytes,
  );
}

sealed class ProfileTabItem {
  const ProfileTabItem();
}

class ProfilePostItem extends ProfileTabItem {
  const ProfilePostItem({required this.caption, required this.timeAgo});

  final String caption;
  final String timeAgo;
}

class ProfilePhotoItem extends ProfileTabItem {
  const ProfilePhotoItem({required this.caption});

  final String caption;
}

class ProfileReviewItem extends ProfileTabItem {
  const ProfileReviewItem({
    required this.campName,
    required this.rating,
    required this.snippet,
  });

  final String campName;
  final double rating;
  final String snippet;
}

class ProfileSavedCampItem extends ProfileTabItem {
  const ProfileSavedCampItem({required this.name, required this.location});

  final String name;
  final String location;
}

class ProfileWishlistItem extends ProfileTabItem {
  const ProfileWishlistItem({required this.name, required this.location});

  final String name;
  final String location;
}

class ProfileCompletedTripItem extends ProfileTabItem {
  const ProfileCompletedTripItem({required this.name, required this.dateLabel});

  final String name;
  final String dateLabel;
}
