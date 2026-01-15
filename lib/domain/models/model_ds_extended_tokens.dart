part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Defines stable JSON keys for [ModelDsExtendedTokens].
///
/// This is a centralized registry of keys to ensure:
/// - Export/import consistency.
/// - Validation of required keys during [ModelDsExtendedTokens.fromJson].
///
/// The [all] list contains every key that must exist in a valid JSON payload.
///
/// Notes:
/// - Keys are intentionally stable; avoid renaming.
/// - Adding a new key is a breaking change for strict JSON import.
abstract class ModelDsExtendedTokensKeys {
  static const String spacingXs = 'spacingXs';
  static const String spacingSm = 'spacingSm';
  static const String spacing = 'spacing';
  static const String spacingLg = 'spacingLg';
  static const String spacingXl = 'spacingXl';
  static const String spacingXXl = 'spacingXXl';

  static const String borderRadiusXs = 'borderRadiusXs';
  static const String borderRadiusSm = 'borderRadiusSm';
  static const String borderRadius = 'borderRadius';
  static const String borderRadiusLg = 'borderRadiusLg';
  static const String borderRadiusXl = 'borderRadiusXl';
  static const String borderRadiusXXl = 'borderRadiusXXl';

  static const String elevationXs = 'elevationXs';
  static const String elevationSm = 'elevationSm';
  static const String elevation = 'elevation';
  static const String elevationLg = 'elevationLg';
  static const String elevationXl = 'elevationXl';
  static const String elevationXXl = 'elevationXXl';

  /// Values intended to be used with `Color.withOpacity(x)` or `withAlpha(...)` conversions.
  /// Range: 0..1.
  static const String withAlphaXs = 'withAlphaXs';
  static const String withAlphaSm = 'withAlphaSm';
  static const String withAlpha = 'withAlpha';
  static const String withAlphaLg = 'withAlphaLg';
  static const String withAlphaXl = 'withAlphaXl';
  static const String withAlphaXXl = 'withAlphaXXl';

  static const String animationDurationShort = 'animationDurationShort';
  static const String animationDuration = 'animationDuration';
  static const String animationDurationLong = 'animationDurationLong';

  static const List<String> all = <String>[
    spacingXs,
    spacingSm,
    spacing,
    spacingLg,
    spacingXl,
    spacingXXl,
    borderRadiusXs,
    borderRadiusSm,
    borderRadius,
    borderRadiusLg,
    borderRadiusXl,
    borderRadiusXXl,
    elevationXs,
    elevationSm,
    elevation,
    elevationLg,
    elevationXl,
    elevationXXl,
    withAlphaXs,
    withAlphaSm,
    withAlpha,
    withAlphaLg,
    withAlphaXl,
    withAlphaXXl,
    animationDurationShort,
    animationDuration,
    animationDurationLong,
  ];
}

/// Represents a set of extended Design System tokens.
///
/// This model groups commonly needed numeric tokens:
/// - Spacing scale (xs..xxl)
/// - Border radius scale (xs..xxl)
/// - Elevation scale (xs..xxl)
/// - Alpha scale for color opacity (xs..xxl) in the 0..1 range
/// - Animation durations (short/regular/long)
///
/// The instance is immutable and self-validating. Any constructor that builds
/// an instance will call an internal validation step.
///
/// Functional example:
/// ```dart
/// void main() {
///   final ModelDsExtendedTokens tokens = ModelDsExtendedTokens.fromFactor(
///     spacingFactor: 2.0,
///     initialSpacing: 4.0,
///     borderRadiusFactor: 2.0,
///     initialBorderRadius: 2.0,
///     elevationFactor: 2.0,
///     initialElevation: 1.0,
///     withAlphaFactor: 1.5,
///     initialWithAlpha: 0.04,
///     animationDurationFactor: 3,
///     initialAnimationDuration: 100.0,
///   );
///
///   final Map<String, dynamic> json = tokens.toJson();
///   final ModelDsExtendedTokens restored = ModelDsExtendedTokens.fromJson(json);
///
///   // Round-trip safety (should be true for the same values).
///   assert(tokens == restored);
///   print(restored.spacing); // e.g. 16.0
/// }
/// ```
///
/// Contracts:
/// - Spacing, radius and elevation values must be finite and >= 0.
/// - `withAlpha*` values must be finite and within 0..1.
/// - Each scale must be ascending (xs <= sm <= ... <= xxl).
/// - Durations must be >= 0 and ascending:
///   short <= regular <= long.
///
/// Throws:
/// - [RangeError] if any contract is violated.
/// - [FormatException] from [fromJson] if any required key is missing.
@immutable
class ModelDsExtendedTokens {
  const ModelDsExtendedTokens({
    this.spacingXs = 4.0,
    this.spacingSm = 8.0,
    this.spacing = 16.0,
    this.spacingLg = 24.0,
    this.spacingXl = 32.0,
    this.spacingXXl = 64.0,
    this.borderRadiusXs = 2.0,
    this.borderRadiusSm = 4.0,
    this.borderRadius = 8.0,
    this.borderRadiusLg = 12.0,
    this.borderRadiusXl = 16.0,
    this.borderRadiusXXl = 24.0,
    this.elevationXs = 0.0,
    this.elevationSm = 1.0,
    this.elevation = 3.0,
    this.elevationLg = 6.0,
    this.elevationXl = 9.0,
    this.elevationXXl = 12.0,
    this.withAlphaXs = 0.04,
    this.withAlphaSm = 0.12,
    this.withAlpha = 0.16,
    this.withAlphaLg = 0.24,
    this.withAlphaXl = 0.32,
    this.withAlphaXXl = 0.40,
    this.animationDurationShort = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationDurationLong = const Duration(milliseconds: 800),
  });

  /// Builds a token set using geometric progression factors.
  ///
  /// Notes:
  /// - Spacing / radius / elevation grow by multiplying the previous step by a factor.
  /// - `withAlpha*` grows upwards but is clamped into 0..1.
  /// - Durations are derived from `initialAnimationDuration` and `animationDurationFactor`.
  ///
  /// Parameters:
  /// - `spacingFactor`, `borderRadiusFactor`, `elevationFactor`:
  ///   Multipliers for each scale.
  /// - `initialSpacing`, `initialBorderRadius`, `initialElevation`:
  ///   The base value for the `*Xs` token.
  /// - `withAlphaFactor`:
  ///   Multiplier used for alpha tokens. Values are clamped into 0..1.
  /// - `initialWithAlpha`:
  ///   Base alpha used for `withAlphaXs` (0..1).
  /// - `animationDurationFactor`:
  ///   Multiplier applied to durations. `long = base * factor^2`.
  /// - `initialAnimationDuration`:
  ///   Base duration (milliseconds) used for `animationDurationShort`.
  ///
  /// Throws:
  /// - [RangeError] if the generated values violate the contracts
  ///   (non-finite values, negatives, non-ascending scales, invalid alpha range, etc.).
  factory ModelDsExtendedTokens.fromFactor({
    double spacingFactor = 2.0,
    double initialSpacing = 4.0,
    double borderRadiusFactor = 2.0,
    double initialBorderRadius = 2.0,
    double elevationFactor = 2.0,
    double initialElevation = 1.0,

    /// ⚠️ `withAlpha` grows upward (0..1), so factor should be > 1 (e.g. 1.5 or 1.25).
    double withAlphaFactor = 1.5,
    double initialWithAlpha = 0.04,
    int animationDurationFactor = 3,
    double initialAnimationDuration = 100.0,
  }) {
    double pNumber(double base, double factor, int exp) {
      double out = base;
      for (int i = 0; i < exp; i++) {
        out *= factor;
      }
      return out;
    }

    int ms(double x) => x.round();

    final ModelDsExtendedTokens out = ModelDsExtendedTokens(
      spacingXs: initialSpacing,
      spacingSm: pNumber(initialSpacing, spacingFactor, 1),
      spacing: pNumber(initialSpacing, spacingFactor, 2),
      spacingLg: pNumber(initialSpacing, spacingFactor, 3),
      spacingXl: pNumber(initialSpacing, spacingFactor, 4),
      spacingXXl: pNumber(initialSpacing, spacingFactor, 5),
      borderRadiusXs: initialBorderRadius,
      borderRadiusSm: pNumber(initialBorderRadius, borderRadiusFactor, 1),
      borderRadius: pNumber(initialBorderRadius, borderRadiusFactor, 2),
      borderRadiusLg: pNumber(initialBorderRadius, borderRadiusFactor, 3),
      borderRadiusXl: pNumber(initialBorderRadius, borderRadiusFactor, 4),
      borderRadiusXXl: pNumber(initialBorderRadius, borderRadiusFactor, 5),
      elevationXs: initialElevation,
      elevationSm: pNumber(initialElevation, elevationFactor, 1),
      elevation: pNumber(initialElevation, elevationFactor, 2),
      elevationLg: pNumber(initialElevation, elevationFactor, 3),
      elevationXl: pNumber(initialElevation, elevationFactor, 4),
      elevationXXl: pNumber(initialElevation, elevationFactor, 5),
      withAlphaXs: initialWithAlpha,
      withAlphaSm: Utils.getDouble(
        pNumber(initialWithAlpha, withAlphaFactor, 1).clamp(0.0, 1.0),
      ),
      withAlpha: Utils.getDouble(
        pNumber(initialWithAlpha, withAlphaFactor, 2).clamp(0.0, 1.0),
      ),
      withAlphaLg: Utils.getDouble(
        pNumber(initialWithAlpha, withAlphaFactor, 3).clamp(0.0, 1.0),
      ),
      withAlphaXl: Utils.getDouble(
        pNumber(initialWithAlpha, withAlphaFactor, 4).clamp(0.0, 1.0),
      ),
      withAlphaXXl: Utils.getDouble(
        pNumber(initialWithAlpha, withAlphaFactor, 5).clamp(0.0, 1.0),
      ),
      animationDurationShort:
          Duration(milliseconds: ms(initialAnimationDuration)),
      animationDuration: Duration(
        milliseconds: ms(initialAnimationDuration * animationDurationFactor),
      ),
      animationDurationLong: Duration(
        milliseconds: ms(
          initialAnimationDuration *
              animationDurationFactor *
              animationDurationFactor,
        ),
      ),
    );

    out._validate();
    return out;
  }

  /// Builds a token set from a JSON map.
  ///
  /// This parser is strict: all keys from [ModelDsExtendedTokensKeys.all]
  /// must be present, otherwise a [FormatException] is thrown.
  ///
  /// Throws:
  /// - [FormatException] if a required key is missing.
  /// - [RangeError] if any parsed value violates the contracts.
  factory ModelDsExtendedTokens.fromJson(Map<String, dynamic> json) {
    for (final String key in ModelDsExtendedTokensKeys.all) {
      if (!json.containsKey(key)) {
        throw FormatException('Missing key: $key');
      }
    }

    double doubleNumber(String key) => Utils.getDouble(json[key]);
    int integerNumber(String key) => Utils.getIntegerFromDynamic(json[key]);

    final ModelDsExtendedTokens out = ModelDsExtendedTokens(
      spacingXs: doubleNumber(ModelDsExtendedTokensKeys.spacingXs),
      spacingSm: doubleNumber(ModelDsExtendedTokensKeys.spacingSm),
      spacing: doubleNumber(ModelDsExtendedTokensKeys.spacing),
      spacingLg: doubleNumber(ModelDsExtendedTokensKeys.spacingLg),
      spacingXl: doubleNumber(ModelDsExtendedTokensKeys.spacingXl),
      spacingXXl: doubleNumber(ModelDsExtendedTokensKeys.spacingXXl),
      borderRadiusXs: doubleNumber(ModelDsExtendedTokensKeys.borderRadiusXs),
      borderRadiusSm: doubleNumber(ModelDsExtendedTokensKeys.borderRadiusSm),
      borderRadius: doubleNumber(ModelDsExtendedTokensKeys.borderRadius),
      borderRadiusLg: doubleNumber(ModelDsExtendedTokensKeys.borderRadiusLg),
      borderRadiusXl: doubleNumber(ModelDsExtendedTokensKeys.borderRadiusXl),
      borderRadiusXXl: doubleNumber(ModelDsExtendedTokensKeys.borderRadiusXXl),
      elevationXs: doubleNumber(ModelDsExtendedTokensKeys.elevationXs),
      elevationSm: doubleNumber(ModelDsExtendedTokensKeys.elevationSm),
      elevation: doubleNumber(ModelDsExtendedTokensKeys.elevation),
      elevationLg: doubleNumber(ModelDsExtendedTokensKeys.elevationLg),
      elevationXl: doubleNumber(ModelDsExtendedTokensKeys.elevationXl),
      elevationXXl: doubleNumber(ModelDsExtendedTokensKeys.elevationXXl),
      withAlphaXs: doubleNumber(ModelDsExtendedTokensKeys.withAlphaXs),
      withAlphaSm: doubleNumber(ModelDsExtendedTokensKeys.withAlphaSm),
      withAlpha: doubleNumber(ModelDsExtendedTokensKeys.withAlpha),
      withAlphaLg: doubleNumber(ModelDsExtendedTokensKeys.withAlphaLg),
      withAlphaXl: doubleNumber(ModelDsExtendedTokensKeys.withAlphaXl),
      withAlphaXXl: doubleNumber(ModelDsExtendedTokensKeys.withAlphaXXl),
      animationDurationShort: Duration(
        milliseconds:
            integerNumber(ModelDsExtendedTokensKeys.animationDurationShort),
      ),
      animationDuration: Duration(
        milliseconds:
            integerNumber(ModelDsExtendedTokensKeys.animationDuration),
      ),
      animationDurationLong: Duration(
        milliseconds:
            integerNumber(ModelDsExtendedTokensKeys.animationDurationLong),
      ),
    );

    out._validate();
    return out;
  }

  final double spacingXs;
  final double spacingSm;
  final double spacing;
  final double spacingLg;
  final double spacingXl;
  final double spacingXXl;

  final double borderRadiusXs;
  final double borderRadiusSm;
  final double borderRadius;
  final double borderRadiusLg;
  final double borderRadiusXl;
  final double borderRadiusXXl;

  final double elevationXs;
  final double elevationSm;
  final double elevation;
  final double elevationLg;
  final double elevationXl;
  final double elevationXXl;

  /// Intended for use with `Color.withOpacity(x)` (0..1).
  final double withAlphaXs;
  final double withAlphaSm;
  final double withAlpha;
  final double withAlphaLg;
  final double withAlphaXl;
  final double withAlphaXXl;

  final Duration animationDurationShort;
  final Duration animationDuration;
  final Duration animationDurationLong;

  /// Returns a new instance with the provided overrides.
  ///
  /// Optimization: if every parameter is `null`, returns `this`.
  ///
  /// Throws:
  /// - [RangeError] if the resulting instance violates the contracts.
  ModelDsExtendedTokens copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacing,
    double? spacingLg,
    double? spacingXl,
    double? spacingXXl,
    double? borderRadiusXs,
    double? borderRadiusSm,
    double? borderRadius,
    double? borderRadiusLg,
    double? borderRadiusXl,
    double? borderRadiusXXl,
    double? elevationXs,
    double? elevationSm,
    double? elevation,
    double? elevationLg,
    double? elevationXl,
    double? elevationXXl,
    double? withAlphaXs,
    double? withAlphaSm,
    double? withAlpha,
    double? withAlphaLg,
    double? withAlphaXl,
    double? withAlphaXXl,
    Duration? animationDurationShort,
    Duration? animationDuration,
    Duration? animationDurationLong,
  }) {
    if (spacingXs == null &&
        spacingSm == null &&
        spacing == null &&
        spacingLg == null &&
        spacingXl == null &&
        spacingXXl == null &&
        borderRadiusXs == null &&
        borderRadiusSm == null &&
        borderRadius == null &&
        borderRadiusLg == null &&
        borderRadiusXl == null &&
        borderRadiusXXl == null &&
        elevationXs == null &&
        elevationSm == null &&
        elevation == null &&
        elevationLg == null &&
        elevationXl == null &&
        elevationXXl == null &&
        withAlphaXs == null &&
        withAlphaSm == null &&
        withAlpha == null &&
        withAlphaLg == null &&
        withAlphaXl == null &&
        withAlphaXXl == null &&
        animationDurationShort == null &&
        animationDuration == null &&
        animationDurationLong == null) {
      return this;
    }

    final ModelDsExtendedTokens out = ModelDsExtendedTokens(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacing: spacing ?? this.spacing,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXXl: spacingXXl ?? this.spacingXXl,
      borderRadiusXs: borderRadiusXs ?? this.borderRadiusXs,
      borderRadiusSm: borderRadiusSm ?? this.borderRadiusSm,
      borderRadius: borderRadius ?? this.borderRadius,
      borderRadiusLg: borderRadiusLg ?? this.borderRadiusLg,
      borderRadiusXl: borderRadiusXl ?? this.borderRadiusXl,
      borderRadiusXXl: borderRadiusXXl ?? this.borderRadiusXXl,
      elevationXs: elevationXs ?? this.elevationXs,
      elevationSm: elevationSm ?? this.elevationSm,
      elevation: elevation ?? this.elevation,
      elevationLg: elevationLg ?? this.elevationLg,
      elevationXl: elevationXl ?? this.elevationXl,
      elevationXXl: elevationXXl ?? this.elevationXXl,
      withAlphaXs: withAlphaXs ?? this.withAlphaXs,
      withAlphaSm: withAlphaSm ?? this.withAlphaSm,
      withAlpha: withAlpha ?? this.withAlpha,
      withAlphaLg: withAlphaLg ?? this.withAlphaLg,
      withAlphaXl: withAlphaXl ?? this.withAlphaXl,
      withAlphaXXl: withAlphaXXl ?? this.withAlphaXXl,
      animationDurationShort:
          animationDurationShort ?? this.animationDurationShort,
      animationDuration: animationDuration ?? this.animationDuration,
      animationDurationLong:
          animationDurationLong ?? this.animationDurationLong,
    );

    out._validate();
    return out;
  }

  /// Returns a JSON representation compatible with [fromJson].
  ///
  /// Durations are serialized as milliseconds (`int`).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelDsExtendedTokensKeys.spacingXs: spacingXs,
      ModelDsExtendedTokensKeys.spacingSm: spacingSm,
      ModelDsExtendedTokensKeys.spacing: spacing,
      ModelDsExtendedTokensKeys.spacingLg: spacingLg,
      ModelDsExtendedTokensKeys.spacingXl: spacingXl,
      ModelDsExtendedTokensKeys.spacingXXl: spacingXXl,
      ModelDsExtendedTokensKeys.borderRadiusXs: borderRadiusXs,
      ModelDsExtendedTokensKeys.borderRadiusSm: borderRadiusSm,
      ModelDsExtendedTokensKeys.borderRadius: borderRadius,
      ModelDsExtendedTokensKeys.borderRadiusLg: borderRadiusLg,
      ModelDsExtendedTokensKeys.borderRadiusXl: borderRadiusXl,
      ModelDsExtendedTokensKeys.borderRadiusXXl: borderRadiusXXl,
      ModelDsExtendedTokensKeys.elevationXs: elevationXs,
      ModelDsExtendedTokensKeys.elevationSm: elevationSm,
      ModelDsExtendedTokensKeys.elevation: elevation,
      ModelDsExtendedTokensKeys.elevationLg: elevationLg,
      ModelDsExtendedTokensKeys.elevationXl: elevationXl,
      ModelDsExtendedTokensKeys.elevationXXl: elevationXXl,
      ModelDsExtendedTokensKeys.withAlphaXs: withAlphaXs,
      ModelDsExtendedTokensKeys.withAlphaSm: withAlphaSm,
      ModelDsExtendedTokensKeys.withAlpha: withAlpha,
      ModelDsExtendedTokensKeys.withAlphaLg: withAlphaLg,
      ModelDsExtendedTokensKeys.withAlphaXl: withAlphaXl,
      ModelDsExtendedTokensKeys.withAlphaXXl: withAlphaXXl,
      ModelDsExtendedTokensKeys.animationDurationShort:
          animationDurationShort.inMilliseconds,
      ModelDsExtendedTokensKeys.animationDuration:
          animationDuration.inMilliseconds,
      ModelDsExtendedTokensKeys.animationDurationLong:
          animationDurationLong.inMilliseconds,
    };
  }

  void _validate() {
    void nonNegative(double v, String name) {
      if (v.isNaN || !v.isFinite) {
        throw RangeError('$name must be finite. Got $v');
      }
      if (v < 0) {
        throw RangeError('$name must be >= 0. Got $v');
      }
    }

    void unit(double v, String name) {
      if (v.isNaN || !v.isFinite) {
        throw RangeError('$name must be finite. Got $v');
      }
      if (v < 0.0 || v > 1.0) {
        throw RangeError('$name must be within 0..1. Got $v');
      }
    }

    void ascending(double a, double b, String aName, String bName) {
      if (a > b) {
        throw RangeError('$aName must be <= $bName. Got $a > $b');
      }
    }

    nonNegative(spacingXs, ModelDsExtendedTokensKeys.spacingXs);
    nonNegative(spacingSm, ModelDsExtendedTokensKeys.spacingSm);
    nonNegative(spacing, ModelDsExtendedTokensKeys.spacing);
    nonNegative(spacingLg, ModelDsExtendedTokensKeys.spacingLg);
    nonNegative(spacingXl, ModelDsExtendedTokensKeys.spacingXl);
    nonNegative(spacingXXl, ModelDsExtendedTokensKeys.spacingXXl);

    ascending(
      spacingXs,
      spacingSm,
      ModelDsExtendedTokensKeys.spacingXs,
      ModelDsExtendedTokensKeys.spacingSm,
    );
    ascending(
      spacingSm,
      spacing,
      ModelDsExtendedTokensKeys.spacingSm,
      ModelDsExtendedTokensKeys.spacing,
    );
    ascending(
      spacing,
      spacingLg,
      ModelDsExtendedTokensKeys.spacing,
      ModelDsExtendedTokensKeys.spacingLg,
    );
    ascending(
      spacingLg,
      spacingXl,
      ModelDsExtendedTokensKeys.spacingLg,
      ModelDsExtendedTokensKeys.spacingXl,
    );
    ascending(
      spacingXl,
      spacingXXl,
      ModelDsExtendedTokensKeys.spacingXl,
      ModelDsExtendedTokensKeys.spacingXXl,
    );

    nonNegative(borderRadiusXs, ModelDsExtendedTokensKeys.borderRadiusXs);
    nonNegative(borderRadiusSm, ModelDsExtendedTokensKeys.borderRadiusSm);
    nonNegative(borderRadius, ModelDsExtendedTokensKeys.borderRadius);
    nonNegative(borderRadiusLg, ModelDsExtendedTokensKeys.borderRadiusLg);
    nonNegative(borderRadiusXl, ModelDsExtendedTokensKeys.borderRadiusXl);
    nonNegative(borderRadiusXXl, ModelDsExtendedTokensKeys.borderRadiusXXl);

    ascending(
      borderRadiusXs,
      borderRadiusSm,
      ModelDsExtendedTokensKeys.borderRadiusXs,
      ModelDsExtendedTokensKeys.borderRadiusSm,
    );
    ascending(
      borderRadiusSm,
      borderRadius,
      ModelDsExtendedTokensKeys.borderRadiusSm,
      ModelDsExtendedTokensKeys.borderRadius,
    );
    ascending(
      borderRadius,
      borderRadiusLg,
      ModelDsExtendedTokensKeys.borderRadius,
      ModelDsExtendedTokensKeys.borderRadiusLg,
    );
    ascending(
      borderRadiusLg,
      borderRadiusXl,
      ModelDsExtendedTokensKeys.borderRadiusLg,
      ModelDsExtendedTokensKeys.borderRadiusXl,
    );
    ascending(
      borderRadiusXl,
      borderRadiusXXl,
      ModelDsExtendedTokensKeys.borderRadiusXl,
      ModelDsExtendedTokensKeys.borderRadiusXXl,
    );

    nonNegative(elevationXs, ModelDsExtendedTokensKeys.elevationXs);
    nonNegative(elevationSm, ModelDsExtendedTokensKeys.elevationSm);
    nonNegative(elevation, ModelDsExtendedTokensKeys.elevation);
    nonNegative(elevationLg, ModelDsExtendedTokensKeys.elevationLg);
    nonNegative(elevationXl, ModelDsExtendedTokensKeys.elevationXl);
    nonNegative(elevationXXl, ModelDsExtendedTokensKeys.elevationXXl);

    ascending(
      elevationXs,
      elevationSm,
      ModelDsExtendedTokensKeys.elevationXs,
      ModelDsExtendedTokensKeys.elevationSm,
    );
    ascending(
      elevationSm,
      elevation,
      ModelDsExtendedTokensKeys.elevationSm,
      ModelDsExtendedTokensKeys.elevation,
    );
    ascending(
      elevation,
      elevationLg,
      ModelDsExtendedTokensKeys.elevation,
      ModelDsExtendedTokensKeys.elevationLg,
    );
    ascending(
      elevationLg,
      elevationXl,
      ModelDsExtendedTokensKeys.elevationLg,
      ModelDsExtendedTokensKeys.elevationXl,
    );
    ascending(
      elevationXl,
      elevationXXl,
      ModelDsExtendedTokensKeys.elevationXl,
      ModelDsExtendedTokensKeys.elevationXXl,
    );

    unit(withAlphaXs, ModelDsExtendedTokensKeys.withAlphaXs);
    unit(withAlphaSm, ModelDsExtendedTokensKeys.withAlphaSm);
    unit(withAlpha, ModelDsExtendedTokensKeys.withAlpha);
    unit(withAlphaLg, ModelDsExtendedTokensKeys.withAlphaLg);
    unit(withAlphaXl, ModelDsExtendedTokensKeys.withAlphaXl);
    unit(withAlphaXXl, ModelDsExtendedTokensKeys.withAlphaXXl);

    ascending(
      withAlphaXs,
      withAlphaSm,
      ModelDsExtendedTokensKeys.withAlphaXs,
      ModelDsExtendedTokensKeys.withAlphaSm,
    );
    ascending(
      withAlphaSm,
      withAlpha,
      ModelDsExtendedTokensKeys.withAlphaSm,
      ModelDsExtendedTokensKeys.withAlpha,
    );
    ascending(
      withAlpha,
      withAlphaLg,
      ModelDsExtendedTokensKeys.withAlpha,
      ModelDsExtendedTokensKeys.withAlphaLg,
    );
    ascending(
      withAlphaLg,
      withAlphaXl,
      ModelDsExtendedTokensKeys.withAlphaLg,
      ModelDsExtendedTokensKeys.withAlphaXl,
    );
    ascending(
      withAlphaXl,
      withAlphaXXl,
      ModelDsExtendedTokensKeys.withAlphaXl,
      ModelDsExtendedTokensKeys.withAlphaXXl,
    );
    if (animationDurationShort.inMilliseconds < 0) {
      throw RangeError('animationDurationShort must be >= 0');
    }
    if (animationDuration.inMilliseconds < 0) {
      throw RangeError('animationDuration must be >= 0');
    }
    if (animationDurationLong.inMilliseconds < 0) {
      throw RangeError('animationDurationLong must be >= 0');
    }
    if (animationDurationShort > animationDuration) {
      throw RangeError('animationDurationShort must be <= animationDuration');
    }
    if (animationDuration > animationDurationLong) {
      throw RangeError('animationDuration must be <= animationDurationLong');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is! ModelDsExtendedTokens) {
      return false;
    }

    return spacingXs == other.spacingXs &&
        spacingSm == other.spacingSm &&
        spacing == other.spacing &&
        spacingLg == other.spacingLg &&
        spacingXl == other.spacingXl &&
        spacingXXl == other.spacingXXl &&
        borderRadiusXs == other.borderRadiusXs &&
        borderRadiusSm == other.borderRadiusSm &&
        borderRadius == other.borderRadius &&
        borderRadiusLg == other.borderRadiusLg &&
        borderRadiusXl == other.borderRadiusXl &&
        borderRadiusXXl == other.borderRadiusXXl &&
        elevationXs == other.elevationXs &&
        elevationSm == other.elevationSm &&
        elevation == other.elevation &&
        elevationLg == other.elevationLg &&
        elevationXl == other.elevationXl &&
        elevationXXl == other.elevationXXl &&
        withAlphaXs == other.withAlphaXs &&
        withAlphaSm == other.withAlphaSm &&
        withAlpha == other.withAlpha &&
        withAlphaLg == other.withAlphaLg &&
        withAlphaXl == other.withAlphaXl &&
        withAlphaXXl == other.withAlphaXXl &&
        animationDurationShort == other.animationDurationShort &&
        animationDuration == other.animationDuration &&
        animationDurationLong == other.animationDurationLong;
  }

  @override
  int get hashCode =>
      spacingXs.hashCode ^
      (spacingSm.hashCode * 3) ^
      (spacing.hashCode * 5) ^
      (spacingLg.hashCode * 7) ^
      (spacingXl.hashCode * 11) ^
      (spacingXXl.hashCode * 13) ^
      (borderRadiusXs.hashCode * 17) ^
      (borderRadiusSm.hashCode * 19) ^
      (borderRadius.hashCode * 23) ^
      (borderRadiusLg.hashCode * 29) ^
      (borderRadiusXl.hashCode * 31) ^
      (borderRadiusXXl.hashCode * 37) ^
      (elevationXs.hashCode * 41) ^
      (elevationSm.hashCode * 43) ^
      (elevation.hashCode * 47) ^
      (elevationLg.hashCode * 53) ^
      (elevationXl.hashCode * 59) ^
      (elevationXXl.hashCode * 61) ^
      (withAlphaXs.hashCode * 67) ^
      (withAlphaSm.hashCode * 71) ^
      (withAlpha.hashCode * 73) ^
      (withAlphaLg.hashCode * 79) ^
      (withAlphaXl.hashCode * 83) ^
      (withAlphaXXl.hashCode * 89) ^
      (animationDurationShort.inMilliseconds.hashCode * 97) ^
      (animationDuration.inMilliseconds.hashCode * 101) ^
      (animationDurationLong.inMilliseconds.hashCode * 103);
}
