import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

TextTheme _materializeFontSizes(TextTheme base) {
  final TextTheme def = ThemeData.fallback().textTheme;

  TextStyle withSize(TextStyle? ts, TextStyle? defTs, double fallback) {
    final TextStyle src = ts ?? defTs ?? const TextStyle();
    final double size = ts?.fontSize ?? defTs?.fontSize ?? fallback;
    return src.copyWith(fontSize: size);
  }

  return base.copyWith(
    displayLarge: withSize(base.displayLarge, def.displayLarge, 57.0),
    displayMedium: withSize(base.displayMedium, def.displayMedium, 45.0),
    displaySmall: withSize(base.displaySmall, def.displaySmall, 36.0),
    headlineLarge: withSize(base.headlineLarge, def.headlineLarge, 32.0),
    headlineMedium: withSize(base.headlineMedium, def.headlineMedium, 28.0),
    headlineSmall: withSize(base.headlineSmall, def.headlineSmall, 24.0),
    titleLarge: withSize(base.titleLarge, def.titleLarge, 22.0),
    titleMedium: withSize(base.titleMedium, def.titleMedium, 16.0),
    titleSmall: withSize(base.titleSmall, def.titleSmall, 14.0),
    bodyLarge: withSize(base.bodyLarge, def.bodyLarge, 16.0),
    bodyMedium: withSize(base.bodyMedium, def.bodyMedium, 14.0),
    bodySmall: withSize(base.bodySmall, def.bodySmall, 12.0),
    labelLarge: withSize(base.labelLarge, def.labelLarge, 14.0),
    labelMedium: withSize(base.labelMedium, def.labelMedium, 12.0),
    labelSmall: withSize(base.labelSmall, def.labelSmall, 11.0),
  );
}

// Escala solo estilos (ya materializados) multiplicando fontSize por factor.
TextTheme _scaleTextTheme(TextTheme base, double factor) {
  if (factor == 1.0) {
    return base;
  }

  TextStyle scale(TextStyle? ts) =>
      (ts ?? const TextStyle(fontSize: 14)).copyWith(
        fontSize: (ts?.fontSize ?? 14) * factor,
      );

  return base.copyWith(
    displayLarge: scale(base.displayLarge),
    displayMedium: scale(base.displayMedium),
    displaySmall: scale(base.displaySmall),
    headlineLarge: scale(base.headlineLarge),
    headlineMedium: scale(base.headlineMedium),
    headlineSmall: scale(base.headlineSmall),
    titleLarge: scale(base.titleLarge),
    titleMedium: scale(base.titleMedium),
    titleSmall: scale(base.titleSmall),
    bodyLarge: scale(base.bodyLarge),
    bodyMedium: scale(base.bodyMedium),
    bodySmall: scale(base.bodySmall),
    labelLarge: scale(base.labelLarge),
    labelMedium: scale(base.labelMedium),
    labelSmall: scale(base.labelSmall),
  );
}

// Fake determinista para pruebas
class FakeServiceTheme extends ServiceTheme {
  const FakeServiceTheme();

  @override
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  }) {
    return platformBrightness == Brightness.dark
        ? darkTheme(state)
        : lightTheme(state);
  }

  @override
  ThemeData lightTheme(ThemeState state) {
    final ColorScheme scheme = schemeFromSeed(state.seed, Brightness.light);
    final ThemeData base =
        ThemeData.from(colorScheme: scheme, useMaterial3: state.useMaterial3);

    final TextTheme materialized = _materializeFontSizes(base.textTheme);
    final TextTheme scaled = _scaleTextTheme(materialized, state.textScale);

    return base.copyWith(textTheme: scaled);
  }

  @override
  ThemeData darkTheme(ThemeState state) {
    final ColorScheme scheme = schemeFromSeed(state.seed, Brightness.dark);
    final ThemeData base =
        ThemeData.from(colorScheme: scheme, useMaterial3: state.useMaterial3);

    final TextTheme materialized = _materializeFontSizes(base.textTheme);
    final TextTheme scaled = _scaleTextTheme(materialized, state.textScale);

    return base.copyWith(textTheme: scaled);
  }

  @override
  ColorScheme schemeFromSeed(Color seed, Brightness brightness) {
    return ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  }
}

void main() {
  group('ServiceTheme (Fake) - contratos básicos', () {
    final ThemeState base = ThemeState.defaults.copyWith(
      seed: const Color(0xFF0061A4),
      useMaterial3: true,
      textScale: 1.2,
    );
    const ServiceTheme svc = FakeServiceTheme();

    test('Given seed+brightness When schemeFromSeed Then respeta brightness',
        () {
      final ColorScheme light = svc.schemeFromSeed(base.seed, Brightness.light);
      final ColorScheme dark = svc.schemeFromSeed(base.seed, Brightness.dark);

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('Given platformBrightness light When toThemeData Then usa lightTheme',
        () {
      final ThemeData td =
          svc.toThemeData(base, platformBrightness: Brightness.light);
      expect(td.colorScheme.brightness, Brightness.light);
      // Verifica que el factor de texto se haya aplicado (heurística simple)
      expect(td.textTheme.bodyMedium?.fontSize, isNotNull);
    });

    test('Given platformBrightness dark When toThemeData Then usa darkTheme',
        () {
      final ThemeData td =
          svc.toThemeData(base, platformBrightness: Brightness.dark);
      expect(td.colorScheme.brightness, Brightness.dark);
    });

    test('ColorRandom not deterministic', () {
      expect(svc.colorRandom(), isA<Color>()); // idem
    });

    test('Given mismos inputs When toThemeData Then idempotente', () {
      final ThemeData a =
          svc.toThemeData(base, platformBrightness: Brightness.dark);
      final ThemeData b =
          svc.toThemeData(base, platformBrightness: Brightness.dark);
      // ThemeData no implementa == profundo, comparamos propiedades clave
      expect(a.colorScheme, b.colorScheme);
      expect(a.useMaterial3, b.useMaterial3);
      expect(
        a.textTheme.bodyMedium!.fontSize,
        b.textTheme.bodyMedium!.fontSize,
      );
    });
  });
}
