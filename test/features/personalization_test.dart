import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/app/store_theme_preset.dart';
import 'package:flutter_tutorials/app/theme.dart';
import 'package:flutter_tutorials/core/local_store.dart';
import 'package:flutter_tutorials/core/providers.dart';
import 'package:flutter_tutorials/features/account/presentation/store_theme_provider.dart';
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

  test('store theme defaults to Auto Red and persists a new preset', () async {
    expect(container.read(storeThemePresetProvider), StoreThemePreset.autoRed);
    await container
        .read(storeThemePresetProvider.notifier)
        .setPreset(StoreThemePreset.freshGreen);
    final restored = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
    addTearDown(restored.dispose);
    expect(
      restored.read(storeThemePresetProvider),
      StoreThemePreset.freshGreen,
    );
  });

  test('Fast Food Orange and Auto Red keep distinct brand hues', () {
    final orange = buildStoreTheme(
      Brightness.light,
      StoreThemePreset.fastFoodOrange,
    ).colorScheme.primary;
    final red = buildStoreTheme(
      Brightness.light,
      StoreThemePreset.autoRed,
    ).colorScheme.primary;
    final orangeHue = HSVColor.fromColor(orange).hue;
    final redHue = HSVColor.fromColor(red).hue;

    expect(orange, const Color(0xFFC2410C));
    expect(red, const Color(0xFFC62828));
    expect(orangeHue, inInclusiveRange(15, 45));
    expect(redHue, anyOf(inInclusiveRange(0, 10), inInclusiveRange(350, 360)));
    expect((orangeHue - redHue).abs(), greaterThan(15));
  });

  test('all preset palettes meet AA contrast in light and dark mode', () {
    for (final preset in StoreThemePreset.values) {
      for (final brightness in Brightness.values) {
        final palette = preset.palette(brightness);
        final pairs = {
          'primary': (palette.primary, palette.onPrimary),
          'secondary': (palette.secondary, palette.onSecondary),
          'bannerEnd': (palette.secondary, palette.onPrimary),
          'tertiary': (palette.tertiary, palette.onTertiary),
          'surface': (palette.surface, palette.onSurface),
          'background': (palette.background, palette.onSurface),
        };

        for (final MapEntry(key: role, value: pair) in pairs.entries) {
          expect(
            _contrastRatio(pair.$1, pair.$2),
            greaterThanOrEqualTo(4.5),
            reason: '${preset.name} ${brightness.name} $role contrast',
          );
        }
      }
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + .05) / (darker + .05);
}
