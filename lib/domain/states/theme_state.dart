// File: lib/src/theme_state.dart
part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for ThemeState.
enum ThemeEnum {
  mode,
  seed,
  useM3,
  textScale,
  preset,
  overrides,
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

/// Immutable theme state model with canonical JSON serialization.
///
/// - Colors are **always** serialized as HEX `#AARRGGBB` (uppercase) to ensure
///   round-trip determinism.
/// - `fromJson` accepts legacy ARGB integers for backward compatibility but
///   re-serializes to HEX on `toJson`.
/// - Optional `createdAt` is serialized as UTC ISO8601 if present; it is
///   treated as metadata and **excluded** from equality and hashing.
///
/// ### Example
/// ```dart
/// final ThemeState s = ThemeState.defaults.copyWith(
///   mode: ThemeMode.dark,
///   seed: const Color(0xFF0061A4),
///   createdAt: DateTime.now().toUtc(),
/// );
/// final Map<String, dynamic> json = s.toJson();
/// final ThemeState round = ThemeState.fromJson(json);
/// assert(s == round); // createdAt ignored for equality
/// ```
@immutable
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.seed,
    required this.useMaterial3,
    this.textScale = 1.0,
    this.preset = 'brand',
    this.overrides,
    this.createdAt,
  });

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

    final DateTime? parsedCreatedAt =
        UtilsForTheme.asUtcInstant(json, ThemeEnum.createdAt.name);

    return ThemeState(
      mode: parsedMode,
      seed: parsedSeed,
      useMaterial3: parsedM3,
      textScale: parsedScale,
      preset: parsedPreset,
      overrides: ov,
      createdAt: parsedCreatedAt,
    );
  }

  final ThemeMode mode;
  final Color seed;
  final bool useMaterial3;
  final double textScale;
  final String preset;
  final ThemeOverrides? overrides;

  /// Optional UTC creation time (metadata, ignored for equality/hash).
  final DateTime? createdAt;

  ThemeState copyWith({
    ThemeMode? mode,
    Color? seed,
    bool? useMaterial3,
    double? textScale,
    String? preset,
    ThemeOverrides? overrides,
    DateTime? createdAt,
  }) =>
      ThemeState(
        mode: mode ?? this.mode,
        seed: seed ?? this.seed,
        useMaterial3: useMaterial3 ?? this.useMaterial3,
        textScale: textScale ?? this.textScale,
        preset: preset ?? this.preset,
        overrides: overrides ?? this.overrides,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        ThemeEnum.mode.name: mode.name,
        ThemeEnum.seed.name: UtilsForTheme.colorToHex(seed),
        ThemeEnum.useM3.name: useMaterial3,
        ThemeEnum.textScale.name: textScale,
        ThemeEnum.preset.name: preset,
        ThemeEnum.overrides.name: overrides?.toJson(),
        if (createdAt != null)
          ThemeEnum.createdAt.name: createdAt!.toUtc().toIso8601String(),
      };

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
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is ThemeState) {
      return mode == other.mode &&
          seed == other.seed &&
          useMaterial3 == other.useMaterial3 &&
          textScale == other.textScale &&
          preset == other.preset &&
          overrides == other.overrides;
    }
    return false;
  }

  @override
  int get hashCode {
    int h = mode.hashCode ^ seed.hashCode ^ useMaterial3.hashCode;
    h = 0x1fffffff & (h ^ textScale.hashCode);
    h = 0x1fffffff & (h ^ preset.hashCode);
    h = 0x1fffffff & (h ^ (overrides?.hashCode ?? 0));
    return h;
  }
}
