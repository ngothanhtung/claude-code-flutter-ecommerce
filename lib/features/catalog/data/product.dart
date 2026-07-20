import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.description,
    this.imageUrls = const [],
  });

  final String id;
  final String name;
  final double price;
  final double rating;
  final int reviews;
  final IconData icon;
  final Color color;
  final String categoryId;
  final String description;
  final List<String> imageUrls;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    reviews: json['reviews_count'] as int,
    icon: productIconFromName(json['icon_name'] as String? ?? ''),
    color: colorFromHex(json['color_hex'] as String? ?? '#13795B'),
    categoryId: json['category_id'] as String,
    description: json['description'] as String? ?? '',
    imageUrls: (json['image_urls'] as List? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );

  List<String> get galleryImages => List.generate(
    3,
    (index) => index < imageUrls.length
        ? imageUrls[index]
        : 'https://picsum.photos/seed/$id-gallery-${index + 1}/1200/900',
    growable: false,
  );
}

Color colorFromHex(String value) {
  final hex = value.replaceFirst('#', '');
  final normalized = hex.length == 6 ? 'FF$hex' : hex;
  return Color(int.tryParse(normalized, radix: 16) ?? 0xFF13795B);
}

IconData productIconFromName(String value) => switch (value) {
  'directions_run' => Icons.directions_run_rounded,
  'checkroom' => Icons.checkroom_rounded,
  'water_drop' => Icons.water_drop_rounded,
  'headphones' => Icons.headphones_rounded,
  'devices' => Icons.devices_rounded,
  'dry_cleaning' => Icons.dry_cleaning_rounded,
  'shopping_bag' => Icons.shopping_bag_rounded,
  'ice_skating' => Icons.ice_skating_rounded,
  'speaker' => Icons.speaker_rounded,
  'keyboard' => Icons.keyboard_rounded,
  'light' => Icons.light_rounded,
  'battery_charging_full' => Icons.battery_charging_full_rounded,
  'chair' => Icons.chair_rounded,
  'home' => Icons.home_rounded,
  'bed' => Icons.bed_rounded,
  'air' => Icons.air_rounded,
  'dinner_dining' => Icons.dinner_dining_rounded,
  'brush' => Icons.brush_rounded,
  'bubble_chart' => Icons.bubble_chart_rounded,
  'local_fire_department' => Icons.local_fire_department_rounded,
  'self_improvement' => Icons.self_improvement_rounded,
  'linear_scale' => Icons.linear_scale_rounded,
  'sports_gymnastics' => Icons.sports_gymnastics_rounded,
  'sports_soccer' => Icons.sports_soccer_rounded,
  'backpack' => Icons.backpack_rounded,
  'bedtime' => Icons.bedtime_rounded,
  'flight' => Icons.flight_rounded,
  _ => Icons.inventory_2_rounded,
};
