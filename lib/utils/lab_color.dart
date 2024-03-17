import 'dart:math';
import 'dart:ui';

import 'package:jocaagura_domain/jocaagura_domain.dart';

class LabColor extends EntityUtil {
  const LabColor(this.lightness, this.a, this.b);
  final double lightness;
  final double a;
  final double b;

  LabColor withLightness(double lightness) {
    return LabColor(lightness, a, b);
  }

  static List<double> colorToLab(Color color) {
    final List<double> xyz = rgbToXyz(color.red, color.green, color.blue);
    return xyzToLab(xyz[0], xyz[1], xyz[2]);
  }

  static List<double> rgbToXyz(int r, int g, int b) {
    final double normalizedR = r / 255;
    final double normalizedG = g / 255;
    final double normalizedB = b / 255;

    final double rLinear = normalizedR > 0.04045
        ? pow((normalizedR + 0.055) / 1.055, 2.4).toDouble()
        : normalizedR / 12.92;
    final double gLinear = normalizedG > 0.04045
        ? pow((normalizedG + 0.055) / 1.055, 2.4).toDouble()
        : normalizedG / 12.92;
    final double bLinear = normalizedB > 0.04045
        ? pow((normalizedB + 0.055) / 1.055, 2.4).toDouble()
        : normalizedB / 12.92;

    final double x =
        rLinear * 0.4124564 + gLinear * 0.3575761 + bLinear * 0.1804375;
    final double y =
        rLinear * 0.2126729 + gLinear * 0.7151522 + bLinear * 0.0721750;
    final double z =
        rLinear * 0.0193339 + gLinear * 0.1191920 + bLinear * 0.9503041;

    return <double>[x * 100, y * 100, z * 100];
  }

  static List<double> xyzToLab(double x, double y, double z) {
    final double xNormalized = x / 95.047;
    final double yNormalized = y / 100.000;
    final double zNormalized = z / 108.883;

    final double x3 = xNormalized > 0.008856
        ? pow(xNormalized, 1 / 3).toDouble()
        : (903.3 * xNormalized + 16) / 116;
    final double y3 = yNormalized > 0.008856
        ? pow(yNormalized, 1 / 3).toDouble()
        : (903.3 * yNormalized + 16) / 116;
    final double z3 = zNormalized > 0.008856
        ? pow(zNormalized, 1 / 3).toDouble()
        : (903.3 * zNormalized + 16) / 116;

    final double l = max(0, (116 * y3) - 16);
    final double a = max(-128, min(127, 500 * (x3 - y3)));
    final double b = max(-128, min(127, 200 * (y3 - z3)));

    return <double>[l, a, b];
  }

  static List<int> labToColor(double l, double a, double b1) {
    final double y3 = (l + 16) / 116;
    final double x3 = a / 500 + y3;
    final double z3 = y3 - (b1 / 200);

    final double xNormalized =
        x3 * x3 * x3 > 0.008856 ? x3 * x3 * x3 : (x3 - 16 / 116) / 7.787;
    final double yNormalized =
        l > 8 ? pow((l + 16) / 116, 3).toDouble() : l / 903.3;
    final double zNormalized =
        z3 * z3 * z3 > 0.008856 ? z3 * z3 * z3 : (z3 - 16 / 116) / 7.787;

    final double x = xNormalized * 95.047;
    final double y = yNormalized * 100.000;
    final double z = zNormalized * 108.883;

    final double rLinear = x * 0.032406 + y * -0.015372 + z * -0.004986;
    final double gLinear = x * -0.009689 + y * 0.018758 + z * 0.000415;
    final double bLinear = x * 0.000557 + y * -0.002040 + z * 0.010570;

    final int r = rLinear <= 0.0031308
        ? (12.92 * rLinear * 255).round()
        : ((1.055 * pow(rLinear, 1 / 2.4) - 0.055) * 255).round();
    final int g = gLinear <= 0.0031308
        ? (12.92 * gLinear * 255).round()
        : ((1.055 * pow(gLinear, 1 / 2.4) - 0.055) * 255).round();
    final int b = bLinear <= 0.0031308
        ? (12.92 * bLinear * 255).round()
        : ((1.055 * pow(bLinear, 1 / 2.4).toDouble() - 0.055) * 255).round();

    return <int>[r, g, b];
  }
}
