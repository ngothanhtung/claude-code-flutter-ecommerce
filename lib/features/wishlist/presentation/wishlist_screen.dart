import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/presentation/header_cart_button.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../catalog/presentation/product_card.dart';
import 'wishlist_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});
  static const routeName = '/wishlist';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(wishlistProvider);
    final products = ref
        .watch(productsProvider)
        .where((product) => ids.contains(product.id))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved items'),
        actions: const [HeaderCartButton()],
      ),
      body: products.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_outline_rounded, size: 58),
                  SizedBox(height: 12),
                  Text(
                    'Your wishlist is ready for inspiration',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
                mainAxisExtent: 246,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (_, index) =>
                  ProductCard(product: products[index], width: double.infinity),
            ),
    );
  }
}
