import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('ServiceTheme', () {
    test('materialColorFromRGB should return a valid MaterialColor', () {
      final MaterialColor materialColor =
          const ServiceTheme().materialColorFromRGB(255, 0, 0);

      expect(materialColor, isA<MaterialColor>());
      expect(LabColor.colorValueFromColor(materialColor), 4294901760);
    });

    test('getDarker should return a darker color', () {
      const MaterialColor color = Colors.blue;
      final Color darkerColor =
          const ServiceTheme().getDarker(color, amount: 0.2);

      expect(darkerColor, isA<Color>());
      expect(darkerColor, isNot(equals(color)));
      expect(
        darkerColor.computeLuminance(),
        lessThan(color.computeLuminance()),
      );
    });

    test('getLighter should return a lighter color', () {
      const MaterialColor color = Colors.blue;
      final Color lighterColor =
          const ServiceTheme().getLighter(color, amount: 0.2);

      expect(lighterColor, isA<Color>());
      expect(lighterColor, isNot(equals(color)));
      expect(
        lighterColor.computeLuminance(),
        greaterThan(color.computeLuminance()),
      );
    });

    test('customThemeFromColorScheme should return a valid ThemeData', () {
      const ColorScheme colorScheme = ColorScheme.light();
      const TextTheme textTheme = TextTheme();
      final ThemeData themeData =
          const ServiceTheme().customThemeFromColorScheme(
        colorScheme,
        textTheme,
      );

      expect(themeData, isA<ThemeData>());
      expect(themeData.colorScheme, equals(colorScheme));
      expect(
        themeData.textTheme.displayLarge?.color != null,
        true,
      );
      expect(themeData.brightness, equals(Brightness.light));
    });

    test('colorRandom should return a random color', () {
      final Color randomColor = const ServiceTheme().colorRandom();

      expect(randomColor, isA<Color>());
    });

    test('validateHexColor should return true for a valid hex color', () {
      const String validColor = '#FF0011';
      final bool isValid = ServiceTheme.validateHexColor(validColor);

      expect(isValid, equals(true));
    });

    test('validateHexColor should return false for an invalid hex color', () {
      const String invalidColor = '#FFF';
      final bool isValid = ServiceTheme.validateHexColor(invalidColor);

      expect(isValid, equals(false));
    });
  });
}
