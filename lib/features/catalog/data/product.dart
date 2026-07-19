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

  List<String> get galleryImages => List.generate(
    3,
    (index) => index < imageUrls.length
        ? imageUrls[index]
        : 'https://picsum.photos/seed/$id-gallery-${index + 1}/1200/900',
    growable: false,
  );
}
