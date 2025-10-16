part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for ThemeState.
enum ThemeEnum {
  mode,
  seed,
  useM3,
  textScale,
  preset,
  overrides,
  textOverrides,
  createdAt,
}

/// JSON keys for ThemeOverrides payload.
enum ThemeOverridesEnum {
  light,
  dark,
}

/// JSON keys inside a ColorScheme serialization.
enum ColorSchemeEnum {
  brightness,
  primary,
  onPrimary,
  secondary,
  onSecondary,
  tertiary,
  onTertiary,
  error,
  onError,
  surface,
  onSurface,
  surfaceTint,
  outline,
  onSurfaceVariant,
  inverseSurface,
  inversePrimary,
}

/// Immutable theme state with canonical JSON serialization.
///
/// ## Behavior
/// - Colors are serialized as uppercase `#AARRGGBB` for deterministic round trips.
/// - `fromJson` accepts legacy ARGB integers for `seed` and re-serializes to HEX.
/// - `createdAt` is metadata (UTC ISO-8601) and **excluded** from equality and `hashCode`.
///
/// ## Contracts
/// - `textScale` must be finite (`isFinite`); otherwise a [FormatException] is thrown.
/// - Missing or invalid `mode` falls back to [ThemeMode.system].
/// - If provided, `createdAt` is normalized to UTC on `toJson()`.
///
/// ## Caveats
/// - `copyWith` does not support nulling optional fields (`overrides`, `textOverrides`, `createdAt`);
///   passing `null` keeps the previous value.
/// - The behavior when `useMaterial3` is **absent** in JSON depends on `UtilsForTheme.asBoolStrict`.
///   Consumers should ensure the key is present or provide a migration step.
///
/// ## Functional example
/// ```dart
/// import 'package:flutter/material.dart';
///
/// void main() {
///   // Given an initial theme state
///   final ThemeState initial = ThemeState.defaults.copyWith(
///     mode: ThemeMode.dark,
///     seed: const Color(0xFF0061A4),
///     textScale: 1.0,
///     // Optional text overrides example (light only shown here)
///     textOverrides: const TextThemeOverrides(
///       light: TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
///     ),
///     createdAt: DateTime.now().toUtc(),
///   );
///
///   // When serialized to JSON
///   final Map<String, dynamic> json = initial.toJson();
///
///   // Then deserializing produces an equal value (metadata excluded from equality)
///   final ThemeState roundTrip = ThemeState.fromJson(json);
///   assert(initial == roundTrip);
///
///   // And changing only createdAt keeps equality true (metadata)
///   final ThemeState changedMeta = initial.copyWith(createdAt: DateTime.now().toUtc());
///   assert(initial == changedMeta);
/// }
/// ```
///
/// See also:
/// - [ThemeOverrides] for color-scheme overrides.
/// - [TextThemeOverrides] for per-scheme text overrides.
@immutable
class ThemeState {
  /// Creates an immutable [ThemeState].
  ///
  /// - [mode]: Theme mode (system/light/dark).
  /// - [seed]: Seed color for palettes.
  /// - [useMaterial3]: Whether Material 3 is enabled.
  /// - [textScale]: Typography scale factor (default `1.0`, must be finite).
  /// - [preset]: Preset name (defaults to `'brand'` when empty/missing in JSON).
  /// - [overrides]: Per-scheme `ColorScheme` overrides (light/dark).
  /// - [textOverrides]: Per-scheme `TextTheme` overrides (light/dark).
  /// - [createdAt]: UTC ISO8601 timestamp (metadata; excluded from equality).
  const ThemeState({
    required this.mode,
    required this.seed,
    required this.useMaterial3,
    this.textScale = 1.0,
    this.preset = 'brand',
    this.overrides,
    this.textOverrides,
    this.createdAt,
  });

  /// Deserializes [ThemeState] from JSON with backward-compat rules.
  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final String modeName =
        UtilsForTheme.asStringOrEmpty(json, ThemeEnum.mode.name);
    final ThemeMode parsedMode = ThemeMode.values.firstWhere(
      (ThemeMode themeMode) =>
          themeMode.name == (modeName.isNotEmpty ? modeName : 'system'),
      orElse: () => ThemeMode.system,
    );

    final dynamic seedRaw = json[ThemeEnum.seed.name];
    final Color parsedSeed = seedRaw == null
        ? const Color(0xFF6750A4)
        : UtilsForTheme.parseColorCanonical(seedRaw, path: ThemeEnum.seed.name);

    final bool parsedM3 =
        UtilsForTheme.asBoolStrict(json, ThemeEnum.useM3.name);

    final double parsedScale =
        UtilsForTheme.asDoubleStrict(json, ThemeEnum.textScale.name, 1.0);
    if (!parsedScale.isFinite) {
      throw const FormatException('ThemeState.textScale invalid');
    }

    final String prevPreset =
        UtilsForTheme.asStringOrEmpty(json, ThemeEnum.preset.name);
    final String parsedPreset = prevPreset.isEmpty ? 'brand' : prevPreset;

    final ThemeOverrides? ov = json[ThemeEnum.overrides.name] == null
        ? null
        : ThemeOverrides.fromJson(
            UtilsForTheme.asMapStrict(json, ThemeEnum.overrides.name),
          );

    final TextThemeOverrides? tov = json[ThemeEnum.textOverrides.name] == null
        ? null
        : TextThemeOverrides.fromJson(
            UtilsForTheme.asMapStrict(json, ThemeEnum.textOverrides.name),
          );

    final DateTime? parsedCreatedAt =
        UtilsForTheme.asUtcInstant(json, ThemeEnum.createdAt.name);

    return ThemeState(
      mode: parsedMode,
      seed: parsedSeed,
      useMaterial3: parsedM3,
      textScale: parsedScale,
      preset: parsedPreset,
      overrides: ov,
      textOverrides: tov,
      createdAt: parsedCreatedAt,
    );
  }

  /// Current theme mode.
  final ThemeMode mode;

  /// Seed color.
  final Color seed;

  /// Enables Material 3.
  final bool useMaterial3;

  /// Typography scale factor (must be finite).
  final double textScale;

  /// Preset name.
  final String preset;

  /// Explicit ColorScheme overrides.
  final ThemeOverrides? overrides;

  /// Explicit TextTheme overrides (light/dark).
  final TextThemeOverrides? textOverrides;

  /// Optional UTC timestamp (metadata; ignored in equality/hashCode).
  final DateTime? createdAt;

  /// Returns a copy with selected changes.
  ThemeState copyWith({
    ThemeMode? mode,
    Color? seed,
    bool? useMaterial3,
    double? textScale,
    String? preset,
    ThemeOverrides? overrides,
    TextThemeOverrides? textOverrides,
    DateTime? createdAt,
  }) =>
      ThemeState(
        mode: mode ?? this.mode,
        seed: seed ?? this.seed,
        useMaterial3: useMaterial3 ?? this.useMaterial3,
        textScale: textScale ?? this.textScale,
        preset: preset ?? this.preset,
        overrides: overrides ?? this.overrides,
        textOverrides: textOverrides ?? this.textOverrides,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Serializes to canonical JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        ThemeEnum.mode.name: mode.name,
        ThemeEnum.seed.name: UtilsForTheme.colorToHex(seed),
        ThemeEnum.useM3.name: useMaterial3,
        ThemeEnum.textScale.name: textScale,
        ThemeEnum.preset.name: preset,
        ThemeEnum.overrides.name: overrides?.toJson(),
        ThemeEnum.textOverrides.name: textOverrides?.toJson(),
        if (createdAt != null)
          ThemeEnum.createdAt.name: createdAt!.toUtc().toIso8601String(),
      };

  /// Default state.
  static const ThemeState defaults = ThemeState(
    mode: ThemeMode.system,
    seed: Color(0xFF6750A4),
    useMaterial3: true,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType || other is! ThemeState) {
      return false;
    }

    return mode == other.mode &&
        seed == other.seed &&
        useMaterial3 == other.useMaterial3 &&
        textScale == other.textScale &&
        preset == other.preset &&
        overrides == other.overrides &&
        textOverrides == other.textOverrides;
  }

  @override
  int get hashCode {
    int h = mode.hashCode ^ seed.hashCode ^ useMaterial3.hashCode;
    h = 0x1fffffff & (h ^ textScale.hashCode);
    h = 0x1fffffff & (h ^ preset.hashCode);
    h = 0x1fffffff & (h ^ (overrides?.hashCode ?? 0));
    h = 0x1fffffff &
        (h ^ (textOverrides?.hashCode ?? 0)); // include textOverrides
    return h;
  }
}
