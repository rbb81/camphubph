import 'package:flutter/material.dart';

class DiscoverCategory {
  const DiscoverCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

const List<DiscoverCategory> kDiscoverCategories = [
  DiscoverCategory('Mountains', Icons.terrain),
  DiscoverCategory('Beaches', Icons.beach_access),
  DiscoverCategory('Lakes', Icons.water),
  DiscoverCategory('Forests', Icons.forest),
  DiscoverCategory('Rivers', Icons.water_drop),
  DiscoverCategory('Camping Grounds', Icons.holiday_village),
  DiscoverCategory('Glamping', Icons.cottage),
  DiscoverCategory('Overlanding', Icons.directions_car),
  DiscoverCategory('Pet Friendly', Icons.pets),
  DiscoverCategory('Family Friendly', Icons.family_restroom),
  DiscoverCategory('Weekend Getaways', Icons.weekend),
  DiscoverCategory('Budget Friendly', Icons.savings),
];

class Camp {
  const Camp({
    required this.id,
    required this.name,
    required this.location,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.priceLevel,
    required this.description,
  });

  final String id;
  final String name;
  final String location;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int priceLevel;
  final String description;

  IconData get primaryIcon => kDiscoverCategories
      .firstWhere(
        (c) => c.label == categories.first,
        orElse: () => const DiscoverCategory('Camping Grounds', Icons.terrain),
      )
      .icon;

  Camp copyWith({double? rating, int? reviewCount}) => Camp(
    id: id,
    name: name,
    location: location,
    categories: categories,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
    distanceKm: distanceKm,
    priceLevel: priceLevel,
    description: description,
  );
}
