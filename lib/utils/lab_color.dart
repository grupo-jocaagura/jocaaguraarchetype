import 'dart:math';
import 'dart:ui';

import 'package:jocaagura_domain/jocaagura_domain.dart';

/// A utility class for working with the CIE-Lab color space.
///
/// The `LabColor` class provides methods to convert colors between different
/// color spaces, including RGB, XYZ, and Lab. It allows precise manipulation
/// of colors for advanced applications like color grading, image processing,
/// and color difference calculations.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/lab_color.dart';
///
/// void main() {
///   // Create a LabColor instance
///   const labColor = LabColor(53.0, 80.0, 67.0);
///
///   // Modify the lightness of the color
///   final newColor = labColor.withLightness(70.0);
///   print('New LabColor: L=${newColor.lightness}, a=${newColor.a}, b=${newColor.b}');
///
///   // Convert an RGB color to Lab
///   final labValues = LabColor.colorToLab(Color.fromARGB(255, 255, 0, 0));
///   print('Lab Values: L=${labValues[0]}, a=${labValues[1]}, b=${labValues[2]}');
/// }
/// ```
class LabColor extends EntityUtil {
  /// Creates a LabColor instance with the given [lightness], [a], and [b] values.
  ///
  /// The `lightness` value represents the brightness of the color,
  /// while `a` and `b` represent the chromaticity.
  const LabColor(this.lightness, this.a, this.b);

  /// The lightness component of the Lab color.
  final double lightness;

  /// The `a` chromatic component of the Lab color.
  final double a;

  /// The `b` chromatic component of the Lab color.
  final double b;

  /// Returns a new `LabColor` instance with the updated [lightness].
  ///
  /// ## Example
  ///
  /// ```dart
  /// const labColor = LabColor(53.0, 80.0, 67.0);
  /// final newColor = labColor.withLightness(70.0);
  /// print('New Lightness: ${newColor.lightness}'); // Output: New Lightness: 70.0
  /// ```
  LabColor withLightness(double lightness) {
    return LabColor(lightness, a, b);
  }

  /// Converts a [Color] to its Lab color representation.
  ///
  /// This method internally converts the RGB values to the XYZ color space,
  /// and then to the Lab color space.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final labValues = LabColor.colorToLab(Color.fromARGB(255, 255, 0, 0));
  /// print('Lab Values: L=${labValues[0]}, a=${labValues[1]}, b=${labValues[2]}');
  /// ```
  static List<double> colorToLab(Color color) {
    final List<double> xyz = rgbToXyz(
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    );
    return xyzToLab(xyz[0], xyz[1], xyz[2]);
  }

  /// Converts RGB values to the XYZ color space.
  ///
  /// Each color channel ([r], [g], and [b]) must be provided as an integer
  /// between 0 and 255. The resulting XYZ values are returned as a list.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final xyz = LabColor.rgbToXyz(255, 0, 0);
  /// print('XYZ Values: X=${xyz[0]}, Y=${xyz[1]}, Z=${xyz[2]}');
  /// ```
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

  /// Converts XYZ values to the Lab color space.
  ///
  /// The inputs [x], [y], and [z] should be normalized XYZ values.
  /// Returns the Lab values as a list `[L, a, b]`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final lab = LabColor.xyzToLab(41.24, 21.26, 1.93);
  /// print('Lab Values: L=${lab[0]}, a=${lab[1]}, b=${lab[2]}');
  /// ```
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

  /// Converts Lab values back to RGB.
  ///
  /// The inputs [l], [a], and [b1] represent the Lab values. Returns the RGB
  /// values as a list `[R, G, B]`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final rgb = LabColor.labToColor(53.0, 80.0, 67.0);
  /// print('RGB Values: R=${rgb[0]}, G=${rgb[1]}, B=${rgb[2]}');
  /// ```
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
