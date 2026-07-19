import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/store_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/promo.dart';
import 'catalog_providers.dart';
import 'category_products_screen.dart';
import 'product_card.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final query = ref.watch(catalogSearchProvider);
    final products = ref.watch(searchResultsProvider);
    final categories = ref.watch(categoriesProvider);
    final promos = ref.watch(catalogRepositoryProvider).promos;
    final firstName = user?.name.split(' ').first ?? 'there';
    return StorePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoreHeader(
            eyebrow: 'Everyday edit',
            title: 'Good morning, $firstName',
            subtitle: 'Find something thoughtful for your everyday.',
            trailing: IconButton.filledTonal(
              tooltip: 'Scan product',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product scanning is unavailable offline.'),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded),
            ),
          ),
          const SizedBox(height: 20),
          ProductSearchField(
            onChanged: ref.read(catalogSearchProvider.notifier).update,
          ),
          const SizedBox(height: 20),
          if (query.trim().isNotEmpty) ...[
            _SectionTitle(
              title: '${products.length} results',
              action: 'Clear',
              onAction: ref.read(catalogSearchProvider.notifier).clear,
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const _EmptySearch()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width >= 700
                      ? 3
                      : 2,
                  mainAxisExtent: 246,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (_, index) => ProductCard(
                  product: products[index],
                  width: double.infinity,
                ),
              ),
          ] else ...[
            SizedBox(
              height: 190,
              child: PageView.builder(
                itemCount: promos.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _PromoCard(promo: promos[index]),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const _SectionTitle(title: 'Shop by mood'),
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final category = categories[index];
                  return InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      CategoryProductsScreen.routeName,
                      arguments: category.id,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 76,
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(category.icon, color: category.color),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            const _SectionTitle(title: 'Popular right now'),
            const SizedBox(height: 12),
            SizedBox(
              height: 246,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.take(8).length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, index) =>
                    ProductCard(product: products[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});
  final Promo promo;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: promo.color,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -26,
          bottom: -36,
          child: Icon(
            promo.icon,
            size: 168,
            color: Colors.white.withValues(alpha: .12),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promo.badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              promo.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              promo.subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: .82)),
            ),
          ],
        ),
      ],
    ),
  );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 56),
    child: Column(
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 52,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        const Text(
          'No products found',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text('Try a shorter or different search.'),
      ],
    ),
  );
}
