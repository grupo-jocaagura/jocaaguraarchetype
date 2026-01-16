part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Color utilities for hex conversion, swatch generation and light/darken.
///
/// Keep helpers pure and deterministic. Do not read from Theme.of(context)
/// here to facilitate reuse in domain/services.
///
/// ### Example
/// ```dart
/// final int hex = ThemeColorUtils.toHex(Colors.indigo);
/// final Color lighter = ThemeColorUtils.lighten(Colors.indigo, 0.08);
/// ```
class ThemeColorUtils {
  const ThemeColorUtils();

  static bool validateHexColor(String colorHex) {
    const String pattern = r'^#([A-Fa-f0-9]{6})$';
    return RegExp(pattern).hasMatch(colorHex);
  }

  static LabColor convertToLab(Color color) {
    final List<double> cielab = LabColor.colorToLab(color);
    return LabColor(cielab[0], cielab[1], cielab[2]);
  }

  static Color convertToRgb(LabColor labColor) {
    final List<int> rgb =
        LabColor.labToColor(labColor.lightness, labColor.a, labColor.b);
    return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1);
  }

  static Color getDarker(Color c, {double amount = .10}) {
    assert(amount > 0 && amount < 1);
    final List<double> lab = LabColor.colorToLab(c);
    final double L = (lab[0] - 100.0 * amount).clamp(0.0, 100.0);
    final List<int> rgb = LabColor.labToColor(L, lab[1], lab[2]);
    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }

  static Color getLighter(Color c, {double amount = .10}) {
    assert(amount > 0 && amount < 1);
    final List<double> lab = LabColor.colorToLab(c);
    final double L = (lab[0] + 100.0 * amount).clamp(0.0, 100.0);
    final List<int> rgb = LabColor.labToColor(L, lab[1], lab[2]);
    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }

  static MaterialColor materialColorFromRGB(int r, int g, int b) {
    assert(r >= 0 && r <= 255);
    assert(g >= 0 && g <= 255);
    assert(b >= 0 && b <= 255);

    final Color base = Color.fromRGBO(r, g, b, 1);
    final Map<int, Color> shades = <int, Color>{
      50: getLighter(base, amount: .45),
      100: getLighter(base, amount: .40),
      200: getLighter(base, amount: .30),
      300: getLighter(base, amount: .20),
      400: getLighter(base),
      500: base,
      600: getDarker(base),
      700: getDarker(base, amount: .20),
      800: getDarker(base, amount: .30),
      900: getDarker(base, amount: .40),
    };
    return MaterialColor(base.toARGB32(), shades);
  }

  static String toHex(
    Color c, {
    bool leadingHashSign = true,
    bool includeAlpha = true,
  }) {
    final int a = Utils.getIntegerFromDynamic(c.a * 255);
    final int r = Utils.getIntegerFromDynamic(c.r * 255);
    final int g = Utils.getIntegerFromDynamic(c.g * 255);
    final int b = Utils.getIntegerFromDynamic(c.b * 255);

    String two(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();

    final String hex = includeAlpha
        ? '${two(a)}${two(r)}${two(g)}${two(b)}'
        : '${two(r)}${two(g)}${two(b)}';

    return leadingHashSign ? '#$hex' : hex;
  }

  static Color? tryParseColor(String input) {
    final String raw = input.trim();

    // Acepta: #RRGGBB, #AARRGGBB, RRGGBB, AARRGGBB
    final String hex = raw.startsWith('#') ? raw.substring(1) : raw;

    if (hex.length != 6 && hex.length != 8) {
      return null;
    }
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return null;
    }

    // Si es 6 → asumimos FF alpha
    if (hex.length == 6) {
      return Color(0xFF000000 | value);
    }
    return Color(value);
  }
}
