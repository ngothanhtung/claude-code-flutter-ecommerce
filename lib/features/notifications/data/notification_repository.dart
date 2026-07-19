import '../../../core/local_store.dart';
import 'notification_model.dart';

class NotificationRepository {
  const NotificationRepository(this.store);

  static const storageKey = 'notifications';
  final LocalStore store;

  List<StoreNotificationModel> load() =>
      store.readJson(storageKey, seedNotifications, (json) {
        if (json is! List) return seedNotifications;
        return json
            .map(StoreNotificationModel.tryFromJson)
            .whereType<StoreNotificationModel>()
            .toList();
      });

  Future<void> save(List<StoreNotificationModel> items) =>
      store.writeJson(storageKey, items.map((item) => item.toJson()).toList());
}

final seedNotifications = [
  StoreNotificationModel(
    id: 'seed-shipping',
    title: 'Your order is on the move',
    subtitle: 'Order #FL-2048 arrives tomorrow. Track your driver anytime.',
    createdAt: DateTime(2026, 7, 19, 9, 24),
    type: StoreNotificationType.order,
  ),
  StoreNotificationModel(
    id: 'seed-offer',
    title: 'A favorite just dropped in price',
    subtitle: 'AirFlex Runner is now 20% off until midnight.',
    createdAt: DateTime(2026, 7, 19, 8, 10),
    type: StoreNotificationType.offer,
  ),
  StoreNotificationModel(
    id: 'seed-stock',
    title: 'Back in stock',
    subtitle: 'The Smart Tumbler from your wishlist is available again.',
    createdAt: DateTime(2026, 7, 18, 16),
    type: StoreNotificationType.stock,
    isRead: true,
  ),
];
