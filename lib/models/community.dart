import 'package:flutter/material.dart';

class Community {
  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.memberCount,
    this.rules = const [],
    this.isJoined = false,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int memberCount;
  final List<String> rules;
  final bool isJoined;

  Community copyWith({bool? isJoined, int? memberCount}) => Community(
    id: id,
    name: name,
    description: description,
    icon: icon,
    memberCount: memberCount ?? this.memberCount,
    rules: rules,
    isJoined: isJoined ?? this.isJoined,
  );
}
