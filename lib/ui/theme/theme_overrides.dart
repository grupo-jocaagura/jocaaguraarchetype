part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Per-scheme color overrides (light/dark) using canonical HEX serialization.
///
/// Each `ColorScheme` is serialized field-by-field with HEX `#AARRGGBB`.
/// Omitted fields are not allowed; provide complete schemes for determinism.
///
/// ### Example
/// ```dart
/// final ThemeOverrides ov = ThemeOverrides(
///   light: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
///   dark: ColorScheme.fromSeed(
///     seedColor: const Color(0xFF6750A4),
///     brightness: Brightness.dark,
///   ),
/// );
/// final Map<String, dynamic> m = ov.toJson();
/// final ThemeOverrides r = ThemeOverrides.fromJson(m)!;
/// assert(ov == r);
/// ```
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
        ColorSchemeEnum.primary.name: UtilsForTheme.colorToHex(s.primary),
        ColorSchemeEnum.onPrimary.name: UtilsForTheme.colorToHex(s.onPrimary),
        ColorSchemeEnum.secondary.name: UtilsForTheme.colorToHex(s.secondary),
        ColorSchemeEnum.onSecondary.name:
            UtilsForTheme.colorToHex(s.onSecondary),
        ColorSchemeEnum.tertiary.name: UtilsForTheme.colorToHex(s.tertiary),
        ColorSchemeEnum.onTertiary.name: UtilsForTheme.colorToHex(s.onTertiary),
        ColorSchemeEnum.error.name: UtilsForTheme.colorToHex(s.error),
        ColorSchemeEnum.onError.name: UtilsForTheme.colorToHex(s.onError),
        ColorSchemeEnum.surface.name: UtilsForTheme.colorToHex(s.surface),
        ColorSchemeEnum.onSurface.name: UtilsForTheme.colorToHex(s.onSurface),
        ColorSchemeEnum.surfaceTint.name:
            UtilsForTheme.colorToHex(s.surfaceTint),
        ColorSchemeEnum.outline.name: UtilsForTheme.colorToHex(s.outline),
        ColorSchemeEnum.onSurfaceVariant.name:
            UtilsForTheme.colorToHex(s.onSurfaceVariant),
        ColorSchemeEnum.inverseSurface.name:
            UtilsForTheme.colorToHex(s.inverseSurface),
        ColorSchemeEnum.inversePrimary.name:
            UtilsForTheme.colorToHex(s.inversePrimary),
      };

  static ColorScheme? _mapToScheme(Map<String, dynamic>? m) {
    if (m == null) {
      return null;
    }
    final String bStr = '${m[ColorSchemeEnum.brightness.name]}';
    final Brightness b = (bStr == 'dark') ? Brightness.dark : Brightness.light;

    Color c(String k) =>
        UtilsForTheme.parseColorCanonical(m[k], path: 'overrides.$k');

    return ColorScheme(
      brightness: b,
      primary: c(ColorSchemeEnum.primary.name),
      onPrimary: c(ColorSchemeEnum.onPrimary.name),
      secondary: c(ColorSchemeEnum.secondary.name),
      onSecondary: c(ColorSchemeEnum.onSecondary.name),
      tertiary: c(ColorSchemeEnum.tertiary.name),
      onTertiary: c(ColorSchemeEnum.onTertiary.name),
      error: c(ColorSchemeEnum.error.name),
      onError: c(ColorSchemeEnum.onError.name),
      surface: c(ColorSchemeEnum.surface.name),
      onSurface: c(ColorSchemeEnum.onSurface.name),
      surfaceTint: c(ColorSchemeEnum.surfaceTint.name),
      outline: c(ColorSchemeEnum.outline.name),
      onSurfaceVariant: c(ColorSchemeEnum.onSurfaceVariant.name),
      inverseSurface: c(ColorSchemeEnum.inverseSurface.name),
      inversePrimary: c(ColorSchemeEnum.inversePrimary.name),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is ThemeOverrides) {
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
