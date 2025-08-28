import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FakeServiceJocaaguraArchetypeTheme · colorRandom', () {
    test('colorRandom() devuelve el color fijo 0xFF0066CC', () {
      const FakeServiceJocaaguraArchetypeTheme svc =
          FakeServiceJocaaguraArchetypeTheme();
      expect(svc.colorRandom().toARGB32(), 0xFF0066CC);
    });
  });

  group('FakeServiceJocaaguraArchetypeTheme · schemeFromSeed', () {
    test('ignora el seed: para mismo Brightness, el esquema es consistente',
        () {
      const FakeServiceJocaaguraArchetypeTheme svc =
          FakeServiceJocaaguraArchetypeTheme();

      final ColorScheme aLight =
          svc.schemeFromSeed(const Color(0xFF123456), Brightness.light);
      final ColorScheme bLight =
          svc.schemeFromSeed(const Color(0xFFABCDEF), Brightness.light);

      // Como el servicio fake ignora el seed, varios slots deben coincidir
      expect(aLight.primary.toARGB32(), bLight.primary.toARGB32());
      expect(aLight.secondary.toARGB32(), bLight.secondary.toARGB32());
      expect(aLight.surface.toARGB32(), bLight.surface.toARGB32());
      expect(aLight.brightness, Brightness.light);

      final ColorScheme aDark =
          svc.schemeFromSeed(const Color(0xFF123456), Brightness.dark);
      final ColorScheme bDark =
          svc.schemeFromSeed(const Color(0xFFABCDEF), Brightness.dark);

      expect(aDark.primary.toARGB32(), bDark.primary.toARGB32());
      expect(aDark.secondary.toARGB32(), bDark.secondary.toARGB32());
      expect(aDark.surface.toARGB32(), bDark.surface.toARGB32());
      expect(aDark.brightness, Brightness.dark);

      // Y los esquemas para light vs dark deben diferir al menos en el brillo
      expect(aLight.brightness != aDark.brightness, isTrue);
    });
  });

  group('FakeServiceJocaaguraArchetypeTheme · toThemeData', () {
    const FakeServiceJocaaguraArchetypeTheme svc =
        FakeServiceJocaaguraArchetypeTheme();

    test('ThemeMode.light → ThemeData con Brightness.light y useM3 ON/OFF', () {
      final ThemeState base = ThemeState.defaults
          .copyWith(mode: ThemeMode.light, useMaterial3: true);
      final ThemeData t1 = svc.toThemeData(
        base,
        platformBrightness:
            Brightness.dark, // debe ignorarse por ThemeMode.light
      );

      expect(t1.colorScheme.brightness, Brightness.light);
      expect(t1.useMaterial3, isTrue);

      final ThemeData t2 = svc.toThemeData(
        base.copyWith(useMaterial3: false),
        platformBrightness: Brightness.light,
      );
      expect(t2.colorScheme.brightness, Brightness.light);
      expect(t2.useMaterial3, isFalse);

      // Usa schemeFromSeed del fake (que ignora seed); verificamos un par de slots.
      final ColorScheme refLight =
          svc.schemeFromSeed(base.seed, Brightness.light);
      expect(t1.colorScheme.primary.toARGB32(), refLight.primary.toARGB32());
      expect(
          t2.colorScheme.secondary.toARGB32(), refLight.secondary.toARGB32());
    });

    test('ThemeMode.dark → ThemeData con Brightness.dark', () {
      final ThemeState base = ThemeState.defaults
          .copyWith(mode: ThemeMode.dark, useMaterial3: true);

      final ThemeData t = svc.toThemeData(
        base,
        platformBrightness: Brightness.light, // ignorado por ThemeMode.dark
      );

      expect(t.colorScheme.brightness, Brightness.dark);
      expect(t.useMaterial3, isTrue);

      final ColorScheme refDark =
          svc.schemeFromSeed(base.seed, Brightness.dark);
      expect(t.colorScheme.primary.toARGB32(), refDark.primary.toARGB32());
    });

    test('ThemeMode.system → usa platformBrightness', () {
      final ThemeState base =
          ThemeState.defaults.copyWith(mode: ThemeMode.system);

      final ThemeData tLight =
          svc.toThemeData(base, platformBrightness: Brightness.light);
      expect(tLight.colorScheme.brightness, Brightness.light);

      final ThemeData tDark =
          svc.toThemeData(base, platformBrightness: Brightness.dark);
      expect(tDark.colorScheme.brightness, Brightness.dark);

      // Cambiar useMaterial3 se refleja en ThemeData
      final ThemeData tLightM2 = svc.toThemeData(
        base.copyWith(useMaterial3: false),
        platformBrightness: Brightness.light,
      );
      expect(tLightM2.useMaterial3, isFalse);
    });
  });

  group('FakeServiceJocaaguraArchetypeTheme · lightTheme / darkTheme', () {
    const FakeServiceJocaaguraArchetypeTheme svc =
        FakeServiceJocaaguraArchetypeTheme();

    test('lightTheme usa schemeFromSeed(..., Brightness.light)', () {
      final ThemeState s =
          ThemeState.defaults.copyWith(seed: const Color(0xFF987654));
      final ThemeData t = svc.lightTheme(s);

      expect(t.colorScheme.brightness, Brightness.light);
      final ColorScheme ref = svc.schemeFromSeed(s.seed, Brightness.light);
      expect(t.colorScheme.primary.toARGB32(), ref.primary.toARGB32());
      expect(t.useMaterial3, s.useMaterial3);
    });

    test('darkTheme usa schemeFromSeed(..., Brightness.dark)', () {
      final ThemeState s =
          ThemeState.defaults.copyWith(seed: const Color(0xFF111222));
      final ThemeData t = svc.darkTheme(s);

      expect(t.colorScheme.brightness, Brightness.dark);
      final ColorScheme ref = svc.schemeFromSeed(s.seed, Brightness.dark);
      expect(t.colorScheme.primary.toARGB32(), ref.primary.toARGB32());
      expect(t.useMaterial3, s.useMaterial3);
    });
  });
}
