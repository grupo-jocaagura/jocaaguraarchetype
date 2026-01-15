part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for [ModelSemanticColors].
///
/// Notes:
/// - Keys are intentionally stable to support export/import.
/// - The [explain] field is informational only and is not part of [all].
abstract final class ModelSemanticColorsKeys {
  static const String explain = 'Semantic colors for domain states';
  static const String success = 'success';
  static const String onSuccess = 'onSuccess';
  static const String successContainer = 'successContainer';
  static const String onSuccessContainer = 'onSuccessContainer';

  static const String warning = 'warning';
  static const String onWarning = 'onWarning';
  static const String warningContainer = 'warningContainer';
  static const String onWarningContainer = 'onWarningContainer';

  static const String info = 'info';
  static const String onInfo = 'onInfo';
  static const String infoContainer = 'infoContainer';
  static const String onInfoContainer = 'onInfoContainer';

  static const List<String> all = <String>[
    success,
    onSuccess,
    successContainer,
    onSuccessContainer,
    warning,
    onWarning,
    warningContainer,
    onWarningContainer,
    info,
    onInfo,
    infoContainer,
    onInfoContainer,
  ];
}

/// Defines semantic colors for domain states (success/warning/info).
///
/// This model provides:
/// - A strict JSON shape via [toJson] and [fromJson].
/// - Recommended fallback palettes for light/dark surfaces.
/// - Derivation from a [ColorScheme] to stay aligned with brand/seed colors.
/// - A minimal contrast validation (contrast ratio >= 3.0) for each bg/fg pair.
///
/// Semantic pairs:
/// - `success` / `onSuccess`
/// - `successContainer` / `onSuccessContainer`
/// - `warning` / `onWarning`
/// - `warningContainer` / `onWarningContainer`
/// - `info` / `onInfo`
/// - `infoContainer` / `onInfoContainer`
///
/// Functional example:
/// ```dart
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final ColorScheme cs = ColorScheme.fromSeed(
///     seedColor: const Color(0xFF6750A4),
///     brightness: Brightness.light,
///   );
///
///   final ModelSemanticColors semantic = ModelSemanticColors.fromColorScheme(cs);
///   final Map<String, dynamic> json = semantic.toJson();
///   final ModelSemanticColors restored = ModelSemanticColors.fromJson(json);
///
///   assert(semantic == restored);
///   print(restored.success); // A semantic success color for the scheme.
/// }
/// ```
///
/// Contracts:
/// - Each "on*" color must have a contrast ratio >= 3.0 with its background.
///
/// Throws:
/// - [RangeError] if contrast validation fails.
/// - [FormatException] if a required JSON key is missing in [fromJson].
@immutable
class ModelSemanticColors {
  const ModelSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  /// Recommended default palette for light surfaces.
  ///
  /// Throws:
  /// - [RangeError] if internal contrast validation fails (should not happen).
  factory ModelSemanticColors.fallbackLight() {
    // Defaults inspired by Material-ish tones (safe + readable on light).
    const Color success = Color(0xFF2E7D32);
    const Color warning = Color(0xFFED6C02);
    const Color info = Color(0xFF0288D1);

    const Color successContainer = Color(0xFFB9F6CA);
    const Color warningContainer = Color(0xFFFFE0B2);
    const Color infoContainer = Color(0xFFB3E5FC);

    return const ModelSemanticColors(
      success: success,
      onSuccess: Colors.white,
      successContainer: successContainer,
      onSuccessContainer: Color(0xFF0B2E13),
      warning: warning,
      onWarning: Colors.white,
      warningContainer: warningContainer,
      onWarningContainer: Color(0xFF3A1F00),
      info: info,
      onInfo: Colors.white,
      infoContainer: infoContainer,
      onInfoContainer: Color(0xFF001E2C),
    ).._validate();
  }

  /// Recommended default palette for dark surfaces.
  ///
  /// Throws:
  /// - [RangeError] if internal contrast validation fails (should not happen).
  factory ModelSemanticColors.fallbackDark() {
    const Color success = Color(0xFF66BB6A);
    const Color warning = Color(0xFFFFB74D);
    const Color info = Color(0xFF4FC3F7);

    const Color successContainer = Color(0xFF1B5E20);
    const Color warningContainer = Color(0xFF4E2B00);
    const Color infoContainer = Color(0xFF004B73);

    return const ModelSemanticColors(
      success: success,
      onSuccess: Color(0xFF06220B),
      successContainer: successContainer,
      onSuccessContainer: Color(0xFFE6F7EA),
      warning: warning,
      onWarning: Color(0xFF2A1500),
      warningContainer: warningContainer,
      onWarningContainer: Color(0xFFFFE9D1),
      info: info,
      onInfo: Color(0xFF001F2B),
      infoContainer: infoContainer,
      onInfoContainer: Color(0xFFE1F4FF),
    ).._validate();
  }

  /// Derives semantic colors from a [ColorScheme].
  ///
  /// Strategy:
  /// - Picks base hues depending on [ColorScheme.brightness].
  /// - Builds container colors by alpha-blending over `cs.surface` so they feel
  ///   native to the theme.
  /// - Chooses "on" colors (black/white) based on luminance.
  ///
  /// Throws:
  /// - [RangeError] if contrast validation fails.
  factory ModelSemanticColors.fromColorScheme(ColorScheme cs) {
    final Color success = _toneForBrightness(
      light: const Color(0xFF2E7D32),
      dark: const Color(0xFF66BB6A),
      brightness: cs.brightness,
    );

    final Color warning = _toneForBrightness(
      light: const Color(0xFFED6C02),
      dark: const Color(0xFFFFB74D),
      brightness: cs.brightness,
    );

    final Color info = _toneForBrightness(
      light: const Color(0xFF0288D1),
      dark: const Color(0xFF4FC3F7),
      brightness: cs.brightness,
    );

    // Containers: alpha-blend over surface to feel “native” in each theme.
    Color containerOf(Color base) {
      final double a = (cs.brightness == Brightness.dark) ? 0.28 : 0.18;
      return Color.alphaBlend(base.withValues(alpha: a), cs.surface);
    }

    final Color successContainer = containerOf(success);
    final Color warningContainer = containerOf(warning);
    final Color infoContainer = containerOf(info);

    final Color onSuccess = _onColorFor(success);
    final Color onWarning = _onColorFor(warning);
    final Color onInfo = _onColorFor(info);

    final Color onSuccessContainer = _onColorFor(successContainer);
    final Color onWarningContainer = _onColorFor(warningContainer);
    final Color onInfoContainer = _onColorFor(infoContainer);

    return ModelSemanticColors(
      success: success,
      onSuccess: onSuccess,
      successContainer: successContainer,
      onSuccessContainer: onSuccessContainer,
      warning: warning,
      onWarning: onWarning,
      warningContainer: warningContainer,
      onWarningContainer: onWarningContainer,
      info: info,
      onInfo: onInfo,
      infoContainer: infoContainer,
      onInfoContainer: onInfoContainer,
    ).._validate();
  }

  /// Builds an instance from a strict JSON payload.
  ///
  /// All keys listed in [ModelSemanticColorsKeys.all] must exist.
  ///
  /// Throws:
  /// - [FormatException] if a required key is missing.
  /// - [RangeError] if contrast validation fails.
  factory ModelSemanticColors.fromJson(Map<String, dynamic> json) {
    for (final String key in ModelSemanticColorsKeys.all) {
      if (!json.containsKey(key)) {
        throw FormatException('Missing key: $key');
      }
    }

    Color c(String key) => Color(Utils.getIntegerFromDynamic(json[key]));

    final ModelSemanticColors out = ModelSemanticColors(
      success: c(ModelSemanticColorsKeys.success),
      onSuccess: c(ModelSemanticColorsKeys.onSuccess),
      successContainer: c(ModelSemanticColorsKeys.successContainer),
      onSuccessContainer: c(ModelSemanticColorsKeys.onSuccessContainer),
      warning: c(ModelSemanticColorsKeys.warning),
      onWarning: c(ModelSemanticColorsKeys.onWarning),
      warningContainer: c(ModelSemanticColorsKeys.warningContainer),
      onWarningContainer: c(ModelSemanticColorsKeys.onWarningContainer),
      info: c(ModelSemanticColorsKeys.info),
      onInfo: c(ModelSemanticColorsKeys.onInfo),
      infoContainer: c(ModelSemanticColorsKeys.infoContainer),
      onInfoContainer: c(ModelSemanticColorsKeys.onInfoContainer),
    );

    out._validate();
    return out;
  }

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  /// Serializes this instance into a JSON map compatible with [fromJson].
  ///
  /// Colors are encoded as ARGB 32-bit integers.
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelSemanticColorsKeys.success: success.toARGB32(),
        ModelSemanticColorsKeys.onSuccess: onSuccess.toARGB32(),
        ModelSemanticColorsKeys.successContainer: successContainer.toARGB32(),
        ModelSemanticColorsKeys.onSuccessContainer:
            onSuccessContainer.toARGB32(),
        ModelSemanticColorsKeys.warning: warning.toARGB32(),
        ModelSemanticColorsKeys.onWarning: onWarning.toARGB32(),
        ModelSemanticColorsKeys.warningContainer: warningContainer.toARGB32(),
        ModelSemanticColorsKeys.onWarningContainer:
            onWarningContainer.toARGB32(),
        ModelSemanticColorsKeys.info: info.toARGB32(),
        ModelSemanticColorsKeys.onInfo: onInfo.toARGB32(),
        ModelSemanticColorsKeys.infoContainer: infoContainer.toARGB32(),
        ModelSemanticColorsKeys.onInfoContainer: onInfoContainer.toARGB32(),
      };

  /// Returns a copy with optional overrides.
  ///
  /// Throws:
  /// - [RangeError] if the resulting instance fails contrast validation.
  ModelSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return ModelSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    ).._validate();
  }

  void _validate() {
    // Minimal: ensure "on" contrasts with background at least reasonably.
    // We keep it simple and deterministic: contrast ratio >= 3.0.
    _minContrast(success, onSuccess, 'success/onSuccess');
    _minContrast(
      successContainer,
      onSuccessContainer,
      'successContainer/onSuccessContainer',
    );
    _minContrast(warning, onWarning, 'warning/onWarning');
    _minContrast(
      warningContainer,
      onWarningContainer,
      'warningContainer/onWarningContainer',
    );
    _minContrast(info, onInfo, 'info/onInfo');
    _minContrast(
      infoContainer,
      onInfoContainer,
      'infoContainer/onInfoContainer',
    );
  }

  static void _minContrast(Color bg, Color fg, String name) {
    final double ratio = _contrastRatio(bg, fg);
    if (ratio < 3.0) {
      throw RangeError('$name contrast too low. Got $ratio (< 3.0)');
    }
  }

  static double _contrastRatio(Color a, Color b) {
    final double l1 = a.computeLuminance();
    final double l2 = b.computeLuminance();
    final double hi = (l1 > l2) ? l1 : l2;
    final double lo = (l1 > l2) ? l2 : l1;
    return (hi + 0.05) / (lo + 0.05);
  }

  static Color _onColorFor(Color background) {
    const Color white = Colors.white;
    const Color black = Colors.black;

    final double cWhite = _contrastRatio(background, white);
    final double cBlack = _contrastRatio(background, black);

    return (cWhite >= cBlack) ? white : black;
  }

  static Color _toneForBrightness({
    required Color light,
    required Color dark,
    required Brightness brightness,
  }) {
    return brightness == Brightness.dark ? dark : light;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is! ModelSemanticColors) {
      return false;
    }

    return success == other.success &&
        onSuccess == other.onSuccess &&
        successContainer == other.successContainer &&
        onSuccessContainer == other.onSuccessContainer &&
        warning == other.warning &&
        onWarning == other.onWarning &&
        warningContainer == other.warningContainer &&
        onWarningContainer == other.onWarningContainer &&
        info == other.info &&
        onInfo == other.onInfo &&
        infoContainer == other.infoContainer &&
        onInfoContainer == other.onInfoContainer;
  }

  @override
  int get hashCode =>
      success.hashCode ^
      (onSuccess.hashCode * 3) ^
      (successContainer.hashCode * 5) ^
      (onSuccessContainer.hashCode * 7) ^
      (warning.hashCode * 11) ^
      (onWarning.hashCode * 13) ^
      (warningContainer.hashCode * 17) ^
      (onWarningContainer.hashCode * 19) ^
      (info.hashCode * 23) ^
      (onInfo.hashCode * 29) ^
      (infoContainer.hashCode * 31) ^
      (onInfoContainer.hashCode * 37);
}
