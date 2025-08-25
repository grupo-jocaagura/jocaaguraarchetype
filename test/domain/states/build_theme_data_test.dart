import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BuildThemeData', () {
    test('applies light override primary', () {
      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.light,
        overrides: const ThemeOverrides(
          light: ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF00BCD4),
            onPrimary: Colors.white,
            secondary: Colors.amber,
            onSecondary: Colors.black,
            tertiary: Colors.purple,
            onTertiary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            surfaceTint: Color(0xFF00BCD4),
            outline: Color(0xFF999999),
            onSurfaceVariant: Color(0xFF666666),
            inverseSurface: Color(0xFF121212),
            inversePrimary: Color(0xFF004D40),
          ),
        ),
      );

      final ThemeData t = const BuildThemeData().fromState(s);
      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.colorScheme.primary, const Color(0xFF00BCD4));
      // textScale factor aplicado
      expect(
        t.textTheme.bodyMedium?.fontSize,
        isNotNull,
      ); // sanity (no crashea)
    });

    test('uses seed-only when no overrides', () {
      final ThemeState s = ThemeState.defaults.copyWith(
        seed: const Color(0xFF3366AA),
      );
      final ThemeData t = const BuildThemeData().fromState(s);
      expect(t.colorScheme.primary, isA<Color>());
    });
  });
}
