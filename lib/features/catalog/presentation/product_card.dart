import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/currency.dart';
import '../../wishlist/presentation/wishlist_providers.dart';
import '../data/product.dart';
import 'product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.width = 174});

  final Product product;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final saved = ref.watch(wishlistProvider).contains(product.id);
    return InkWell(
      key: ValueKey('product-card-${product.id}'),
      onTap: () => Navigator.pushNamed(
        context,
        ProductDetailScreen.routeName,
        arguments: product.id,
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: product.color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(product.icon, size: 58, color: product.color),
                  ),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: IconButton.filled(
                      key: ValueKey('wishlist-${product.id}'),
                      tooltip: saved
                          ? 'Remove from saved items'
                          : 'Save ${product.name}',
                      onPressed: () => ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id),
                      icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 19,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: saved
                            ? colors.error
                            : colors.onSurface,
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 16, color: colors.tertiary),
                const SizedBox(width: 3),
                Text(
                  '${product.rating} · ${product.reviews}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatCurrency(product.price),
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
