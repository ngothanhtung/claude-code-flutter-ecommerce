import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/store_scaffold.dart';
import '../data/notification_model.dart';
import 'notification_providers.dart';

class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key});
  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab> {
  bool unreadOnly = false;
  @override
  Widget build(BuildContext context) {
    final all = ref.watch(notificationsProvider);
    final items = unreadOnly ? all.where((item) => !item.isRead).toList() : all;
    return StorePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoreHeader(
            eyebrow: 'Inbox',
            title: 'Updates',
            subtitle: 'Orders, offers, and reminders in one place.',
            trailing: IconButton.filledTonal(
              tooltip: 'Mark all as read',
              onPressed: all.any((item) => !item.isRead)
                  ? ref.read(notificationsProvider.notifier).markAllRead
                  : null,
              icon: const Icon(Icons.done_all_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('All')),
              ButtonSegment(value: true, label: Text('Unread')),
            ],
            selected: {unreadOnly},
            onSelectionChanged: (value) =>
                setState(() => unreadOnly = value.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 22),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 58),
              child: Column(
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 54),
                  SizedBox(height: 12),
                  Text(
                    'You are all caught up',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NotificationCard(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({required this.item});
  final StoreNotificationModel item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final (icon, color) = switch (item.type) {
      StoreNotificationType.order => (
        Icons.local_shipping_rounded,
        colors.primary,
      ),
      StoreNotificationType.offer => (
        Icons.local_offer_rounded,
        colors.tertiary,
      ),
      StoreNotificationType.stock => (Icons.favorite_rounded, colors.secondary),
    };
    return InkWell(
      onTap: item.isRead
          ? null
          : () => ref.read(notificationsProvider.notifier).markRead(item.id),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead
              ? colors.surfaceContainerLowest
              : color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: item.isRead
                ? colors.outlineVariant
                : color.withValues(alpha: .28),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        DateFormat.MMMd().format(item.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
