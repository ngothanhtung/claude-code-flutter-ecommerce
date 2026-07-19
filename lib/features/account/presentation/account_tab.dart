import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_tab_provider.dart';
import '../../../shared/store_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../orders/presentation/order_history_screen.dart';
import '../../orders/presentation/order_providers.dart';
import '../../wishlist/presentation/wishlist_providers.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import 'theme_mode_provider.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final orderCount = ref.watch(ordersProvider).value?.length ?? 0;
    final wishlistCount = ref.watch(wishlistProvider).length;
    final themeMode = ref.watch(themeModeProvider);
    return StorePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StoreHeader(
            eyebrow: 'Profile',
            title: 'My account',
            subtitle: 'Everything personal, all in one place.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.onPrimary, width: 3),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Everyday member',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: colors.onPrimary.withValues(alpha: .76),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(value: '$orderCount', label: 'Orders'),
                    ),
                    Container(
                      width: 1,
                      height: 34,
                      color: colors.onPrimary.withValues(alpha: .2),
                    ),
                    Expanded(
                      child: _Stat(value: '$wishlistCount', label: 'Wishlist'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Material(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.receipt_long_rounded,
                    color: colors.primary,
                  ),
                  title: const Text(
                    'My orders',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('$orderCount orders'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(
                    context,
                    OrderHistoryScreen.routeName,
                  ),
                ),
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: Icon(
                    Icons.favorite_outline_rounded,
                    color: colors.primary,
                  ),
                  title: const Text(
                    'Saved items',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('$wishlistCount products waiting for you'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      Navigator.pushNamed(context, WishlistScreen.routeName),
                ),
                const Divider(height: 1, indent: 64),
                SwitchListTile(
                  key: const ValueKey('theme-mode-switch'),
                  secondary: Icon(
                    Icons.dark_mode_outlined,
                    color: colors.primary,
                  ),
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    themeMode == ThemeMode.system
                        ? 'Following system until changed'
                        : themeMode.name,
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (dark) => ref
                      .read(themeModeProvider.notifier)
                      .setMode(dark ? ThemeMode.dark : ThemeMode.light),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const ValueKey('logout-button'),
            onPressed: () async {
              ref.read(mainTabProvider.notifier).showHome();
              await ref.read(currentUserProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: .72), fontSize: 12),
        ),
      ],
    );
  }
}
