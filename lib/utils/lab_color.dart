part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
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
  const LabColor(this.lightness, this.a, this.b);

  final double lightness; // 0..100
  final double a; // ~ -128..127
  final double b; // ~ -128..127

  LabColor withLightness(double lightness) => LabColor(lightness, a, b);

  // --- Helpers numéricos ---
  static double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  static int _clamp8(double v) {
    final int n = v.round();
    if (n < 0) {
      return 0;
    }
    if (n > 255) {
      return 255;
    }
    return n;
  }

  static int convertTo255Value(double value) {
    return (value * 255).round() & 0xff;
  }

  /// Convierte un [Color] ARGB de Flutter a Lab.
  /// Usa los canales nativos `red/green/blue` (0..255) para evitar doble redondeo.
  static List<double> colorToLab(Color color) {
    final List<double> xyz = rgbToXyz(
      convertTo255Value(color.r),
      convertTo255Value(color.g),
      convertTo255Value(color.b),
    );
    return xyzToLab(xyz[0], xyz[1], xyz[2]);
  }

  /// sRGB (0..255) → XYZ (D65; 0..100)
  static List<double> rgbToXyz(int r, int g, int b) {
    // Normaliza a 0..1
    final double R = r / 255.0;
    final double G = g / 255.0;
    final double B = b / 255.0;

    // Corrección gamma (sRGB companding)
    double lin(double u) =>
        (u <= 0.04045) ? (u / 12.92) : pow((u + 0.055) / 1.055, 2.4).toDouble();

    final double rLin = lin(R);
    final double gLin = lin(G);
    final double bLin = lin(B);

    // Matriz sRGB→XYZ (D65)
    final double x =
        (0.4124564 * rLin + 0.3575761 * gLin + 0.1804375 * bLin) * 100.0;
    final double y =
        (0.2126729 * rLin + 0.7151522 * gLin + 0.0721750 * bLin) * 100.0;
    final double z =
        (0.0193339 * rLin + 0.1191920 * gLin + 0.9503041 * bLin) * 100.0;

    return <double>[x, y, z];
  }

  /// XYZ (D65; 0..100) → Lab
  static List<double> xyzToLab(double x, double y, double z) {
    // Blanco de referencia D65
    const double Xn = 95.047;
    const double Yn = 100.000;
    const double Zn = 108.883;

    double f(double t) => (t > 0.008856)
        ? pow(t, 1.0 / 3.0).toDouble()
        : ((903.3 * t + 16.0) / 116.0);

    final double fx = f(x / Xn);
    final double fy = f(y / Yn);
    final double fz = f(z / Zn);

    final double L = _clamp(116.0 * fy - 16.0, 0.0, 100.0);
    final double a = _clamp(500.0 * (fx - fy), -128.0, 127.0);
    final double b = _clamp(200.0 * (fy - fz), -128.0, 127.0);

    return <double>[L, a, b];
  }

  /// Lab → sRGB (0..255)
  static List<int> labToColor(double l, double a, double b1) {
    // Inversa de xyzToLab
    const double Xn = 95.047;
    const double Yn = 100.000;
    const double Zn = 108.883;

    final double fy = (l + 16.0) / 116.0;
    final double fx = a / 500.0 + fy;
    final double fz = fy - (b1 / 200.0);

    double inv(double t) =>
        (t * t * t > 0.008856) ? (t * t * t) : ((t - 16.0 / 116.0) / 7.787);

    final double xr = inv(fx);
    final double yr =
        (l > 8.0) ? pow((l + 16.0) / 116.0, 3.0).toDouble() : (l / 903.3);
    final double zr = inv(fz);

    final double X = xr * Xn;
    final double Y = yr * Yn;
    final double Z = zr * Zn;

    // XYZ → sRGB lineal
    final double rLin = 3.2404542 * (X / 100.0) +
        (-1.5371385) * (Y / 100.0) +
        (-0.4985314) * (Z / 100.0);
    final double gLin = -0.9692660 * (X / 100.0) +
        1.8760108 * (Y / 100.0) +
        0.0415560 * (Z / 100.0);
    final double bLin = 0.0556434 * (X / 100.0) +
        (-0.2040259) * (Y / 100.0) +
        1.0572252 * (Z / 100.0);

    double compand(double u) => (u <= 0.0031308)
        ? (12.92 * u)
        : (1.055 * pow(u, 1.0 / 2.4).toDouble() - 0.055);

    final int r = _clamp8(compand(rLin) * 255.0);
    final int g = _clamp8(compand(gLin) * 255.0);
    final int b = _clamp8(compand(bLin) * 255.0);

    return <int>[r, g, b];
  }

  static int colorValue(int r, int g, int b) {
    assert(r >= 0 && r <= 255);
    assert(g >= 0 && g <= 255);
    assert(b >= 0 && b <= 255);
    return (255 << 24) | (r << 16) | (g << 8) | b;
  }

  static int colorValueFromColor(Color color) {
    return colorValue(
      convertTo255Value(color.r),
      convertTo255Value(color.g),
      convertTo255Value(color.b),
    );
  }
}
