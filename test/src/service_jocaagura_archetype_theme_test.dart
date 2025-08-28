import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ServiceJocaaguraArchetypeTheme · schemeFromSeed()', () {
    test('respeta el Brightness y es determinista para misma semilla', () {
      const ServiceJocaaguraArchetypeTheme svc =
          ServiceJocaaguraArchetypeTheme();
      const Color seed = Color(0xFF8E4D2F);

      final ColorScheme light1 = svc.schemeFromSeed(seed, Brightness.light);
      final ColorScheme light2 = svc.schemeFromSeed(seed, Brightness.light);
      final ColorScheme dark1 = svc.schemeFromSeed(seed, Brightness.dark);

      expect(light1.brightness, Brightness.light);
      expect(dark1.brightness, Brightness.dark);

      // Determinismo para misma entrada
      expect(light1.primary, light2.primary);

      // Cambia con el brillo
      expect(light1.primary, isNot(equals(dark1.primary)));
    });
  });

  group('ServiceJocaaguraArchetypeTheme · toThemeData()', () {
    const ServiceJocaaguraArchetypeTheme svc = ServiceJocaaguraArchetypeTheme();
    const Color seed = Color(0xFF446688);

    test('ThemeMode.light fuerza Brightness.light y respeta useMaterial3', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.light,
        seed: seed,
        useMaterial3: true,
      );

      final ThemeData t = svc.toThemeData(
        s,
        platformBrightness: Brightness.dark, // debe ser ignorado en modo light
      );

      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.useMaterial3, isTrue);
      expect(t.visualDensity, VisualDensity.standard);
    });

    test('ThemeMode.dark fuerza Brightness.dark y respeta useMaterial3=false',
        () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.dark,
        seed: seed,
        useMaterial3: false,
      );

      final ThemeData t = svc.toThemeData(
        s,
        platformBrightness: Brightness.light, // ignorado en modo dark
      );

      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.useMaterial3, isFalse);
      expect(t.visualDensity, VisualDensity.standard);
    });

    test('ThemeMode.system usa platformBrightness', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.system,
        seed: seed,
        useMaterial3: true,
      );

      final ThemeData tLight = svc.toThemeData(
        s,
        platformBrightness: Brightness.light,
      );
      final ThemeData tDark = svc.toThemeData(
        s,
        platformBrightness: Brightness.dark,
      );

      expect(tLight.colorScheme.brightness, Brightness.light);
      expect(tDark.colorScheme.brightness, Brightness.dark);
    });
  });

  group('ServiceJocaaguraArchetypeTheme · lightTheme()/darkTheme()', () {
    const ServiceJocaaguraArchetypeTheme svc = ServiceJocaaguraArchetypeTheme();
    const Color seed = Color(0xFF225577);

    test('lightTheme construye ThemeData con brightness light', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.system, // no afecta a estos helpers
        seed: seed,
        useMaterial3: true,
      );
      final ThemeData t = svc.lightTheme(s);
      expect(t.colorScheme.brightness, Brightness.light);

      // Sanity: el scheme proviene de la misma función interna
      final ColorScheme expected = svc.schemeFromSeed(seed, Brightness.light);
      expect(t.colorScheme.primary, expected.primary);
      expect(t.useMaterial3, isTrue);
    });

    test('darkTheme construye ThemeData con brightness dark', () {
      const ThemeState s = ThemeState(
        mode: ThemeMode.system,
        seed: seed,
        useMaterial3: false,
      );
      final ThemeData t = svc.darkTheme(s);
      expect(t.colorScheme.brightness, Brightness.dark);

      final ColorScheme expected = svc.schemeFromSeed(seed, Brightness.dark);
      expect(t.colorScheme.primary, expected.primary);
      expect(t.useMaterial3, isFalse);
    });
  });

  group('ServiceTheme.base · colorRandom()', () {
    // Verifica la funcion provista por la clase base abstracta
    const ServiceJocaaguraArchetypeTheme svc = ServiceJocaaguraArchetypeTheme();

    test(
        'retorna colores opacos dentro de rango 0-255 y suficientemente variados',
        () {
      // Tomamos varias muestras para asegurar variedad (probabilidad de colisión muy baja)
      const int samples = 50;
      final Set<int> seen = <int>{};

      for (int i = 0; i < samples; i += 1) {
        final Color c = svc.colorRandom();
        // Opacidad completa
        expect(c.a, 1);
        // Rango válido de componentes
        expect(c.r, inInclusiveRange(0, 255));
        expect(c.g, inInclusiveRange(0, 255));
        expect(c.b, inInclusiveRange(0, 255));
        seen.add(c.toARGB32());
      }

      // Debe haber más de un color distinto con altísima probabilidad
      expect(seen.length, greaterThan(1));
    });

    test('no debe lanzar excepciones al invocarse repetidamente', () {
      expect(
        () {
          for (int i = 0; i < 200; i += 1) {
            svc.colorRandom();
          }
        },
        returnsNormally,
      );
    });
  });
}
