part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class UtilsForTheme {
  const UtilsForTheme();

// Returns canonical HEX string as #AARRGGBB (uppercase)
  static String colorToHex(Color c) {
    final String v =
        c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$v';
  }

  static Color parseHexColorStrict(String s, {required String path}) {
    final String v = s.trim();
    if (!v.startsWith('#')) {
      throw FormatException('Invalid hex color (missing #) at $path: "$s"');
    }
    final String hex = v.substring(1);
    if (hex.length == 6) {
      // RRGGBB -> assume FF alpha
      final int rgb = int.parse(hex, radix: 16);
      return Color(0xFF000000 | rgb);
    } else if (hex.length == 8) {
      final int argb = int.parse(hex, radix: 16);
      return Color(argb);
    }
    throw FormatException('Invalid hex color length at $path: "$s"');
  }

  static Color parseColorCanonical(dynamic value, {required String path}) {
    if (value is Color) {
      return value;
    }
    if (value is int) {
      return Color(value);
    }
    if (value is String) {
      return parseHexColorStrict(value, path: path);
    }
    throw FormatException('Invalid color type at $path: ${value.runtimeType}');
  }

  static bool asBoolStrict(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key)) {
      throw FormatException('Missing required boolean "$key"');
    }
    final dynamic v = json[key];
    if (v is bool) {
      return v;
    }
    throw FormatException('Field "$key" must be a bool, got ${v.runtimeType}');
  }

  static double asDoubleStrict(
    Map<String, dynamic> json,
    String key,
    double fallback,
  ) {
    if (!json.containsKey(key)) {
      return fallback;
    }
    final dynamic v = json[key];
    if (v is num && v.isFinite) {
      return v.toDouble();
    }
    throw FormatException('Field "$key" must be a finite number');
  }

  static String asStringOrEmpty(Map<String, dynamic> json, String key) {
    final dynamic v = json[key];
    if (v == null) {
      return '';
    }
    if (v is String) {
      return v;
    }
    throw FormatException('Field "$key" must be a string');
  }

  static Map<String, dynamic> asMapStrict(
    Map<String, dynamic> json,
    String key,
  ) {
    final dynamic v = json[key];
    if (v is Map<String, dynamic>) {
      return v;
    }
    throw FormatException('Field "$key" must be an object');
  }

  static DateTime? asUtcInstant(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key) || json[key] == null) {
      return null;
    }
    final dynamic v = json[key];
    if (v is! String) {
      throw FormatException('Field "$key" must be ISO8601 string');
    }
    return DateTime.parse(v).toUtc();
  }
}
