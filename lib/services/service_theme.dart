import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../utils/lab_color.dart';

class ServiceTheme extends EntityService {
  const ServiceTheme();
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
      Color.fromRGBO(r, g, b, 1).value,
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

  Color getDarker(Color color, {double amount = .1}) {
    assert(amount > 0 && amount < 1);

    final LabColor labColor = convertToLab(color);
    final LabColor darkerLabColor =
        labColor.withLightness(labColor.lightness - amount);
    final Color darkerColor = convertToRgb(darkerLabColor);

    return darkerColor;
  }

  Color getLighter(Color color, {double amount = .1}) {
    assert(amount > 0 && amount < 1);

    final LabColor labColor = convertToLab(color);
    final LabColor lighterLabColor =
        labColor.withLightness(labColor.lightness + amount);
    final Color lighterColor = convertToRgb(lighterLabColor);

    return lighterColor;
  }

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

  Color colorRandom() {
    final Random random = Random();
    final int r = random.nextInt(256);
    final int g = random.nextInt(256);
    final int b = random.nextInt(256);

    return Color.fromRGBO(r, g, b, 1);
  }

  static bool validateHexColor(String colorHex) {
    const String hexColorPattern = r'^#([A-Fa-f0-9]{6})$';
    final RegExp regex = RegExp(hexColorPattern);
    return regex.hasMatch(colorHex);
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
}
