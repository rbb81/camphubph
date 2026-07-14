import 'package:latlong2/latlong.dart';

import '../models/camp.dart';

/// Placeholder camp directory. There's no `camps` schema in Supabase yet,
/// so this stands in for what a real Discover/Camp Details query will
/// eventually return — see docs/ux/wireframes.md "Discover" and
/// "Camp Details" sections.
final List<Camp> sampleCamps = [
  const Camp(
    id: 'daraitan',
    coordinates: LatLng(14.5995, 121.4574),
    name: 'Mt. Daraitan campsite',
    location: 'Tanay, Rizal',
    categories: ['Mountains', 'Camping Grounds'],
    rating: 4.6,
    reviewCount: 2,
    distanceKm: 62,
    priceLevel: 1,
    description:
        'A riverside campsite at the base of Mt. Daraitan, popular for its summit sunrise views and the Tinipak River crossing nearby.',
  ),
  const Camp(
    id: 'nasugbu-beach',
    coordinates: LatLng(14.0708, 120.6320),
    name: 'Nasugbu beach camp',
    location: 'Nasugbu, Batangas',
    categories: ['Beaches', 'Family Friendly'],
    rating: 4.3,
    reviewCount: 1,
    distanceKm: 105,
    priceLevel: 2,
    description:
        'A relaxed beachfront camp with calm waters, ideal for a weekend with the family. Gets crowded on holidays.',
  ),
  const Camp(
    id: 'taal-lake',
    coordinates: LatLng(13.8783, 120.9256),
    name: 'Taal Lake shoreline',
    location: 'Taal, Batangas',
    categories: ['Lakes', 'Weekend Getaways'],
    rating: 4.8,
    reviewCount: 1,
    distanceKm: 98,
    priceLevel: 1,
    description:
        'Quiet lakeside camping with a view of Taal Volcano across the water. Underrated for a low-key weekend trip.',
  ),
  const Camp(
    id: 'batangas-ridge',
    coordinates: LatLng(13.7565, 121.0583),
    name: 'Batangas Ridge',
    location: 'Batangas',
    categories: ['Mountains', 'Weekend Getaways'],
    rating: 4.5,
    reviewCount: 0,
    distanceKm: 88,
    priceLevel: 1,
    description:
        'A ridge-line trail with sweeping views best caught at sunrise. Moderate difficulty, good for a first overnight climb.',
  ),
  const Camp(
    id: 'masungi',
    coordinates: LatLng(14.5308, 121.2853),
    name: 'Masungi Georeserve',
    location: 'Baras, Rizal',
    categories: ['Forests', 'Family Friendly'],
    rating: 4.9,
    reviewCount: 1,
    distanceKm: 70,
    priceLevel: 3,
    description:
        'A managed forest reserve with rope bridges and canopy trails through limestone karst formations. Booking required.',
  ),
  const Camp(
    id: 'pagsanjan-river',
    coordinates: LatLng(14.2705, 121.4544),
    name: 'Pagsanjan River camp',
    location: 'Pagsanjan, Laguna',
    categories: ['Rivers', 'Budget Friendly'],
    rating: 4.1,
    reviewCount: 0,
    distanceKm: 110,
    priceLevel: 1,
    description:
        'A budget-friendly riverside spot near the falls, popular with student groups and first-time campers.',
  ),
  const Camp(
    id: 'chateau-glamp',
    coordinates: LatLng(14.0740, 120.6280),
    name: 'Chateau du Mer glamping',
    location: 'Nasugbu, Batangas',
    categories: ['Glamping', 'Weekend Getaways'],
    rating: 4.7,
    reviewCount: 1,
    distanceKm: 108,
    priceLevel: 3,
    description:
        'A glamping site with furnished tents overlooking the sea — showers, real beds, and a private beach access.',
  ),
  const Camp(
    id: 'overland-trail',
    coordinates: LatLng(14.7420, 121.4630),
    name: 'Sierra Madre overland trail',
    location: 'General Nakar, Quezon',
    categories: ['Overlanding', 'Mountains'],
    rating: 4.4,
    reviewCount: 0,
    distanceKm: 140,
    priceLevel: 2,
    description:
        '4x4 overland route through the Sierra Madre foothills with a basic campsite at the halfway point. High-clearance vehicles recommended.',
  ),
  const Camp(
    id: 'anawangin',
    coordinates: LatLng(14.9430, 120.1290),
    name: 'Anawangin Cove',
    location: 'San Antonio, Zambales',
    categories: ['Beaches', 'Budget Friendly'],
    rating: 4.5,
    reviewCount: 1,
    distanceKm: 190,
    priceLevel: 2,
    description:
        'A cove backed by a pine-tree grove, reachable by boat from Pundaquit. A classic budget beach-camping trip.',
  ),
  const Camp(
    id: 'sagada-pines',
    coordinates: LatLng(17.0797, 120.9010),
    name: 'Sagada Pine Forest camp',
    location: 'Sagada, Mountain Province',
    categories: ['Forests', 'Pet Friendly'],
    rating: 4.6,
    reviewCount: 0,
    distanceKm: 420,
    priceLevel: 2,
    description:
        'A cool, pine-scented campsite near Sagada town, welcoming of leashed pets and close to the hanging coffins trail.',
  ),
  const Camp(
    id: 'caliraya-lake',
    coordinates: LatLng(14.2967, 121.4869),
    name: 'Caliraya Lake camp',
    location: 'Lumban, Laguna',
    categories: ['Lakes', 'Family Friendly'],
    rating: 4.2,
    reviewCount: 0,
    distanceKm: 100,
    priceLevel: 2,
    description:
        'A family-friendly lake resort area with calm waters good for kayaking, plus open lawns for tents.',
  ),
  const Camp(
    id: 'puerto-galera',
    coordinates: LatLng(13.5083, 120.9540),
    name: 'Puerto Galera cliffside camp',
    location: 'Puerto Galera, Oriental Mindoro',
    categories: ['Beaches', 'Pet Friendly'],
    rating: 4.7,
    reviewCount: 1,
    distanceKm: 150,
    priceLevel: 2,
    description:
        'A cliffside camping spot with a private cove below, a short boat ride from the main Puerto Galera piers.',
  ),
];
