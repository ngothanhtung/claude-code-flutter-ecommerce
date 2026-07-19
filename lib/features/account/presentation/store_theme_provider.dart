import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/store_theme_preset.dart';
import '../../../core/providers.dart';

final storeThemePresetProvider =
    NotifierProvider<StoreThemePresetNotifier, StoreThemePreset>(
      StoreThemePresetNotifier.new,
    );

class StoreThemePresetNotifier extends Notifier<StoreThemePreset> {
  static const storageKey = 'store_theme_preset';

  @override
  StoreThemePreset build() {
    final value = ref.read(localStoreProvider).readString(storageKey);
    return StoreThemePreset.values.firstWhere(
      (preset) => preset.name == value,
      orElse: () => StoreThemePreset.autoRed,
    );
  }

  Future<void> setPreset(StoreThemePreset preset) async {
    state = preset;
    await ref.read(localStoreProvider).writeString(storageKey, preset.name);
  }
}
