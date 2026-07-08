import '../models/community_member.dart';

/// Placeholder community rosters, keyed by `Community.id`. There's no
/// `community_members` schema in Supabase yet — see docs/ux/wireframes.md
/// "Community Feed" section (Members tab).
final List<CommunityMember> sampleCommunityMembers = [
  const CommunityMember(
    communityId: 'luzon-overlanders',
    name: 'Rico Fernandez',
    initials: 'RF',
    role: CommunityRole.moderator,
  ),
  const CommunityMember(
    communityId: 'luzon-overlanders',
    name: 'Ana Dela Cruz',
    initials: 'AD',
    role: CommunityRole.member,
  ),
  const CommunityMember(
    communityId: 'luzon-overlanders',
    name: 'Miguel Ibarra',
    initials: 'MI',
    role: CommunityRole.member,
  ),
  const CommunityMember(
    communityId: 'batangas-beach-campers',
    name: 'Liza Santos',
    initials: 'LS',
    role: CommunityRole.moderator,
  ),
  const CommunityMember(
    communityId: 'batangas-beach-campers',
    name: 'Paolo Reyes',
    initials: 'PR',
    role: CommunityRole.member,
  ),
  const CommunityMember(
    communityId: 'trail-runners-ph',
    name: 'Carla Mendoza',
    initials: 'CM',
    role: CommunityRole.moderator,
  ),
  const CommunityMember(
    communityId: 'trail-runners-ph',
    name: 'Jomari Cruz',
    initials: 'JC',
    role: CommunityRole.moderator,
  ),
  const CommunityMember(
    communityId: 'trail-runners-ph',
    name: 'Bea Villanueva',
    initials: 'BV',
    role: CommunityRole.member,
  ),
];
