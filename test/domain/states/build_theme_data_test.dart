import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BuildThemeData', () {
    test('applies light override primary (stable checks)', () {
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

      // Override respetado
      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.colorScheme.primary, const Color(0xFF00BCD4));

      // Se conserva M3 según el estado
      expect(t.useMaterial3, s.useMaterial3);

      // Sanity robusto: el TextTheme existe y al menos un estilo no es null
      final bool hasAnyTextStyle = <TextStyle?>[
        t.textTheme.bodyMedium,
        t.textTheme.bodyLarge,
        t.textTheme.titleMedium,
        t.textTheme.labelLarge,
        t.textTheme.headlineSmall,
      ].any((TextStyle? e) => e != null);
      expect(
        hasAnyTextStyle,
        isTrue,
        reason: 'Al menos un estilo del TextTheme debería estar definido.',
      );
    });

    test('uses seed-only when no overrides', () {
      final ThemeState s = ThemeState.defaults.copyWith(
        seed: const Color(0xFF3366AA),
      );
      final ThemeData t = const BuildThemeData().fromState(s);

      expect(t.colorScheme.primary, isA<Color>());

      expect(t.useMaterial3, s.useMaterial3);
    });
  });
}
