import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../utils/lab_color.dart';

/// A service class for managing theme-related functionalities.
///
/// The `ServiceTheme` class provides utility methods to work with colors,
/// create custom themes, and manipulate color brightness. It includes methods
/// for generating random colors, validating hex color codes, and converting
/// between RGB and Lab color spaces.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/service_theme.dart';
///
/// void main() {
///   final serviceTheme = ServiceTheme();
///
///   // Generate a random color
///   final randomColor = serviceTheme.colorRandom();
///   print('Random Color: $randomColor');
///
///   // Create a MaterialColor from RGB values
///   final materialColor = serviceTheme.materialColorFromRGB(100, 150, 200);
///   print('MaterialColor: ${materialColor.shade500}');
/// }
/// ```
class ServiceTheme extends EntityService {
  /// Creates an instance of `ServiceTheme`.
  const ServiceTheme();

  /// Generates a `MaterialColor` from the provided RGB values.
  ///
  /// The [r], [g], and [b] parameters represent the red, green, and blue
  /// components, respectively, and must be integers between 0 and 255.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final serviceTheme = ServiceTheme();
  /// final materialColor = serviceTheme.materialColorFromRGB(255, 100, 50);
  /// print('MaterialColor: ${materialColor.shade500}');
  /// ```
  MaterialColor materialColorFromRGB(int r, int g, int b) {
    assert(r >= 0 && r <= 255);
    assert(g >= 0 && g <= 255);
    assert(b >= 0 && b <= 255);
    final List<int> colorValues =
        List<int>.generate(10, (int index) => index * 100 + 100);

    int findClosestValue(int value) {
      int closest = colorValues.first;
      int distance = (closest - value).abs();

      for (final int colorValue in colorValues) {
        final int newDistance = (colorValue - value).abs();

        if (newDistance < distance) {
          closest = colorValue;
          distance = newDistance;
        } else {
          break;
        }
      }

      return closest;
    }

    final int closestR = findClosestValue(r);
    final int closestG = findClosestValue(g);
    final int closestB = findClosestValue(b);

    return MaterialColor(
      (255 << 24) | (r << 16) | (g << 8) | b,
      <int, Color>{
        50: Color.fromRGBO(closestR, closestG, closestB, 0.1),
        100: Color.fromRGBO(closestR, closestG, closestB, 0.2),
        200: Color.fromRGBO(closestR, closestG, closestB, 0.3),
        300: Color.fromRGBO(closestR, closestG, closestB, 0.4),
        400: Color.fromRGBO(closestR, closestG, closestB, 0.5),
        500: Color.fromRGBO(closestR, closestG, closestB, 0.6),
        600: Color.fromRGBO(closestR, closestG, closestB, 0.7),
        700: Color.fromRGBO(closestR, closestG, closestB, 0.8),
        800: Color.fromRGBO(closestR, closestG, closestB, 0.9),
        900: Color.fromRGBO(closestR, closestG, closestB, 1.0),
      },
    );
  }

  /// Returns a darker version of the given [color].
  ///
  /// The [amount] parameter specifies how much darker the color should be.
  /// The value of [amount] must be between 0 and 1.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final serviceTheme = ServiceTheme();
  /// final color = Color(0xFF2196F3);
  /// final darkerColor = serviceTheme.getDarker(color, amount: 0.2);
  /// print('Darker Color: $darkerColor');
  /// ```
  Color getDarker(Color color, {double amount = .1}) {
    assert(amount > 0 && amount < 1);

    final LabColor labColor = convertToLab(color);
    final LabColor darkerLabColor =
        labColor.withLightness(labColor.lightness - amount);
    final Color darkerColor = convertToRgb(darkerLabColor);

    return darkerColor;
  }

  /// Returns a lighter version of the given [color].
  ///
  /// The [amount] parameter specifies how much lighter the color should be.
  /// The value of [amount] must be between 0 and 1.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final serviceTheme = ServiceTheme();
  /// final color = Color(0xFF2196F3);
  /// final lighterColor = serviceTheme.getLighter(color, amount: 0.2);
  /// print('Lighter Color: $lighterColor');
  /// ```
  Color getLighter(Color color, {double amount = .1}) {
    assert(amount > 0 && amount < 1);

    final LabColor labColor = convertToLab(color);
    final LabColor lighterLabColor =
        labColor.withLightness(labColor.lightness + amount);
    final Color lighterColor = convertToRgb(lighterLabColor);

    return lighterColor;
  }

  /// Creates a custom `ThemeData` from the given [colorScheme] and [textTheme].
  ///
  /// If [isDark] is `true`, the theme will have a dark brightness.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final serviceTheme = ServiceTheme();
  /// final theme = serviceTheme.customThemeFromColorScheme(
  ///   ColorScheme.light(),
  ///   TextTheme(),
  ///   false,
  /// );
  /// print('Custom Theme: $theme');
  /// ```
  ThemeData customThemeFromColorScheme(
    ColorScheme colorScheme,
    TextTheme textTheme, [
    bool isDark = false,
  ]) {
    if (isDark) {
      return ThemeData(
        brightness: Brightness.dark,
      );
    }
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
    );
  }

  /// Generates a random `Color`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final serviceTheme = ServiceTheme();
  /// final randomColor = serviceTheme.colorRandom();
  /// print('Random Color: $randomColor');
  /// ```
  Color colorRandom() {
    final Random random = Random();
    final int r = random.nextInt(256);
    final int g = random.nextInt(256);
    final int b = random.nextInt(256);

    return Color.fromRGBO(r, g, b, 1);
  }

  /// Validates if the given [colorHex] string is a valid hex color.
  ///
  /// The [colorHex] must start with `#` and be followed by six hexadecimal
  /// digits. Returns `true` if valid, otherwise `false`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isValid = ServiceTheme.validateHexColor('#FF5733');
  /// print('Is valid hex color: $isValid');
  /// ```
  static bool validateHexColor(String colorHex) {
    const String hexColorPattern = r'^#([A-Fa-f0-9]{6})$';
    final RegExp regex = RegExp(hexColorPattern);
    return regex.hasMatch(colorHex);
  }

  /// Converts an RGB `Color` to a `LabColor`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final color = Color(0xFF2196F3);
  /// final labColor = ServiceTheme.convertToLab(color);
  /// print('Lab Color: L=${labColor.lightness}, a=${labColor.a}, b=${labColor.b}');
  /// ```
  static LabColor convertToLab(Color color) {
    final List<double> cielab = LabColor.colorToLab(color);

    return LabColor(cielab[0], cielab[1], cielab[2]);
  }

  /// Converts a `LabColor` to an RGB `Color`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final labColor = LabColor(50.0, 20.0, -30.0);
  /// final color = ServiceTheme.convertToRgb(labColor);
  /// print('RGB Color: $color');
  /// ```
  static Color convertToRgb(LabColor labColor) {
    final List<int> rgb =
        LabColor.labToColor(labColor.lightness, labColor.a, labColor.b);

    return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1);
  }
}
