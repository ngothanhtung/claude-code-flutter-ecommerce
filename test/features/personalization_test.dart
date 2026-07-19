import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/core/local_store.dart';
import 'package:flutter_tutorials/core/providers.dart';
import 'package:flutter_tutorials/features/notifications/data/notification_model.dart';
import 'package:flutter_tutorials/features/notifications/presentation/notification_providers.dart';
import 'package:flutter_tutorials/features/wishlist/presentation/wishlist_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LocalStore(await SharedPreferences.getInstance());
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
  });
  tearDown(() => container.dispose());

  test('wishlist toggles and restores valid product IDs', () async {
    await container.read(wishlistProvider.notifier).toggle('airflex-runner');
    expect(container.read(wishlistProvider), {'airflex-runner'});
    final restored = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
    addTearDown(restored.dispose);
    expect(restored.read(wishlistProvider), {'airflex-runner'});
  });

  test('notifications mark read and accept generated updates', () async {
    expect(container.read(unreadNotificationsProvider), 2);
    await container
        .read(notificationsProvider.notifier)
        .markRead('seed-shipping');
    expect(container.read(unreadNotificationsProvider), 1);
    await container
        .read(notificationsProvider.notifier)
        .add(
          StoreNotificationModel(
            id: 'generated',
            title: 'Generated',
            subtitle: 'Local update',
            createdAt: DateTime(2026, 7, 19),
            type: StoreNotificationType.order,
          ),
        );
    expect(container.read(unreadNotificationsProvider), 2);
  });
}
