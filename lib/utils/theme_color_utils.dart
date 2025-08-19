part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class ThemeColorUtils {
  const ThemeColorUtils._(); // no instanciable

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

  static Color getDarker(Color color, {double amount = .1}) {
    assert(amount > 0 && amount < 1);
    final LabColor lab = convertToLab(color);
    final LabColor darker = lab.withLightness(lab.lightness - amount);
    return convertToRgb(darker);
  }

  static Color getLighter(Color color, {double amount = .1}) {
    assert(amount > 0 && amount < 1);
    final LabColor lab = convertToLab(color);
    final LabColor lighter = lab.withLightness(lab.lightness + amount);
    return convertToRgb(lighter);
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
}
