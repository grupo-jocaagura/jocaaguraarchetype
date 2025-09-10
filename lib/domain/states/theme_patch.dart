part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Partial update intent for theme. Any non-null field will be applied on top
/// of the current ThemeState in the repository.
@immutable
class ThemePatch {
  const ThemePatch({
    this.mode,
    this.seed,
    this.useMaterial3,
    this.textScale,
    this.preset,
    this.overrides,
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

  /// Optional per-scheme overrides; if provided, it replaces current overrides.
  final ThemeOverrides? overrides;

  /// Applies this patch over [base] producing a new ThemeState.
  ThemeState applyOn(ThemeState base) {
    final double scale = textScale == null
        ? base.textScale
        : (textScale!.isFinite ? textScale!.clamp(0.8, 1.6) : base.textScale);
    return base.copyWith(
      mode: mode ?? base.mode,
      seed: seed ?? base.seed,
      useMaterial3: useMaterial3 ?? base.useMaterial3,
      textScale: scale,
      preset: preset ?? base.preset,
      overrides: overrides ?? base.overrides,
    );
  }
}
