part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Builds ThemeData from ThemeState combining seed-generated schemes
/// with optional per-scheme overrides. UI-only helper.
class BuildThemeData {
  const BuildThemeData();

  static ThemeData fromState(ThemeState s, {TextTheme? baseTextTheme}) {
    final bool dark = s.mode == ThemeMode.dark;

    // 1) Base desde seed
    final ColorScheme base = ColorScheme.fromSeed(
      seedColor: s.seed,
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    // 2) Overrides opcionales
    final ColorScheme effective = _mergeOverrides(
      base,
      dark ? s.overrides?.dark : s.overrides?.light,
    );

    // 3) Material 3 + textScale
    final ThemeData t = ThemeData(
      useMaterial3: s.useMaterial3,
      colorScheme: effective,
      textTheme: baseTextTheme,
    );
    return t.copyWith(
      textTheme:
          (baseTextTheme ?? t.textTheme).apply(fontSizeFactor: s.textScale),
      visualDensity: VisualDensity.standard,
    );
  }

  static ColorScheme _mergeOverrides(ColorScheme base, ColorScheme? ovr) {
    if (ovr == null) {
      return base;
    }
    return base.copyWith(
      primary: ovr.primary,
      onPrimary: ovr.onPrimary,
      secondary: ovr.secondary,
      onSecondary: ovr.onSecondary,
      tertiary: ovr.tertiary,
      onTertiary: ovr.onTertiary,
      error: ovr.error,
      onError: ovr.onError,
      surface: ovr.surface,
      onSurface: ovr.onSurface,
      surfaceTint: ovr.surfaceTint,
      outline: ovr.outline,
      onSurfaceVariant: ovr.onSurfaceVariant,
      inverseSurface: ovr.inverseSurface,
      inversePrimary: ovr.inversePrimary,
    );
  }
}
