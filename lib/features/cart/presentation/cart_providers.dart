import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../catalog/data/product.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../data/cart_item.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider(
  (ref) => CartRepository(ref.watch(localStoreProvider)),
);
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => ref.read(cartRepositoryProvider).load();

  Future<void> add(String productId, {int quantity = 1}) async {
    if (quantity <= 0) return;
    final index = state.indexWhere((item) => item.productId == productId);
    final next = [...state];
    if (index < 0) {
      next.add(CartItem(productId: productId, quantity: quantity));
    } else {
      next[index] = next[index].copyWith(
        quantity: next[index].quantity + quantity,
      );
    }
    await _save(next);
  }

  Future<void> increment(String id) async => add(id);

  Future<void> decrement(String id) async {
    final item = state.where((item) => item.productId == id).firstOrNull;
    if (item == null) return;
    if (item.quantity == 1) return remove(id);
    await _save([
      for (final current in state)
        if (current.productId == id)
          current.copyWith(quantity: current.quantity - 1)
        else
          current,
    ]);
  }

  Future<void> remove(String id) async =>
      _save(state.where((item) => item.productId != id).toList());

  Future<void> clear() async => _save(const []);

  Future<void> _save(List<CartItem> next) async {
    await ref.read(cartRepositoryProvider).save(next);
    state = next;
  }
}

class CartLine {
  const CartLine(this.product, this.quantity);
  final Product product;
  final int quantity;
  double get total => product.price * quantity;
}

final cartLinesProvider = Provider<List<CartLine>>((ref) {
  final catalog = ref.watch(catalogRepositoryProvider);
  return ref
      .watch(cartProvider)
      .map((item) {
        final product = catalog.findById(item.productId);
        return product == null ? null : CartLine(product, item.quantity);
      })
      .whereType<CartLine>()
      .toList();
});
final cartTotalQuantityProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity),
);
final cartSubtotalProvider = Provider<double>(
  (ref) =>
      ref.watch(cartLinesProvider).fold(0, (sum, line) => sum + line.total),
);
