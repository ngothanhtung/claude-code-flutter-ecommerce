import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/currency.dart';
import '../../../shared/store_scaffold.dart';
import '../../orders/presentation/checkout_screen.dart';
import 'cart_providers.dart';

class CartTab extends ConsumerWidget {
  const CartTab({super.key, required this.onContinueShopping});
  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartLinesProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    if (lines.isEmpty) {
      return _EmptyCart(onContinueShopping: onContinueShopping);
    }
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Stack(
        children: [
          StorePage(
            bottomPadding: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StoreHeader(
                  eyebrow: 'Your bag',
                  title: 'Cart',
                  subtitle: 'Everything you chose, ready when you are.',
                ),
                const SizedBox(height: 18),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CartLineCard(line: line),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Estimated total',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatCurrency(subtotal),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: FilledButton.icon(
                    key: const ValueKey('checkout-button'),
                    onPressed: () =>
                        Navigator.pushNamed(context, CheckoutScreen.routeName),
                    icon: const Icon(Icons.lock_outline_rounded, size: 19),
                    label: Text(
                      'Secure checkout · ${formatCurrency(subtotal)}',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({required this.line});
  final CartLine line;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 88,
            decoration: BoxDecoration(
              color: line.product.color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(line.product.icon, size: 42, color: line.product.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  formatCurrency(line.product.price),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Subtotal · ${formatCurrency(line.total)}',
                  key: ValueKey('cart-line-subtotal-${line.product.id}'),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 36,
                      child: IconButton.outlined(
                        key: ValueKey('cart-decrement-${line.product.id}'),
                        tooltip: 'Decrease quantity',
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .decrement(line.product.id),
                        icon: const Icon(Icons.remove_rounded, size: 17),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${line.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox.square(
                      dimension: 36,
                      child: IconButton.filledTonal(
                        key: ValueKey('cart-increment-${line.product.id}'),
                        tooltip: 'Increase quantity',
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .increment(line.product.id),
                        icon: const Icon(Icons.add_rounded, size: 17),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove item',
            onPressed: () =>
                ref.read(cartProvider.notifier).remove(line.product.id),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onContinueShopping});
  final VoidCallback onContinueShopping;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StorePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StoreHeader(
            eyebrow: 'Your bag',
            title: 'Cart',
            subtitle: 'Everything you chose, ready when you are.',
          ),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 54,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Your bag is beautifully empty',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore the edit and save something for later.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onContinueShopping,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
