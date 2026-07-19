import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/core/local_store.dart';
import 'package:flutter_tutorials/core/providers.dart';
import 'package:flutter_tutorials/features/cart/presentation/cart_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
  });

  tearDown(() => container.dispose());

  test('adds, increments, decrements, removes and calculates totals', () async {
    final notifier = container.read(cartProvider.notifier);
    await notifier.add('airflex-runner', quantity: 2);
    await notifier.increment('airflex-runner');
    expect(container.read(cartTotalQuantityProvider), 3);
    expect(container.read(cartSubtotalProvider), 360);
    await notifier.decrement('airflex-runner');
    expect(container.read(cartProvider).single.quantity, 2);
    await notifier.remove('airflex-runner');
    expect(container.read(cartProvider), isEmpty);
  });

  test('hydrates persisted cart in a new container', () async {
    await container
        .read(cartProvider.notifier)
        .add('smart-tumbler', quantity: 2);
    final store = container.read(localStoreProvider);
    final restored = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
    addTearDown(restored.dispose);
    expect(restored.read(cartProvider).single.quantity, 2);
  });
}
