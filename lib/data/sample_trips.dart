import '../models/trip.dart';

/// Placeholder trip schedule. There's no `trips` schema in Supabase yet.
///
/// Mutated in place (`sampleTrips.add(...)`), not copied-then-mutated like
/// `sample_communities.dart` — Add to Trip (pushed from Camp Details) and
/// My Trips (pushed from Profile) are independently-pushed screens that both
/// need to see every trip for conflict-checking, and there's no shared state
/// layer in this app otherwise.
final List<Trip> sampleTrips = [
  Trip(
    id: 'trip_seed_upcoming',
    campId: 'daraitan',
    campName: 'Mt. Daraitan campsite',
    campLocation: 'Tanay, Rizal',
    startDate: DateTime.now().add(const Duration(days: 14)),
    endDate: DateTime.now().add(const Duration(days: 16)),
  ),
  Trip(
    id: 'trip_seed_past',
    campId: 'taal-lake',
    campName: 'Taal Lake shoreline',
    campLocation: 'Taal, Batangas',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().subtract(const Duration(days: 28)),
  ),
];
