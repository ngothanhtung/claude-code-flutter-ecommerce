import '../../../core/local_store.dart';
import 'cart_item.dart';

class CartRepository {
  const CartRepository(this.store);

  static const storageKey = 'cart';
  final LocalStore store;

  List<CartItem> load() =>
      store.readJson(storageKey, const <CartItem>[], (json) {
        if (json is! List) return const <CartItem>[];
        return json.map(CartItem.tryFromJson).whereType<CartItem>().toList();
      });

  Future<void> save(List<CartItem> items) =>
      store.writeJson(storageKey, items.map((item) => item.toJson()).toList());
}
