import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/store_scaffold.dart';
import '../data/category.dart';
import 'catalog_providers.dart';
import 'category_products_screen.dart';

class CategoriesTab extends ConsumerWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final width = MediaQuery.sizeOf(context).width;
    return StorePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StoreHeader(
            eyebrow: 'Discover',
            title: 'Categories',
            subtitle: 'Curated collections for every part of your day.',
          ),
          const SizedBox(height: 22),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width >= 700 ? 3 : 2,
              mainAxisExtent: 174,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (_, index) {
              final category = categories[index];
              final count = products
                  .where((product) => product.categoryId == category.id)
                  .length;
              return _CategoryCard(category: category, count: count);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.count});
  final Category category;
  final int count;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      key: ValueKey('category-${category.id}'),
      onTap: () => Navigator.pushNamed(
        context,
        CategoryProductsScreen.routeName,
        arguments: category.id,
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(category.icon, color: category.color),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
            const Spacer(),
            Text(
              category.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              '$count products',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
