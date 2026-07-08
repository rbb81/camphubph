enum CommunityRole { moderator, member }

class CommunityMember {
  const CommunityMember({
    required this.communityId,
    required this.name,
    required this.initials,
    required this.role,
  });

  final String communityId;
  final String name;
  final String initials;
  final CommunityRole role;
}
