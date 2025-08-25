import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  const ServiceJocaaguraArchetypeTheme svc = ServiceJocaaguraArchetypeTheme();

  group('ServiceJocaaguraArchetypeTheme.schemeFromSeed', () {
    test('genera ColorScheme determinista para light/dark', () {
      const Color seed = Color(0xFF8E4D2F);

      final ColorScheme light = svc.schemeFromSeed(seed, Brightness.light);
      final ColorScheme dark = svc.schemeFromSeed(seed, Brightness.dark);

      // Coherente con la API nativa
      expect(light.primary,
          ColorScheme.fromSeed(seedColor: seed).primary,);
      expect(dark.primary,
          ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).primary,);

      // No deben ser iguales entre sí (brillo distinto)
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.primary, isNot(equals(dark.primary)));
    });
  });

  group('ServiceJocaaguraArchetypeTheme.lightTheme/darkTheme', () {
    test('respeta seed y useMaterial3 (light)', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.light,
        seed: Color(0xFF336699),
        useMaterial3: true,
      );

      final ThemeData t = svc.lightTheme(s);

      expect(t.useMaterial3, isTrue);
      expect(t.colorScheme.brightness, Brightness.light);
      // Validación de coherencia con fromSeed
      final ColorScheme expected =
      ColorScheme.fromSeed(seedColor: s.seed);
      expect(t.colorScheme.primary, expected.primary);
    });

    test('respeta seed y useMaterial3 (dark)', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.dark,
        seed: Color(0xFF114455),
        useMaterial3: false,
      );

      final ThemeData t = svc.darkTheme(s);

      expect(t.useMaterial3, isFalse);
      expect(t.colorScheme.brightness, Brightness.dark);
      final ColorScheme expected =
      ColorScheme.fromSeed(seedColor: s.seed, brightness: Brightness.dark);
      expect(t.colorScheme.primary, expected.primary);
    });
  });

  group('ServiceJocaaguraArchetypeTheme.toThemeData (elige brillo según ThemeMode)', () {
    test('ThemeMode.light ignora platformBrightness y fuerza Brightness.light', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.light,
        seed: Color(0xFFAA5500),
        useMaterial3: true,
      );

      // Aunque la plataforma sea dark, el modo light debe imponerse
      final ThemeData t = svc.toThemeData(s, platformBrightness: Brightness.dark);

      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.useMaterial3, isTrue);

      final ColorScheme expected =
      ColorScheme.fromSeed(seedColor: s.seed);
      expect(t.colorScheme.primary, expected.primary);
    });

    test('ThemeMode.dark ignora platformBrightness y fuerza Brightness.dark', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.dark,
        seed: Color(0xFF7722CC),
        useMaterial3: false,
      );

      // Aunque la plataforma sea light, el modo dark debe imponerse
      final ThemeData t = svc.toThemeData(s, platformBrightness: Brightness.light);

      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.useMaterial3, isFalse);

      final ColorScheme expected =
      ColorScheme.fromSeed(seedColor: s.seed, brightness: Brightness.dark);
      expect(t.colorScheme.primary, expected.primary);
    });

    test('ThemeMode.system usa platformBrightness (light)', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.system,
        seed: Color(0xFF009688),
        useMaterial3: true,
      );

      final ThemeData t = svc.toThemeData(s, platformBrightness: Brightness.light);

      expect(t.colorScheme.brightness, Brightness.light);
      final ColorScheme expected =
      ColorScheme.fromSeed(seedColor: s.seed);
      expect(t.colorScheme.primary, expected.primary);
    });

    test('ThemeMode.system usa platformBrightness (dark)', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.system,
        seed: Color(0xFF009688),
        useMaterial3: true,
      );

      final ThemeData t = svc.toThemeData(s, platformBrightness: Brightness.dark);

      expect(t.colorScheme.brightness, Brightness.dark);
      final ColorScheme expected =
      ColorScheme.fromSeed(seedColor: s.seed, brightness: Brightness.dark);
      expect(t.colorScheme.primary, expected.primary);
    });

    test('siempre fija visualDensity a VisualDensity.standard', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.system,
        seed: Color(0xFF333333),
        useMaterial3: true,
      );

      final ThemeData tLight =
      svc.toThemeData(s, platformBrightness: Brightness.light);
      final ThemeData tDark =
      svc.toThemeData(s, platformBrightness: Brightness.dark);

      expect(tLight.visualDensity, VisualDensity.standard);
      expect(tDark.visualDensity, VisualDensity.standard);
    });
  });
}
