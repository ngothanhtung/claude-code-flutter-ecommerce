import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_screen.dart';
import '../../../shared/currency.dart';
import 'order_detail_screen.dart';
import 'order_providers.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});
  static const routeName = '/order-success';
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final order = ordersState.value
        ?.where((item) => item.id == orderId)
        .firstOrNull;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 58,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Order confirmed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$orderId is now being prepared.',
                    textAlign: TextAlign.center,
                  ),
                  if (order != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(order.total),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: order == null || ordersState.isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                            context,
                            OrderDetailScreen.routeName,
                            arguments: orderId,
                          ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: const Text('View order'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      MainScreen.routeName,
                      (_) => false,
                    ),
                    child: const Text('Back to store'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
