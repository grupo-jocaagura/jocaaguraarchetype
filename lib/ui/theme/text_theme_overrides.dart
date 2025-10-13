part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Holds per-scheme typography overrides (light/dark) for `TextTheme`,
/// serialized as JSON maps of `TextStyle` fields.
///
/// Scope:
/// - Serializes a curated subset of `TextStyle`: `fontFamily`, `fontSize`,
///   `fontWeight` (numeric), `letterSpacing`, and `height`.
/// - Does NOT serialize `color` (colors belong to `ColorScheme`).
/// - `light` and/or `dark` can be `null`.
///
/// Equality & hashing:
/// - Structural equality based on every included `TextStyle` field.
///
/// Example:
/// ```dart
/// void main() {
///   final TextThemeOverrides ov = TextThemeOverrides(
///     light: const TextTheme(
///       bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
///     ),
///     dark: const TextTheme(
///       bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
///     ),
///   );
///   final Map<String, dynamic> json = ov.toJson();
///   final TextThemeOverrides r = TextThemeOverrides.fromJson(json)!;
///   assert(ov == r);
/// }
/// ```
@immutable
class TextThemeOverrides {
  const TextThemeOverrides({
    this.light,
    this.dark,
    this.fontName = '',
  });

  final TextTheme? light;
  final TextTheme? dark;
  final String fontName;

  /// Returns a new instance overriding provided fields.
  /// Use the `clear*` flags to explicitly set nullable fields to null.
  TextThemeOverrides copyWith({
    TextTheme? light,
    bool clearLight = false,
    TextTheme? dark,
    bool clearDark = false,
    String? fontName,
    bool clearFontName = false,
  }) {
    return TextThemeOverrides(
      light: clearLight ? null : (light ?? this.light),
      dark: clearDark ? null : (dark ?? this.dark),
      fontName: fontName ?? this.fontName,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'light': light == null ? null : _textThemeToMap(light!),
        'dark': dark == null ? null : _textThemeToMap(dark!),
        'fontName': fontName,
      };

  static TextThemeOverrides? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return TextThemeOverrides(
      light: _mapToTextTheme(json['light'] as Map<String, dynamic>?),
      dark: _mapToTextTheme(json['dark'] as Map<String, dynamic>?),
      fontName: Utils.getStringFromDynamic(json['fontName']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextThemeOverrides &&
          runtimeType == other.runtimeType &&
          _textThemeEquals(light, other.light) &&
          _textThemeEquals(dark, other.dark) &&
          fontName == other.fontName;

  @override
  int get hashCode {
    final int hLight = _textThemeHash(light);
    final int hDark = _textThemeHash(dark);
    final int hFont = fontName.hashCode;
    return 0x1fffffff & (hLight ^ (hDark * 31) ^ (hFont * 131));
  }

  // -------------------- Helpers (TextTheme <-> Map) --------------------

  static Map<String, dynamic> _textThemeToMap(TextTheme t) => <String, dynamic>{
        'displayLarge': _textStyleToMap(t.displayLarge),
        'displayMedium': _textStyleToMap(t.displayMedium),
        'displaySmall': _textStyleToMap(t.displaySmall),
        'headlineLarge': _textStyleToMap(t.headlineLarge),
        'headlineMedium': _textStyleToMap(t.headlineMedium),
        'headlineSmall': _textStyleToMap(t.headlineSmall),
        'titleLarge': _textStyleToMap(t.titleLarge),
        'titleMedium': _textStyleToMap(t.titleMedium),
        'titleSmall': _textStyleToMap(t.titleSmall),
        'bodyLarge': _textStyleToMap(t.bodyLarge),
        'bodyMedium': _textStyleToMap(t.bodyMedium),
        'bodySmall': _textStyleToMap(t.bodySmall),
        'labelLarge': _textStyleToMap(t.labelLarge),
        'labelMedium': _textStyleToMap(t.labelMedium),
        'labelSmall': _textStyleToMap(t.labelSmall),
      };

  /// Preserve null: if input map is null, return null.
  static TextTheme? _mapToTextTheme(Map<String, dynamic>? m) {
    if (m == null) {
      return null;
    }
    TextStyle? ts(String k) => _mapToTextStyle(m[k] as Map<String, dynamic>?);
    return TextTheme(
      displayLarge: ts('displayLarge'),
      displayMedium: ts('displayMedium'),
      displaySmall: ts('displaySmall'),
      headlineLarge: ts('headlineLarge'),
      headlineMedium: ts('headlineMedium'),
      headlineSmall: ts('headlineSmall'),
      titleLarge: ts('titleLarge'),
      titleMedium: ts('titleMedium'),
      titleSmall: ts('titleSmall'),
      bodyLarge: ts('bodyLarge'),
      bodyMedium: ts('bodyMedium'),
      bodySmall: ts('bodySmall'),
      labelLarge: ts('labelLarge'),
      labelMedium: ts('labelMedium'),
      labelSmall: ts('labelSmall'),
    );
  }

  static Map<String, dynamic>? _textStyleToMap(TextStyle? s) {
    if (s == null) {
      return null;
    }
    return <String, dynamic>{
      'fontFamily': s.fontFamily,
      'fontSize': s.fontSize,
      'fontWeight': s.fontWeight?.value, // numeric weight (100..900)
      'letterSpacing': s.letterSpacing,
      'height': s.height,
    };
  }

  static TextStyle? _mapToTextStyle(Map<String, dynamic>? m) {
    if (m == null) {
      return null;
    }
    final String? family = m['fontFamily'] as String?;
    final double? size = (m['fontSize'] as num?)?.toDouble();
    final int? w = m['fontWeight'] as int?;
    final double? letter = (m['letterSpacing'] as num?)?.toDouble();
    final double? h = (m['height'] as num?)?.toDouble();
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight:
          w == null ? null : FontWeight.values[((w ~/ 100) - 1).clamp(0, 8)],
      letterSpacing: letter,
      height: h,
    );
  }

  // -------------------- Equality / Hash helpers --------------------

  static bool _textThemeEquals(TextTheme? a, TextTheme? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    bool eq(TextStyle? x, TextStyle? y) => _textStyleEquals(x, y);
    return eq(a.displayLarge, b.displayLarge) &&
        eq(a.displayMedium, b.displayMedium) &&
        eq(a.displaySmall, b.displaySmall) &&
        eq(a.headlineLarge, b.headlineLarge) &&
        eq(a.headlineMedium, b.headlineMedium) &&
        eq(a.headlineSmall, b.headlineSmall) &&
        eq(a.titleLarge, b.titleLarge) &&
        eq(a.titleMedium, b.titleMedium) &&
        eq(a.titleSmall, b.titleSmall) &&
        eq(a.bodyLarge, b.bodyLarge) &&
        eq(a.bodyMedium, b.bodyMedium) &&
        eq(a.bodySmall, b.bodySmall) &&
        eq(a.labelLarge, b.labelLarge) &&
        eq(a.labelMedium, b.labelMedium) &&
        eq(a.labelSmall, b.labelSmall);
  }

  static bool _textStyleEquals(TextStyle? a, TextStyle? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    return a.fontFamily == b.fontFamily &&
        a.fontSize == b.fontSize &&
        a.fontWeight == b.fontWeight &&
        a.letterSpacing == b.letterSpacing &&
        a.height == b.height;
  }

  static int _textThemeHash(TextTheme? t) {
    if (t == null) {
      return 0;
    }
    int h = 0;
    int mix(int acc, TextStyle? s) =>
        0x1fffffff & (acc * 31 ^ _textStyleHash(s));
    h = mix(h, t.displayLarge);
    h = mix(h, t.displayMedium);
    h = mix(h, t.displaySmall);
    h = mix(h, t.headlineLarge);
    h = mix(h, t.headlineMedium);
    h = mix(h, t.headlineSmall);
    h = mix(h, t.titleLarge);
    h = mix(h, t.titleMedium);
    h = mix(h, t.titleSmall);
    h = mix(h, t.bodyLarge);
    h = mix(h, t.bodyMedium);
    h = mix(h, t.bodySmall);
    h = mix(h, t.labelLarge);
    h = mix(h, t.labelMedium);
    h = mix(h, t.labelSmall);
    return h;
  }

  static int _textStyleHash(TextStyle? s) {
    if (s == null) {
      return 0;
    }
    int h = s.fontFamily?.hashCode ?? 0;
    h = 0x1fffffff & (h * 31 ^ (s.fontSize?.hashCode ?? 0));
    h = 0x1fffffff & (h * 31 ^ (s.fontWeight?.hashCode ?? 0));
    h = 0x1fffffff & (h * 31 ^ (s.letterSpacing?.hashCode ?? 0));
    h = 0x1fffffff & (h * 31 ^ (s.height?.hashCode ?? 0));
    return h;
  }
}
