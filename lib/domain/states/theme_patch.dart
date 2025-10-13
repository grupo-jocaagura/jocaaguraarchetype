part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Expresses a partial update intent for theming. Any non-null field replaces
/// the corresponding value on top of a given [ThemeState].
///
/// Semantics
/// - `mode`, `seed`, `useMaterial3`, `textScale`, and `preset` are applied
///   directly when provided.
/// - `textScale` is clamped to the inclusive range `[0.8, 1.6]`. If a non-finite
///   value is provided, the current state's value is kept.
/// - `overrides` and `textOverrides` are **wholesale replacements**: when provided,
///   they fully replace the current ones (no deep merge).
/// - Passing `null` for a field keeps the current state's value. This class
///   does **not** support "nulling" existing values (e.g., clearing overrides).
///
/// Example
/// ```dart
/// final ThemePatch patch = ThemePatch(
///   mode: ThemeMode.dark,
///   textScale: 1.1, // clamped to [0.8, 1.6]
///   textOverrides: const TextThemeOverrides(
///     light: TextTheme(
///       bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
///     ),
///     dark: TextTheme(
///       bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
///     ),
///   ),
/// );
///
/// final ThemeState updated = patch.applyOn(ThemeState.defaults);
/// ```
///
/// Notes
/// - If you need to *clear* (`null`) an existing `overrides` or `textOverrides`,
///   use a higher-level API or a dedicated "clear" signal; `ThemePatch` only
///   replaces when non-null values are provided.
/// - `preset` is not normalized here; upstream layers may apply defaults such as `'brand'`.
@immutable
class ThemePatch {
  const ThemePatch({
    this.mode,
    this.seed,
    this.useMaterial3,
    this.textScale,
    this.preset,
    this.overrides,
    this.textOverrides, // <-- NEW
  });

  /// Target ThemeMode.
  final ThemeMode? mode;

  /// Seed color for ColorScheme.fromSeed (unless overridden by overrides).
  final Color? seed;

  /// Toggle for Material 3.
  final bool? useMaterial3;

  /// Text scale factor; will be clamped on apply.
  final double? textScale;

  /// Named preset (brand, designer, etc).
  final String? preset;

  /// Optional per-scheme color overrides; if provided, replaces current overrides.
  final ThemeOverrides? overrides;

  /// Optional per-scheme typography overrides; if provided, replaces current overrides.
  final TextThemeOverrides? textOverrides; // <-- NEW

  /// Applies this patch over [base] producing a new [ThemeState].
  ThemeState applyOn(ThemeState base) {
    final double scale = textScale == null
        ? base.textScale
        : (textScale!.isFinite
            ? Utils.getDouble(textScale!.clamp(0.8, 1.6))
            : base.textScale);

    return base.copyWith(
      mode: mode ?? base.mode,
      seed: seed ?? base.seed,
      useMaterial3: useMaterial3 ?? base.useMaterial3,
      textScale: scale,
      preset: preset ?? base.preset,
      overrides: overrides ?? base.overrides,
      textOverrides: textOverrides ?? base.textOverrides, // <-- NEW
    );
  }

  /// Convenience helper to build a copy changing selected fields.
  ///
  /// Tip: Pass `null` to keep the current value; pass a non-null value to replace it.
  ThemePatch copyWith({
    ThemeMode? mode,
    Color? seed,
    bool? useMaterial3,
    double? textScale,
    String? preset,
    ThemeOverrides? overrides,
    TextThemeOverrides? textOverrides,
  }) {
    return ThemePatch(
      mode: mode ?? this.mode,
      seed: seed ?? this.seed,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      textScale: textScale ?? this.textScale,
      preset: preset ?? this.preset,
      overrides: overrides ?? this.overrides,
      textOverrides: textOverrides ?? this.textOverrides,
    );
  }
}
