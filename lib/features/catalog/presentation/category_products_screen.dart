import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/presentation/header_cart_button.dart';
import '../data/category.dart';
import 'catalog_providers.dart';
import 'product_card.dart';

class CategoryProductsScreen extends ConsumerWidget {
  const CategoryProductsScreen({super.key, required this.categoryId});
  static const routeName = '/category';
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    Category? category;
    for (final item in categories) {
      if (item.id == categoryId) category = item;
    }
    final products = ref.watch(categoryProductsProvider(categoryId));
    if (category == null) {
      return const Scaffold(body: Center(child: Text('Category not found')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: const [HeaderCartButton()],
      ),
      body: GridView.builder(
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
