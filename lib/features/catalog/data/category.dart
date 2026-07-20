import 'package:flutter/material.dart';

import 'product.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: switch (json['icon_name']) {
      'checkroom' => Icons.checkroom_rounded,
      'devices' => Icons.devices_rounded,
      'chair_alt' => Icons.chair_alt_rounded,
      'home' => Icons.home_rounded,
      'spa' => Icons.spa_rounded,
      'fitness_center' => Icons.fitness_center_rounded,
      'sports_soccer' => Icons.sports_soccer_rounded,
      'luggage' => Icons.luggage_rounded,
      'flight' => Icons.flight_rounded,
      _ => Icons.category_rounded,
    },
    color: colorFromHex(json['color_hex'] as String? ?? '#13795B'),
  );
}
