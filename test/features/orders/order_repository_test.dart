import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/core/local_store.dart';
import 'package:flutter_tutorials/features/orders/data/order.dart';
import 'package:flutter_tutorials/features/orders/data/order_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

StoreOrder _order({String userId = 'user-1'}) => StoreOrder(
  id: 'EV-100',
  userId: userId,
  items: const [
    OrderItem(
      productId: 'airflex-runner',
      name: 'AirFlex Runner',
      unitPrice: 120,
      quantity: 2,
    ),
  ],
  total: 240,
  date: DateTime(2026, 7, 19),
  status: OrderStatus.processing,
  shippingAddress: 'Mai · 0900000000\n1 Main Street',
  paymentMethod: PaymentMethod.cod,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('round-trips a Firestore order snapshot', () {
    final restored = StoreOrder.tryFromJson(_order().toFirestore());
    expect(restored?.id, 'EV-100');
    expect(restored?.userId, 'user-1');
    expect(restored?.items.single.name, 'AirFlex Runner');
    expect(restored?.total, 240);
  });

  test('in-memory repository isolates orders by owner', () async {
    final repository = InMemoryOrderRepository();
    await repository.add(_order());
    expect(await repository.watchForUser('user-1').first, hasLength(1));
    expect(await repository.watchForUser('user-2').first, isEmpty);
  });

  test(
    'reads legacy local orders for migration and assigns the owner',
    () async {
      SharedPreferences.setMockInitialValues({
        LegacyLocalOrderStore.storageKey:
            '[{"id":"EV-100","items":[{"productId":"airflex-runner",'
            '"name":"AirFlex Runner","unitPrice":120,"quantity":2}],'
            '"total":240,"date":"2026-07-19T00:00:00.000",'
            '"status":"processing","shippingAddress":"1 Main Street",'
            '"paymentMethod":"cod"}]',
      });
      final legacy = LegacyLocalOrderStore(
        LocalStore(await SharedPreferences.getInstance()),
      );
      final restored = legacy.loadForUser('firebase-user').single;
      expect(restored.userId, 'firebase-user');
      await legacy.clear();
      expect(legacy.loadForUser('firebase-user'), isEmpty);
    },
  );
}
