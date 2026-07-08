import '../models/camp.dart';

/// Placeholder camp directory. There's no `camps` schema in Supabase yet,
/// so this stands in for what a real Discover/Camp Details query will
/// eventually return — see docs/ux/wireframes.md "Discover" and
/// "Camp Details" sections.
final List<Camp> sampleCamps = [
  const Camp(
    id: 'daraitan',
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
