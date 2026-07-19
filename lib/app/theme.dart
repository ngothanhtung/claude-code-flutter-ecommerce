import 'package:flutter/material.dart';

import 'store_theme_preset.dart';

ThemeData buildStoreTheme(Brightness brightness, StoreThemePreset preset) {
  final palette = preset.palette(brightness);
  final generatedColors = ColorScheme.fromSeed(
    seedColor: preset.seedColor,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final colors = generatedColors.copyWith(
    primary: palette.primary,
    onPrimary: palette.onPrimary,
    secondary: palette.secondary,
    onSecondary: palette.onSecondary,
    tertiary: palette.tertiary,
    onTertiary: palette.onTertiary,
    surface: palette.surface,
    onSurface: palette.onSurface,
    outline: palette.outline,
  );
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: palette.background,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? colors.surfaceContainer : colors.surface,
      indicatorColor: colors.primary.withValues(alpha: .14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? colors.primary
              : colors.onSurfaceVariant,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
