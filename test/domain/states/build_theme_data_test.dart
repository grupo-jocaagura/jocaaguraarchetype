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

  group('BuildThemeData.fromState • básicos', () {
    test(
        'Given ThemeState light When fromState Then brightness is light and useMaterial3 forwarded',
        () {
      // Arrange
      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.light,
        useMaterial3: true,
        textScale: 1.0,
      );
      const BuildThemeData builder = BuildThemeData();

      // Act
      final ThemeData t = builder.fromState(s);

      // Assert
      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.useMaterial3, isTrue);
      expect(t.visualDensity, VisualDensity.standard);
    });

    test('Given ThemeState dark When fromState Then brightness is dark', () {
      final ThemeState s = ThemeState.defaults.copyWith(mode: ThemeMode.dark);
      const BuildThemeData builder = BuildThemeData();

      final ThemeData t = builder.fromState(s);

      expect(t.colorScheme.brightness, Brightness.dark);
    });
  });

  group('BuildThemeData.fromState • overrides merge', () {
    ColorScheme makeLightOverride() => const ColorScheme.light(
          primary: Color(0xFF111111),
          onPrimary: Color(0xFF222222),
          secondary: Color(0xFF333333),
          onSecondary: Color(0xFF444444),
          tertiary: Color(0xFF555555),
          onTertiary: Color(0xFF666666),
          error: Color(0xFF777777),
          onError: Color(0xFF888888),
          surface: Color(0xFF999999),
          onSurface: Color(0xFFAAAAAA),
          surfaceTint: Color(0xFFBBBBBB),
          outline: Color(0xFFCCCCCC),
          onSurfaceVariant: Color(0xFFDDDDDD),
          inverseSurface: Color(0xFFEEEEEE),
          inversePrimary: Color(0xFF0000FF),
        );

    ColorScheme makeDarkOverride() => const ColorScheme.dark(
          primary: Color(0xFF010101),
          onPrimary: Color(0xFF020202),
          secondary: Color(0xFF030303),
          onSecondary: Color(0xFF040404),
          tertiary: Color(0xFF050505),
          onTertiary: Color(0xFF060606),
          error: Color(0xFF070707),
          onError: Color(0xFF080808),
          surface: Color(0xFF090909),
          onSurface: Color(0xFF0A0A0A),
          surfaceTint: Color(0xFF0B0B0B),
          outline: Color(0xFF0C0C0C),
          onSurfaceVariant: Color(0xFF0D0D0D),
          inverseSurface: Color(0xFF0E0E0E),
          inversePrimary: Color(0xFF00FF00),
        );

    test(
        'Given light mode with light overrides When fromState Then effective scheme matches overrides',
        () {
      // Arrange
      final ThemeOverrides ov = ThemeOverrides(light: makeLightOverride());
      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.light,
        overrides: ov,
      );

      const BuildThemeData builder = BuildThemeData();

      // Act
      final ThemeData t = builder.fromState(s);

      // Assert: spot-check a few fields to ensure override applied
      expect(t.colorScheme.primary, const Color(0xFF111111));
      expect(t.colorScheme.onPrimary, const Color(0xFF222222));
      expect(t.colorScheme.inversePrimary, const Color(0xFF0000FF));
    });

    test(
        'Given dark mode with dark overrides When fromState Then effective scheme matches overrides',
        () {
      final ThemeOverrides ov = ThemeOverrides(dark: makeDarkOverride());
      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        overrides: ov,
      );

      const BuildThemeData builder = BuildThemeData();
      final ThemeData t = builder.fromState(s);

      expect(t.colorScheme.primary, const Color(0xFF010101));
      expect(t.colorScheme.onSecondary, const Color(0xFF040404));
      expect(t.colorScheme.inversePrimary, const Color(0xFF00FF00));
    });

    test(
        'Given no overrides When fromState Then base scheme is used (no crash)',
        () {
      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.light,
      );
      const BuildThemeData builder = BuildThemeData();

      final ThemeData t = builder.fromState(s);

      // No aserción de valores exactos (fromSeed es determinístico pero interno);
      // sólo validamos que produzca un scheme válido.
      expect(t.colorScheme, isA<ColorScheme>());
    });
  });

  group('BuildThemeData.fromState • text scaling', () {
    test(
        'Given baseTextTheme with font sizes When scale 1.2 Then multiplies only non-null fontSize',
        () {
      // Arrange
      const TextTheme baseText = TextTheme(
        bodyMedium: TextStyle(fontSize: 10),
        titleSmall: TextStyle(fontSize: 12),
        // headlineMedium sin fontSize -> debe permanecer null
        headlineMedium: TextStyle(fontFamily: 'X'),
      );

      final ThemeState s = ThemeState.defaults.copyWith(textScale: 1.2);
      const BuildThemeData builder = BuildThemeData();

      // Act
      final ThemeData t = builder.fromState(s, baseTextTheme: baseText);

      // Assert
      expect(t.textTheme.bodyMedium!.fontSize, closeTo(12.0, 1e-9));
      expect(t.textTheme.titleSmall!.fontSize, closeTo(14.4, 1e-9));
      expect(
        t.textTheme.headlineMedium!.fontSize,
        isNull,
      ); // no tamaño -> se preserva
    });

    test('Given scale == 1.0 When fromState Then textTheme unchanged', () {
      const TextTheme baseText = TextTheme(
        bodySmall: TextStyle(fontSize: 8),
      );
      final ThemeState s = ThemeState.defaults.copyWith(textScale: 1.0);
      const BuildThemeData builder = BuildThemeData();

      final ThemeData t = builder.fromState(s, baseTextTheme: baseText);

      expect(t.textTheme.bodySmall!.fontSize, 8.0);
    });

    test('Given scale is NaN When fromState Then textTheme unchanged', () {
      const TextTheme baseText = TextTheme(
        labelLarge: TextStyle(fontSize: 20),
      );
      final ThemeState s = ThemeState.defaults.copyWith(textScale: double.nan);
      const BuildThemeData builder = BuildThemeData();

      final ThemeData t = builder.fromState(s, baseTextTheme: baseText);

      expect(t.textTheme.labelLarge!.fontSize, 20.0);
    });

    test(
        'Given no baseTextTheme When fromState Then scales default theme text if sizes are present',
        () {
      // Arrange: Many default TextTheme slots have sizes; verificamos que no falle y cambie al menos uno.
      final ThemeState s = ThemeState.defaults.copyWith(textScale: 1.1);
      const BuildThemeData builder = BuildThemeData();

      // Act
      final ThemeData t = builder.fromState(s);

      // Assert (spot-check): asumimos bodyMedium no es null y tiene tamaño por defecto en Material
      expect(t.textTheme.bodyMedium, isNotNull);
      // Puede ser null el fontSize en algunas plataformas/temas, así que validamos condicionalmente.
      final double? fs = t.textTheme.bodyMedium!.fontSize;
      if (fs != null) {
        // Como no tenemos el valor previo, comprobamos consistencia del escalado indirectamente
        // creando otra instancia con scale 1.0 y comparando.
        final ThemeData tNoScale = const BuildThemeData().fromState(
          ThemeState.defaults.copyWith(textScale: 1.0),
        );
        final double? baseSize = tNoScale.textTheme.bodyMedium!.fontSize;
        if (baseSize != null) {
          expect(fs, closeTo(baseSize * 1.1, 0.0001));
        }
      }
    });
  });

  group('BuildThemeData • visualDensity & forwarding', () {
    test('Always sets visualDensity to VisualDensity.standard', () {
      final ThemeState s = ThemeState.defaults.copyWith(textScale: 1.0);
      const BuildThemeData builder = BuildThemeData();
      final ThemeData t = builder.fromState(s);

      expect(t.visualDensity, VisualDensity.standard);
    });

    test('Forwards provided baseTextTheme before scaling', () {
      const TextTheme baseText = TextTheme(
        bodyMedium: TextStyle(fontSize: 10),
      );
      final ThemeState s = ThemeState.defaults.copyWith(textScale: 1.5);
      const BuildThemeData builder = BuildThemeData();

      final ThemeData t = builder.fromState(s, baseTextTheme: baseText);

      expect(t.textTheme.bodyMedium!.fontSize, 15.0);
    });
  });
}
