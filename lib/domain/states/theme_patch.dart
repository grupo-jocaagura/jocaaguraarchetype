part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Describes a partial update intent for theming and applies it on top of a
/// given [ThemeState].
///
/// ## Semantics
/// - Non-null fields replace the corresponding values in the base state.
/// - `textScale` is clamped to the inclusive range `[0.8, 1.6]`.
///   If a non-finite value (NaN/∞) is provided, the base state's value is kept.
/// - `overrides` and `textOverrides` are wholesale replacements (no deep merge).
/// - Passing `null` keeps the base state's value; this class does **not** support
///   clearing existing values (e.g. setting overrides to `null`).
///
/// ## Notes
/// - `preset` is not normalized here; upstream layers may enforce defaults such
///   as `'brand'`.
///
/// ## Example
/// ```dart
/// void main() {
/// final ThemePatch patch = ThemePatch(
///   mode: ThemeMode.dark,
///   textScale: 1.1,
///   textOverrides: const TextThemeOverrides(
///     light: TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
///     dark:  TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
///   ),
/// );
/// final ThemeState updated = patch.applyOn(ThemeState.defaults);
/// }
/// ```
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
