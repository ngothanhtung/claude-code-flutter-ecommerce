import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/currency.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../cart/presentation/header_cart_button.dart';
import '../../wishlist/presentation/wishlist_providers.dart';
import 'catalog_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  static const routeName = '/product';
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final galleryController = PageController();
  int quantity = 1;
  int selectedImage = 0;
  bool adding = false;

  @override
  void dispose() {
    galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productProvider(widget.productId));
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }
    final colors = Theme.of(context).colorScheme;
    final saved = ref.watch(wishlistProvider).contains(product.id);
    final images = product.galleryImages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          const HeaderCartButton(),
          IconButton(
            key: ValueKey('wishlist-${product.id}'),
            tooltip: saved ? 'Remove from saved items' : 'Save item',
            onPressed: () =>
                ref.read(wishlistProvider.notifier).toggle(product.id),
            icon: Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved ? colors.error : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
              children: [
                _ProductGallery(
                  productName: product.name,
                  imageUrls: images,
                  fallbackIcon: product.icon,
                  fallbackColor: product.color,
                  controller: galleryController,
                  selectedIndex: selectedImage,
                  onPageChanged: (index) =>
                      setState(() => selectedImage = index),
                  onThumbnailPressed: (index) {
                    if (index == selectedImage) return;
                    final reduceMotion = MediaQuery.of(
                      context,
                    ).disableAnimations;
                    setState(() => selectedImage = index);
                    if (reduceMotion) {
                      galleryController.jumpToPage(index);
                    } else {
                      galleryController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      formatCurrency(product.price),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: colors.tertiary),
                    const SizedBox(width: 5),
                    Text(
                      '${product.rating} · ${product.reviews} reviews',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Designed for your everyday',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton.outlined(
                      key: const ValueKey('quantity-minus'),
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      key: const ValueKey('quantity-plus'),
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: FilledButton.icon(
            key: const ValueKey('add-to-cart-button'),
            onPressed: adding
                ? null
                : () async {
                    setState(() => adding = true);
                    await ref
                        .read(cartProvider.notifier)
                        .add(product.id, quantity: quantity);
                    if (!context.mounted) return;
                    setState(() => adding = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$quantity × ${product.name} added to cart',
                        ),
                      ),
                    );
                  },
            icon: adding
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.shopping_bag_outlined),
            label: Text(
              adding
                  ? 'Adding…'
                  : 'Add to cart · ${formatCurrency(product.price * quantity)}',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGallery extends StatelessWidget {
  const _ProductGallery({
    required this.productName,
    required this.imageUrls,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.controller,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onThumbnailPressed,
  });

  final String productName;
  final List<String> imageUrls;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final PageController controller;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.28,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fallbackColor.withValues(alpha: .12),
                  ),
                  child: PageView.builder(
                    key: const ValueKey('product-gallery'),
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: imageUrls.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) => AnimatedBuilder(
                      animation: controller,
                      child: _GalleryImage(
                        url: imageUrls[index],
                        semanticLabel:
                            '$productName, image ${index + 1} of ${imageUrls.length}',
                        fallbackIcon: fallbackIcon,
                        fallbackColor: fallbackColor,
                      ),
                      builder: (context, child) {
                        if (reduceMotion || !controller.hasClients) {
                          return child!;
                        }
                        final page = controller.position.hasContentDimensions
                            ? controller.page ?? selectedIndex.toDouble()
                            : selectedIndex.toDouble();
                        final distance = (page - index).abs().clamp(0.0, 1.0);
                        return Opacity(
                          opacity: 1 - (distance * .16),
                          child: Transform.scale(
                            scale: 1 - (distance * .035),
                            child: child,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: .88),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: AnimatedSwitcher(
                      duration: duration,
                      child: Text(
                        '${selectedIndex + 1} / ${imageUrls.length}',
                        key: ValueKey(selectedIndex),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var index = 0; index < imageUrls.length; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: index == selectedIndex,
                  label:
                      'Show $productName image ${index + 1} of ${imageUrls.length}',
                  child: AnimatedScale(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    scale: index == selectedIndex ? 1 : .96,
                    child: AnimatedContainer(
                      key: ValueKey('product-thumbnail-$index'),
                      height: 72,
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: index == selectedIndex
                              ? colors.primary
                              : colors.outlineVariant,
                          width: index == selectedIndex ? 1.5 : 1,
                        ),
                        boxShadow: index == selectedIndex
                            ? [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: .12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : const [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Material(
                          color: colors.surfaceContainerLowest,
                          child: InkWell(
                            onTap: () => onThumbnailPressed(index),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ExcludeSemantics(
                                  child: _GalleryImage(
                                    url: imageUrls[index],
                                    semanticLabel: '',
                                    fallbackIcon: fallbackIcon,
                                    fallbackColor: fallbackColor,
                                  ),
                                ),
                                if (index == selectedIndex)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe_rounded, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Swipe or tap a thumbnail',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({
    required this.url,
    required this.semanticLabel,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final String url;
  final String semanticLabel;
  final IconData fallbackIcon;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: semanticLabel,
    child: Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 220),
          child: child,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: fallbackColor,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => DecoratedBox(
        decoration: BoxDecoration(color: fallbackColor.withValues(alpha: .14)),
        child: Center(
          child: Icon(fallbackIcon, size: 72, color: fallbackColor),
        ),
      ),
    ),
  );
}
