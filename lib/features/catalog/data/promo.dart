import 'package:flutter/material.dart';

class Promo {
  const Promo(this.badge, this.title, this.subtitle, this.icon);

  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;

  factory Promo.fromJson(Map<String, dynamic> json) => Promo(
    json['badge'] as String,
    json['title'] as String,
    json['subtitle'] as String,
    switch (json['icon_name']) {
      'checkroom' => Icons.checkroom_rounded,
      'chair_alt' => Icons.chair_alt_rounded,
      'local_shipping' => Icons.local_shipping_rounded,
      'local_offer' => Icons.local_offer_rounded,
      'sell' => Icons.sell_rounded,
      'trending_up' => Icons.trending_up_rounded,
      _ => Icons.local_offer_rounded,
    },
  );
}
