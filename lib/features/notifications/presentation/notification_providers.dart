import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(ref.watch(localStoreProvider)),
);
final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<StoreNotificationModel>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends Notifier<List<StoreNotificationModel>> {
  @override
  List<StoreNotificationModel> build() =>
      ref.read(notificationRepositoryProvider).load();

  Future<void> add(StoreNotificationModel item) => _save([item, ...state]);

  Future<void> markRead(String id) => _save([
    for (final item in state)
      item.id == id ? item.copyWith(isRead: true) : item,
  ]);

  Future<void> markAllRead() =>
      _save(state.map((item) => item.copyWith(isRead: true)).toList());

  Future<void> _save(List<StoreNotificationModel> next) async {
    await ref.read(notificationRepositoryProvider).save(next);
    state = next;
  }
}

final unreadNotificationsProvider = Provider<int>(
  (ref) =>
      ref.watch(notificationsProvider).where((item) => !item.isRead).length,
);
