import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_tab_provider.dart';
import '../../../shared/store_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/category.dart';
import '../data/product.dart';
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
    void showCategories() => ref.read(mainTabProvider.notifier).select(1);

    return StorePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoreHeader(
            eyebrow: 'Curated for you',
            title: 'Good morning, $firstName',
            subtitle: 'Fresh finds, member offers and everyday essentials.',
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
          const SizedBox(height: 18),
          ProductSearchField(
            onChanged: ref.read(catalogSearchProvider.notifier).update,
          ),
          const SizedBox(height: 20),
          if (query.trim().isNotEmpty)
            _SearchResults(
              products: products,
              onClear: ref.read(catalogSearchProvider.notifier).clear,
            )
          else ...[
            _PromoCarousel(promos: promos, onShopNow: showCategories),
            const SizedBox(height: 20),
            const _BenefitStrip(),
            const SizedBox(height: 30),
            _SectionTitle(
              title: 'Shop by category',
              subtitle: 'Jump straight to what you love',
              action: 'View all',
              onAction: showCategories,
            ),
            const SizedBox(height: 14),
            SizedBox(
              key: const ValueKey('home-category-strip'),
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, index) => _CategoryCard(
                  category: categories[index],
                  onTap: () => Navigator.pushNamed(
                    context,
                    CategoryProductsScreen.routeName,
                    arguments: categories[index].id,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _SectionTitle(
              key: const ValueKey('home-trending-section'),
              title: 'Trending now',
              subtitle: 'Most-loved picks this week',
              action: 'See all',
              onAction: showCategories,
            ),
            const SizedBox(height: 14),
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
            if (products.length > 8) ...[
              const SizedBox(height: 30),
              _SectionTitle(
                title: 'New arrivals',
                subtitle: 'Just landed in the store',
                action: 'Explore',
                onAction: showCategories,
              ),
              const SizedBox(height: 14),
              _ProductGrid(
                key: const ValueKey('home-new-arrivals-grid'),
                products: products.skip(8).take(6).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.products, required this.onClear});

  final List<Product> products;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionTitle(
        title: '${products.length} results',
        subtitle: 'Products matching your search',
        action: 'Clear',
        onAction: onClear,
      ),
      const SizedBox(height: 14),
      if (products.isEmpty)
        const _EmptySearch()
      else
        _ProductGrid(products: products),
    ],
  );
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: products.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
      mainAxisExtent: 246,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
    ),
    itemBuilder: (_, index) =>
        ProductCard(product: products[index], width: double.infinity),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      if (action != null)
        TextButton.icon(
          onPressed: onAction,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 17),
          label: Text(action!),
        ),
    ],
  );
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel({required this.promos, required this.onShopNow});

  final List<Promo> promos;
  final VoidCallback onShopNow;

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .94);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('home-promo-carousel'),
    children: [
      SizedBox(
        height: 220,
        child: PageView.builder(
          controller: _controller,
          padEnds: false,
          itemCount: widget.promos.length,
          onPageChanged: (page) => setState(() => _currentPage = page),
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _PromoCard(
              promo: widget.promos[index],
              onShopNow: widget.onShopNow,
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Semantics(
        label: 'Promotion ${_currentPage + 1} of ${widget.promos.length}',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promos.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: index == _currentPage ? 24 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo, required this.onShopNow});

  final Promo promo;
  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: ValueKey('promo-card-${promo.badge}'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.secondary],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -34,
            child: Icon(
              promo.icon,
              size: 172,
              color: colors.onPrimary.withValues(alpha: .12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  promo.badge,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .9,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                promo.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                promo.subtitle,
                style: TextStyle(
                  color: colors.onPrimary.withValues(alpha: .84),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: ValueKey('promo-shop-${promo.badge}'),
                onPressed: onShopNow,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.onPrimary,
                  foregroundColor: colors.primary,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Shop now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitStrip extends StatelessWidget {
  const _BenefitStrip();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('home-benefit-strip'),
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Benefit(
              icon: Icons.local_shipping_outlined,
              label: 'Free delivery',
              color: colors.primary,
            ),
          ),
          _BenefitDivider(color: colors.outlineVariant),
          Expanded(
            child: _Benefit(
              icon: Icons.replay_rounded,
              label: 'Easy returns',
              color: colors.secondary,
            ),
          ),
          _BenefitDivider(color: colors.outlineVariant),
          Expanded(
            child: _Benefit(
              icon: Icons.verified_user_outlined,
              label: 'Secure pay',
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 22, color: color),
      const SizedBox(height: 5),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: color);
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Browse ${category.name}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 96,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(category.icon, color: category.color, size: 27),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
