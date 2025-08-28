part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class BuildThemeData {
  const BuildThemeData();

  ThemeData fromState(ThemeState s, {TextTheme? baseTextTheme}) {
    final bool dark = s.mode == ThemeMode.dark;

    final ColorScheme base = ColorScheme.fromSeed(
      seedColor: s.seed,
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    final ColorScheme effective = _mergeOverrides(
      base,
      dark ? s.overrides?.dark : s.overrides?.light,
    );

    final ThemeData t = ThemeData(
      useMaterial3: s.useMaterial3,
      colorScheme: effective,
      textTheme: baseTextTheme,
    );

    final TextTheme resolved = baseTextTheme ?? t.textTheme;
    final TextTheme scaled = _applyTextScaleSafely(resolved, s.textScale);

    return t.copyWith(
      textTheme: scaled,
      visualDensity: VisualDensity.standard,
    );
  }

  ColorScheme _mergeOverrides(ColorScheme base, ColorScheme? ovr) {
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

  /// Scales only text styles that have a non-null fontSize.
  TextTheme _applyTextScaleSafely(TextTheme t, double factor) {
    if (factor == 1.0 || factor.isNaN) {
      return t;
    }

    TextStyle? scale(TextStyle? s) {
      if (s == null) {
        return null;
      }
      final double? fs = s.fontSize;
      return (fs == null) ? s : s.copyWith(fontSize: fs * factor);
    }

    return t.copyWith(
      displayLarge: scale(t.displayLarge),
      displayMedium: scale(t.displayMedium),
      displaySmall: scale(t.displaySmall),
      headlineLarge: scale(t.headlineLarge),
      headlineMedium: scale(t.headlineMedium),
      headlineSmall: scale(t.headlineSmall),
      titleLarge: scale(t.titleLarge),
      titleMedium: scale(t.titleMedium),
      titleSmall: scale(t.titleSmall),
      bodyLarge: scale(t.bodyLarge),
      bodyMedium: scale(t.bodyMedium),
      bodySmall: scale(t.bodySmall),
      labelLarge: scale(t.labelLarge),
      labelMedium: scale(t.labelMedium),
      labelSmall: scale(t.labelSmall),
    );
  }
}
