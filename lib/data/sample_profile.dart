import '../models/profile.dart';

/// Placeholder "own profile" content. There's no `profiles` schema in
/// Supabase yet, so this stands in for what a real profile query will
/// eventually return — see docs/ux/wireframes.md "Profile" section.
final sampleProfile = UserProfile(
  name: 'Ana Dela Cruz',
  initials: 'AD',
  bio:
      'Weekend warrior chasing sunrises across Luzon. Always down for a river crossing.',
  experienceLevel: ExperienceLevel.intermediate,
  favoriteStyles: const ['Mountain climbing', 'Car camping', 'Beach camping'],
  followerCount: 482,
  followingCount: 213,
);

final List<ProfilePostItem> sampleProfilePosts = [
  const ProfilePostItem(
    caption:
        'Made it to the summit just in time for sunrise. Worth every step.',
    timeAgo: '2d',
  ),
  const ProfilePostItem(
    caption: 'Rainy season river crossing at Nasugbu — pack that dry bag.',
    timeAgo: '1w',
  ),
];

final List<ProfilePhotoItem> sampleProfilePhotos = [
  const ProfilePhotoItem(caption: 'Sunrise at Mt. Daraitan'),
  const ProfilePhotoItem(caption: 'Campfire night, Taal Lake'),
  const ProfilePhotoItem(caption: 'River crossing, Nasugbu'),
  const ProfilePhotoItem(caption: 'Trail mix break'),
];

final List<ProfileReviewItem> sampleProfileReviews = [
  const ProfileReviewItem(
    campName: 'Mt. Daraitan campsite',
    rating: 4.6,
    snippet:
        'Well-maintained trail and a stunning summit view. Bring extra water.',
  ),
  const ProfileReviewItem(
    campName: 'Nasugbu beach camp',
    rating: 4.3,
    snippet: 'Great for a relaxed weekend, gets crowded on holidays.',
  ),
];

final List<ProfileSavedCampItem> sampleSavedCamps = [
  const ProfileSavedCampItem(
    name: 'Mt. Daraitan campsite',
    location: 'Tanay, Rizal',
  ),
  const ProfileSavedCampItem(
    name: 'Nasugbu beach camp',
    location: 'Nasugbu, Batangas',
  ),
];

final List<ProfileWishlistItem> sampleWishlist = [
  const ProfileWishlistItem(name: 'Batangas Ridge', location: 'Batangas'),
  const ProfileWishlistItem(
    name: 'Taal Lake shoreline',
    location: 'Taal, Batangas',
  ),
];

final List<ProfileCompletedTripItem> sampleCompletedTrips = [
  const ProfileCompletedTripItem(
    name: 'Mt. Daraitan weekend climb',
    dateLabel: 'March 2026',
  ),
  const ProfileCompletedTripItem(
    name: 'Taal Lake camp with the crew',
    dateLabel: 'January 2026',
  ),
];
