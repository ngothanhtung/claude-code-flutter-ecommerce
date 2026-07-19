import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_tab_provider.dart';
import '../../../app/store_theme_preset.dart';
import '../../../shared/store_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../orders/presentation/order_history_screen.dart';
import '../../orders/presentation/order_providers.dart';
import '../../wishlist/presentation/wishlist_providers.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import 'store_theme_provider.dart';
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
    final storeTheme = ref.watch(storeThemePresetProvider);
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
                ListTile(
                  key: const ValueKey('store-theme-selector'),
                  leading: Icon(storeTheme.icon, color: colors.primary),
                  title: const Text(
                    'Store theme',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(storeTheme.label),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CompactPalettePreview(
                        preset: storeTheme,
                        brightness: Theme.of(context).brightness,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: () => _showThemePicker(context, ref, storeTheme),
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

Future<void> _showThemePicker(
  BuildContext context,
  WidgetRef ref,
  StoreThemePreset selected,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose a store theme',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Preview each identity in light and dark mode.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (final preset in StoreThemePreset.values) ...[
          _ThemePresetTile(
            preset: preset,
            selected: preset == selected,
            onTap: () async {
              await ref
                  .read(storeThemePresetProvider.notifier)
                  .setPreset(preset);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          if (preset != StoreThemePreset.values.last)
            const SizedBox(height: 10),
        ],
      ],
    ),
  ),
);

class _ThemePresetTile extends StatelessWidget {
  const _ThemePresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final StoreThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? colors.primaryContainer
            : colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('store-theme-${preset.name}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            preset.palette(Brightness.light).primary,
                            preset.palette(Brightness.light).secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(preset.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.label,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            preset.description,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: selected ? colors.primary : colors.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ModePalettePreview(
                        preset: preset,
                        brightness: Brightness.light,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModePalettePreview(
                        preset: preset,
                        brightness: Brightness.dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModePalettePreview extends StatelessWidget {
  const _ModePalettePreview({required this.preset, required this.brightness});

  final StoreThemePreset preset;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette(brightness);
    final dark = brightness == Brightness.dark;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.outline.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          Icon(
            dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 16,
            color: palette.onSurface,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              dark ? 'Dark' : 'Light',
              style: TextStyle(
                color: palette.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _PaletteDot(color: palette.primary),
          const SizedBox(width: 4),
          _PaletteDot(color: palette.secondary),
          const SizedBox(width: 4),
          _PaletteDot(color: palette.tertiary),
        ],
      ),
    );
  }
}

class _CompactPalettePreview extends StatelessWidget {
  const _CompactPalettePreview({
    required this.preset,
    required this.brightness,
  });

  final StoreThemePreset preset;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette(brightness);
    return Container(
      width: 48,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(child: ColoredBox(color: palette.primary)),
          Expanded(child: ColoredBox(color: palette.secondary)),
          Expanded(child: ColoredBox(color: palette.tertiary)),
        ],
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  const _PaletteDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
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
