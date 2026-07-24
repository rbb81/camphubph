import 'package:flutter/material.dart';

import '../models/community.dart';

/// Placeholder community directory. There's no `communities` schema in
/// Supabase yet — see docs/ux/wireframes.md "Communities (tab landing)" and
/// "Community Feed" sections.
final List<Community> sampleCommunities = [
  const Community(
    id: 'luzon-overlanders',
    name: 'Luzon Overlanders',
    description: 'Off-road and overlanding trips across Luzon.',
    icon: Icons.directions_car,
    memberCount: 1284,
    isJoined: true,
    rules: [
      'Be respectful — no gatekeeping newer overlanders.',
      'Tag trip reports with the route and vehicle type.',
      'No buy/sell posts — use the marketplace groups for that.',
    ],
  ),
  const Community(
    id: 'batangas-beach-campers',
    name: 'Batangas Beach Campers',
    description: 'Beach camping spots and tide reports around Batangas.',
    icon: Icons.beach_access,
    memberCount: 942,
    isJoined: true,
    rules: [
      'Pack out all trash — leave no trace.',
      'Share exact coordinates when posting a new spot.',
      'No open fires during dry-season burn bans.',
    ],
  ),
  const Community(
    id: 'trail-runners-ph',
    name: 'Trail Runners PH',
    description: 'Trail running routes, races, and gear talk.',
    icon: Icons.directions_run,
    memberCount: 2310,
    isJoined: true,
    rules: [
      'Post distance and elevation gain with every route.',
      'Flag hazardous trail conditions immediately.',
      'Keep race promo posts to the pinned megathread.',
    ],
  ),
  const Community(
    id: 'budget-backpackers-ph',
    name: 'Budget Backpackers PH',
    description: 'Camping and hiking on a shoestring budget.',
    icon: Icons.savings,
    memberCount: 1877,
    rules: [
      'Include a rough cost breakdown in trip posts.',
      'No promoting paid tour packages without disclosure.',
    ],
  ),
  const Community(
    id: 'family-campers-ph',
    name: 'Family Campers PH',
    description: 'Kid-friendly campsites and family trip planning.',
    icon: Icons.family_restroom,
    memberCount: 1532,
    rules: [
      'Keep recommendations family- and kid-friendly.',
      'Note nearby medical facilities for remote sites.',
      'Be kind — first-time camping parents ask a lot of questions here.',
    ],
  ),
  const Community(
    id: 'glamping-philippines',
    name: 'Glamping Philippines',
    description: 'Glamping resorts, reviews, and booking tips.',
    icon: Icons.cottage,
    memberCount: 764,
    rules: [
      'Disclose sponsored stays.',
      'Post current pricing where possible — it changes often.',
    ],
  ),
  const Community(
    id: 'rizal-weekend-warriors',
    name: 'Rizal Weekend Warriors',
    description: 'Quick weekend camping trips within Rizal province.',
    icon: Icons.weekend,
    memberCount: 1093,
    rules: [
      'Weekend-trip posts only — day hikes go to the hiking groups.',
      'Carpool offers welcome, coordinate via comments.',
    ],
  ),
  const Community(
    id: 'palawan-dreamers',
    name: 'Palawan Dreamers',
    description: 'Planning trips to Palawan\'s islands and campsites.',
    icon: Icons.terrain,
    memberCount: 3021,
    isPrivate: true,
    rules: [
      'Check permit requirements before posting a route.',
      'Respect marine sanctuary and no-camping zones.',
      'No unauthorized tour operator ads.',
    ],
  ),
  const Community(
    id: 'bicol-volcano-trekkers',
    name: 'Bicol Volcano Trekkers',
    description: 'Mayon and Bulusan trail conditions, permits, and meetups.',
    icon: Icons.terrain,
    memberCount: 87,
    isPrivate: true,
    isJoined: true,
    rules: [
      'Share permit/guide contact info responsibly.',
      'No unauthorized tour operator ads.',
    ],
  ),
];
