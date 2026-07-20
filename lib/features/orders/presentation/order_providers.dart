import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../notifications/data/notification_model.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../data/order.dart';
import '../data/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => ApiOrderRepository(ref.watch(apiClientProvider)),
);

final legacyLocalOrderStoreProvider = Provider(
  (ref) => LegacyLocalOrderStore(ref.watch(localStoreProvider)),
);

final ordersProvider = StreamProvider<List<StoreOrder>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield const [];
    return;
  }

  final repository = ref.watch(orderRepositoryProvider);
  final legacyStore = ref.watch(legacyLocalOrderStoreProvider);
  final legacyOrders = legacyStore.loadForUser(user.id);
  if (legacyOrders.isNotEmpty) {
    for (final order in legacyOrders) {
      await repository.add(order);
    }
    await legacyStore.clear();
  }

  yield* repository.watchForUser(user.id);
});

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, AsyncValue<StoreOrder?>>(
      CheckoutNotifier.new,
    );

class CheckoutNotifier extends Notifier<AsyncValue<StoreOrder?>> {
  StoreOrder? _pendingOrder;
  bool _orderPersisted = false;

  @override
  AsyncValue<StoreOrder?> build() => const AsyncData(null);

  Future<StoreOrder?> placeOrder({
    required String recipient,
    required String phone,
    required String address,
    required PaymentMethod paymentMethod,
  }) async {
    if (state.isLoading) return null;
    final user = ref.read(currentUserProvider);
    final lines = ref.read(cartLinesProvider);
    if (user == null || lines.isEmpty) return null;
    if (state.value != null) {
      _pendingOrder = null;
      _orderPersisted = false;
    }
    state = const AsyncLoading();
    try {
      final now = DateTime.now();
      final order =
          _pendingOrder ??
          StoreOrder(
            id: 'EV-${now.microsecondsSinceEpoch}',
            userId: user.id,
            items: lines
                .map(
                  (line) => OrderItem(
                    productId: line.product.id,
                    name: line.product.name,
                    unitPrice: line.product.price,
                    quantity: line.quantity,
                  ),
                )
                .toList(),
            total: lines.fold(0, (sum, line) => sum + line.total),
            date: now,
            status: OrderStatus.processing,
            shippingAddress: '$recipient · $phone\n${address.trim()}',
            paymentMethod: paymentMethod,
          );
      _pendingOrder = order;
      if (!_orderPersisted) {
        await ref.read(orderRepositoryProvider).add(order);
        _orderPersisted = true;
      }
      await ref.read(cartProvider.notifier).clear();
      final notificationId = 'order-${order.id}';
      if (!ref
          .read(notificationsProvider)
          .any((item) => item.id == notificationId)) {
        await ref
            .read(notificationsProvider.notifier)
            .add(
              StoreNotificationModel(
                id: notificationId,
                title: 'Order placed successfully',
                subtitle: '${order.id} is confirmed and now processing.',
                createdAt: now,
                type: StoreNotificationType.order,
              ),
            );
      }
      state = AsyncData(order);
      return order;
    } on Object catch (error, stack) {
      state = AsyncError(error, stack);
      return null;
    }
  }
}
