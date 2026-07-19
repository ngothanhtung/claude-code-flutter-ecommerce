import 'package:flutter/material.dart';

enum StoreThemePreset { freshGreen, fastFoodOrange, autoRed }

@immutable
class StoreThemePalette {
  const StoreThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.outline,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color outline;
}

extension StoreThemePresetX on StoreThemePreset {
  String get label => switch (this) {
    StoreThemePreset.freshGreen => 'Fresh Green',
    StoreThemePreset.fastFoodOrange => 'Fast Food Orange',
    StoreThemePreset.autoRed => 'Auto Red',
  };

  String get description => switch (this) {
    StoreThemePreset.freshGreen => 'Organic, calm and naturally fresh',
    StoreThemePreset.fastFoodOrange => 'Warm, energetic and appetite-led',
    StoreThemePreset.autoRed => 'Sporty, premium and performance-led',
  };

  IconData get icon => switch (this) {
    StoreThemePreset.freshGreen => Icons.eco_outlined,
    StoreThemePreset.fastFoodOrange => Icons.fastfood_outlined,
    StoreThemePreset.autoRed => Icons.directions_car_outlined,
  };

  Color get seedColor => palette(Brightness.light).primary;

  StoreThemePalette palette(Brightness brightness) => switch ((
    this,
    brightness,
  )) {
    (StoreThemePreset.freshGreen, Brightness.light) => const StoreThemePalette(
      primary: Color(0xFF2E7D32),
      onPrimary: Colors.white,
      secondary: Color(0xFF00695C),
      onSecondary: Colors.white,
      tertiary: Color(0xFF9A6700),
      onTertiary: Colors.white,
      background: Color(0xFFF2F8F2),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF172019),
      outline: Color(0xFF6F786F),
    ),
    (StoreThemePreset.freshGreen, Brightness.dark) => const StoreThemePalette(
      primary: Color(0xFF81C784),
      onPrimary: Color(0xFF102112),
      secondary: Color(0xFF80CBC4),
      onSecondary: Color(0xFF08211E),
      tertiary: Color(0xFFFFD166),
      onTertiary: Color(0xFF251A00),
      background: Color(0xFF0D1710),
      surface: Color(0xFF141F17),
      onSurface: Color(0xFFE5EDE5),
      outline: Color(0xFF8B938B),
    ),
    (StoreThemePreset.fastFoodOrange, Brightness.light) =>
      const StoreThemePalette(
        primary: Color(0xFFC2410C),
        onPrimary: Colors.white,
        secondary: Color(0xFFA16207),
        onSecondary: Colors.white,
        tertiary: Color(0xFF1D4ED8),
        onTertiary: Colors.white,
        background: Color(0xFFFFF7ED),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF28170F),
        outline: Color(0xFF80736C),
      ),
    (StoreThemePreset.fastFoodOrange, Brightness.dark) =>
      const StoreThemePalette(
        primary: Color(0xFFFFB36B),
        onPrimary: Color(0xFF2D1400),
        secondary: Color(0xFFFACC15),
        onSecondary: Color(0xFF251A00),
        tertiary: Color(0xFF93C5FD),
        onTertiary: Color(0xFF071A32),
        background: Color(0xFF1B100A),
        surface: Color(0xFF24160F),
        onSurface: Color(0xFFF6EDE7),
        outline: Color(0xFFA39388),
      ),
    (StoreThemePreset.autoRed, Brightness.light) => const StoreThemePalette(
      primary: Color(0xFFC62828),
      onPrimary: Colors.white,
      secondary: Color(0xFF1E293B),
      onSecondary: Colors.white,
      tertiary: Color(0xFF475569),
      onTertiary: Colors.white,
      background: Color(0xFFF7F7F8),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF18181B),
      outline: Color(0xFF74747C),
    ),
    (StoreThemePreset.autoRed, Brightness.dark) => const StoreThemePalette(
      primary: Color(0xFFFFB3AE),
      onPrimary: Color(0xFF3F0004),
      secondary: Color(0xFFCBD5E1),
      onSecondary: Color(0xFF1E293B),
      tertiary: Color(0xFF94A3B8),
      onTertiary: Color(0xFF101827),
      background: Color(0xFF0D1117),
      surface: Color(0xFF151B23),
      onSurface: Color(0xFFE8EDF4),
      outline: Color(0xFF8B949E),
    ),
  };
}
