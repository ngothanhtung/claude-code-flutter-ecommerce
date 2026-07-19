import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/currency.dart';
import '../../reviews/presentation/review_product_screen.dart';
import '../data/order.dart';
import 'order_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  static const routeName = '/order-detail';
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    return ordersState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Could not load this order')),
      ),
      data: (orders) => _buildOrder(context, orders),
    );
  }

  Widget _buildOrder(BuildContext context, List<StoreOrder> orders) {
    final order = orders.where((item) => item.id == orderId).firstOrNull;
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(order.id)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Processing',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text('Placed ${DateFormat.yMMMd().add_jm().format(order.date)}'),
          const SizedBox(height: 24),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.inventory_2_outlined),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${item.quantity} × ${formatCurrency(item.unitPrice)}',
                        ),
                        trailing: Text(
                          formatCurrency(item.total),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          key: ValueKey('review-product-${item.productId}'),
                          onPressed: () async {
                            final saved = await Navigator.pushNamed(
                              context,
                              ReviewProductScreen.routeName,
                              arguments: ReviewScreenArgs(
                                productId: item.productId,
                                productName: item.name,
                                orderId: order.id,
                              ),
                            );
                            if (saved == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your review was saved'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Review product'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                formatCurrency(order.total),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Delivery',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(order.shippingAddress),
          const SizedBox(height: 20),
          Text(
            order.paymentMethod == PaymentMethod.cod
                ? 'Cash on delivery'
                : 'Demo card',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
