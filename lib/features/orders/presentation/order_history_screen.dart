import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/currency.dart';
import 'order_detail_screen.dart';
import 'order_providers.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 52),
                const SizedBox(height: 12),
                const Text(
                  'Could not load your orders',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(ordersProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 58),
                  SizedBox(height: 12),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_mall_outlined),
                  ),
                  title: Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(order.date)} · '
                    '${order.items.length} items',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(order.total),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Text('Processing', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    OrderDetailScreen.routeName,
                    arguments: order.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
