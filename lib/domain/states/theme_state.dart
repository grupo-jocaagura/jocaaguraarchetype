part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for ThemeState.
enum ThemeEnum {
  mode,
  seed,
  useM3,
  textScale,
  preset,
  overrides,
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

@immutable
class ThemeOverrides {
  const ThemeOverrides({this.light, this.dark});

  final ColorScheme? light;
  final ColorScheme? dark;

  ThemeOverrides copyWith({ColorScheme? light, ColorScheme? dark}) =>
      ThemeOverrides(light: light ?? this.light, dark: dark ?? this.dark);

  Map<String, dynamic> toJson() => <String, dynamic>{
        ThemeOverridesEnum.light.name:
            light == null ? null : _schemeToMap(light!),
        ThemeOverridesEnum.dark.name: dark == null ? null : _schemeToMap(dark!),
      };

  static ThemeOverrides? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return ThemeOverrides(
      light: _mapToScheme(
        json[ThemeOverridesEnum.light.name] as Map<String, dynamic>?,
      ),
      dark: _mapToScheme(
        json[ThemeOverridesEnum.dark.name] as Map<String, dynamic>?,
      ),
    );
  }

  static Map<String, dynamic> _schemeToMap(ColorScheme s) => <String, dynamic>{
        ColorSchemeEnum.brightness.name: s.brightness.name,
        ColorSchemeEnum.primary.name: s.primary.toARGB32(),
        ColorSchemeEnum.onPrimary.name: s.onPrimary.toARGB32(),
        ColorSchemeEnum.secondary.name: s.secondary.toARGB32(),
        ColorSchemeEnum.onSecondary.name: s.onSecondary.toARGB32(),
        ColorSchemeEnum.tertiary.name: s.tertiary.toARGB32(),
        ColorSchemeEnum.onTertiary.name: s.onTertiary.toARGB32(),
        ColorSchemeEnum.error.name: s.error.toARGB32(),
        ColorSchemeEnum.onError.name: s.onError.toARGB32(),
        ColorSchemeEnum.surface.name: s.surface.toARGB32(),
        ColorSchemeEnum.onSurface.name: s.onSurface.toARGB32(),
        ColorSchemeEnum.surfaceTint.name: s.surfaceTint.toARGB32(),
        ColorSchemeEnum.outline.name: s.outline.toARGB32(),
        ColorSchemeEnum.onSurfaceVariant.name: s.onSurfaceVariant.toARGB32(),
        ColorSchemeEnum.inverseSurface.name: s.inverseSurface.toARGB32(),
        ColorSchemeEnum.inversePrimary.name: s.inversePrimary.toARGB32(),
      };

  static ColorScheme? _mapToScheme(Map<String, dynamic>? m) {
    if (m == null) {
      return null;
    }
    final Brightness b = (m[ColorSchemeEnum.brightness.name] == 'dark')
        ? Brightness.dark
        : Brightness.light;
    Color c(int v) => Color((v as num).toInt());
    return ColorScheme(
      brightness: b,
      primary: c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.primary.name])),
      onPrimary:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.onPrimary.name])),
      secondary:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.secondary.name])),
      onSecondary:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.onSecondary.name])),
      tertiary:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.tertiary.name])),
      onTertiary:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.onTertiary.name])),
      error: c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.error.name])),
      onError: c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.onError.name])),
      surface: c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.surface.name])),
      onSurface:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.onSurface.name])),
      surfaceTint:
          c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.surfaceTint.name])),
      outline: c(Utils.getIntegerFromDynamic(m[ColorSchemeEnum.outline.name])),
      onSurfaceVariant: c(
        Utils.getIntegerFromDynamic(
          m[ColorSchemeEnum.onSurfaceVariant.name],
        ),
      ),
      inverseSurface: c(
        Utils.getIntegerFromDynamic(m[ColorSchemeEnum.inverseSurface.name]),
      ),
      inversePrimary: c(
        Utils.getIntegerFromDynamic(m[ColorSchemeEnum.inversePrimary.name]),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    } else if (other is ThemeOverrides) {
      return _schemeEquals(light, other.light) &&
          _schemeEquals(dark, other.dark);
    }
    return false;
  }

  @override
  int get hashCode => _schemeHash(light) ^ (_schemeHash(dark) * 31);

  static bool _schemeEquals(ColorScheme? a, ColorScheme? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    return a.brightness == b.brightness &&
        a.primary == b.primary &&
        a.onPrimary == b.onPrimary &&
        a.secondary == b.secondary &&
        a.onSecondary == b.onSecondary &&
        a.tertiary == b.tertiary &&
        a.onTertiary == b.onTertiary &&
        a.error == b.error &&
        a.onError == b.onError &&
        a.surface == b.surface &&
        a.onSurface == b.onSurface &&
        a.surfaceTint == b.surfaceTint &&
        a.outline == b.outline &&
        a.onSurfaceVariant == b.onSurfaceVariant &&
        a.inverseSurface == b.inverseSurface &&
        a.inversePrimary == b.inversePrimary;
  }

  static int _schemeHash(ColorScheme? s) {
    if (s == null) {
      return 0;
    }
    int h = s.brightness.hashCode;
    h = 0x1fffffff & (h ^ s.primary.hashCode);
    h = 0x1fffffff & (h ^ s.onPrimary.hashCode);
    h = 0x1fffffff & (h ^ s.secondary.hashCode);
    h = 0x1fffffff & (h ^ s.onSecondary.hashCode);
    h = 0x1fffffff & (h ^ s.tertiary.hashCode);
    h = 0x1fffffff & (h ^ s.onTertiary.hashCode);
    h = 0x1fffffff & (h ^ s.error.hashCode);
    h = 0x1fffffff & (h ^ s.onError.hashCode);
    h = 0x1fffffff & (h ^ s.surface.hashCode);
    h = 0x1fffffff & (h ^ s.onSurface.hashCode);
    h = 0x1fffffff & (h ^ s.surfaceTint.hashCode);
    h = 0x1fffffff & (h ^ s.outline.hashCode);
    h = 0x1fffffff & (h ^ s.onSurfaceVariant.hashCode);
    h = 0x1fffffff & (h ^ s.inverseSurface.hashCode);
    h = 0x1fffffff & (h ^ s.inversePrimary.hashCode);
    return h;
  }
}

@immutable
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.seed,
    required this.useMaterial3,
    this.textScale = 1.0,
    this.preset = 'brand',
    this.overrides,
  });

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final String modeName = Utils.getStringFromDynamic(
      json[ThemeEnum.mode.name],
    );
    return ThemeState(
      mode: ThemeMode.values.firstWhere(
        (ThemeMode e) => e.name == (modeName.isNotEmpty ? modeName : 'system'),
        orElse: () => ThemeMode.system,
      ),
      seed: Color(
        Utils.getIntegerFromDynamic(json[ThemeEnum.seed.name]) > 0
            ? Utils.getIntegerFromDynamic(json[ThemeEnum.seed.name])
            : 0xFF6750A4,
      ),
      useMaterial3: Utils.getBoolFromDynamic(json[ThemeEnum.useM3.name]),
      textScale: Utils.getDouble(json[ThemeEnum.textScale.name], 1.0),
      preset: (() {
        final String p =
            Utils.getStringFromDynamic(json[ThemeEnum.preset.name]);
        return p.isEmpty ? 'brand' : p;
      })(),
      overrides: json[ThemeEnum.overrides.name] == null
          ? null
          : ThemeOverrides.fromJson(
              Utils.mapFromDynamic(json[ThemeEnum.overrides.name]),
            ),
    );
  }

  final ThemeMode mode;
  final Color seed;
  final bool useMaterial3;
  final double textScale;
  final String preset;
  final ThemeOverrides? overrides;

  ThemeState copyWith({
    ThemeMode? mode,
    Color? seed,
    bool? useMaterial3,
    double? textScale,
    String? preset,
    ThemeOverrides? overrides,
  }) =>
      ThemeState(
        mode: mode ?? this.mode,
        seed: seed ?? this.seed,
        useMaterial3: useMaterial3 ?? this.useMaterial3,
        textScale: textScale ?? this.textScale,
        preset: preset ?? this.preset,
        overrides: overrides ?? this.overrides,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        ThemeEnum.mode.name: mode.name,
        ThemeEnum.seed.name: seed.toARGB32(),
        ThemeEnum.useM3.name: useMaterial3,
        ThemeEnum.textScale.name: textScale,
        ThemeEnum.preset.name: preset,
        ThemeEnum.overrides.name: overrides?.toJson(),
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
        : Utils.getDouble(textScale!.clamp(0.8, 1.6));
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
