import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ThemePatch.applyOn – escala tipográfica (clamp & robustez)', () {
    test(
        'Given textScale dentro de rango When applyOn Then se respeta (p. ej. 1.1)',
        () {
      // Arrange
      const ThemePatch patch = ThemePatch(textScale: 1.1);
      final ThemeState base = ThemeState.defaults.copyWith(textScale: 1.0);

      // Act
      final ThemeState updated = patch.applyOn(base);

      // Assert
      expect(updated.textScale, 1.1);
    });

    test('Given textScale menor a 0.8 When applyOn Then se clampa a 0.8', () {
      const ThemePatch patch = ThemePatch(textScale: 0.1); // fuera de rango
      final ThemeState base = ThemeState.defaults.copyWith(textScale: 1.0);

      final ThemeState updated = patch.applyOn(base);

      expect(updated.textScale, 0.8);
    });

    test('Given textScale mayor a 1.6 When applyOn Then se clampa a 1.6', () {
      const ThemePatch patch = ThemePatch(textScale: 9.0); // fuera de rango
      final ThemeState base = ThemeState.defaults.copyWith(textScale: 1.0);

      final ThemeState updated = patch.applyOn(base);

      expect(updated.textScale, 1.6);
    });

    test(
        'Given textScale no finito (infinity) When applyOn Then conserva valor base',
        () {
      const ThemePatch patch = ThemePatch(textScale: double.infinity);
      final ThemeState base = ThemeState.defaults.copyWith(textScale: 1.25);

      final ThemeState updated = patch.applyOn(base);

      expect(updated.textScale, 1.25);
    });

    test('Given textScale null When applyOn Then conserva valor base', () {
      const ThemePatch patch = ThemePatch();
      final ThemeState base = ThemeState.defaults.copyWith(textScale: 1.2);

      final ThemeState updated = patch.applyOn(base);

      expect(updated.textScale, 1.2);
    });
  });

  group('ThemePatch.applyOn – campos escalares', () {
    test('Given modo y seed When applyOn Then reemplaza valores', () {
      const ThemePatch patch = ThemePatch(
        mode: ThemeMode.dark,
        seed: Color(0xFF0061A4),
        useMaterial3: false,
        preset: 'designer',
      );
      final ThemeState base = ThemeState.defaults.copyWith(
        mode: ThemeMode.system,
        seed: const Color(0xFF6750A4),
        useMaterial3: true,
        preset: 'brand',
      );

      final ThemeState updated = patch.applyOn(base);

      expect(updated.mode, ThemeMode.dark);
      expect(updated.seed, const Color(0xFF0061A4));
      expect(updated.useMaterial3, isFalse);
      expect(updated.preset, 'designer');
    });

    test(
        'Given patch vacío When applyOn Then devuelve un estado equivalente al base',
        () {
      const ThemePatch patch = ThemePatch();
      final ThemeState base = ThemeState.defaults.copyWith(
        mode: ThemeMode.light,
        textScale: 1.05,
        preset: 'brand',
      );

      final ThemeState updated = patch.applyOn(base);

      expect(updated, equals(base));
    });
  });

  group('ThemePatch.applyOn – overrides (reemplazo vs conservación)', () {
    test('Given overrides nuevos When applyOn Then reemplaza los existentes',
        () {
      final ThemeOverrides existing = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      );
      final ThemeOverrides replacement = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF006E1C)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006E1C),
          brightness: Brightness.dark,
        ),
      );

      final ThemeState base = ThemeState.defaults.copyWith(overrides: existing);
      final ThemePatch patch = ThemePatch(overrides: replacement);

      final ThemeState updated = patch.applyOn(base);

      expect(updated.overrides, equals(replacement));
      expect(updated.overrides, isNot(equals(existing)));
    });

    test(
        'Given textOverrides nuevos When applyOn Then reemplaza los existentes',
        () {
      const TextThemeOverrides existing = TextThemeOverrides(
        light:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 12)),
      );
      const TextThemeOverrides replacement = TextThemeOverrides(
        light:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        dark:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
      );

      final ThemeState base =
          ThemeState.defaults.copyWith(textOverrides: existing);
      const ThemePatch patch = ThemePatch(textOverrides: replacement);

      final ThemeState updated = patch.applyOn(base);

      expect(updated.textOverrides, equals(replacement));
      expect(updated.textOverrides, isNot(equals(existing)));
    });

    test(
        'Given overrides == null When applyOn Then conserva overrides del base (no nulling)',
        () {
      final ThemeOverrides existing = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      );
      final ThemeState base = ThemeState.defaults.copyWith(overrides: existing);

      const ThemePatch patch = ThemePatch();

      final ThemeState updated = patch.applyOn(base);

      expect(updated.overrides, equals(existing));
    });

    test(
        'Given textOverrides == null When applyOn Then conserva textOverrides del base (no nulling)',
        () {
      const TextThemeOverrides existing = TextThemeOverrides(
        light: TextTheme(titleMedium: TextStyle(fontWeight: FontWeight.w600)),
      );
      final ThemeState base =
          ThemeState.defaults.copyWith(textOverrides: existing);

      const ThemePatch patch = ThemePatch();

      final ThemeState updated = patch.applyOn(base);

      expect(updated.textOverrides, equals(existing));
    });
  });

  group('ThemePatch.copyWith – preserva y reemplaza correctamente', () {
    test(
        'Given patch con valores When copyWith parcial Then mezcla manteniendo los no provistos',
        () {
      const ThemePatch basePatch = ThemePatch(
        mode: ThemeMode.light,
        textScale: 1.2,
        preset: 'brand',
      );

      final ThemePatch patched = basePatch.copyWith(
        mode: ThemeMode.dark, // reemplaza
        seed: const Color(0xFF123456), // agrega
        // textScale no provisto -> conserva 1.2
      );

      expect(patched.mode, ThemeMode.dark);
      expect(patched.seed, const Color(0xFF123456));
      expect(patched.textScale, 1.2);
      expect(patched.preset, 'brand');
    });

    test(
        'Given copyWith con overrides/textOverrides Then actualiza referencias',
        () {
      final ThemeOverrides ov = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF001122)),
      );
      const TextThemeOverrides tov = TextThemeOverrides(
        dark: TextTheme(bodyMedium: TextStyle(fontSize: 13)),
      );

      const ThemePatch basePatch = ThemePatch();
      final ThemePatch p2 = basePatch.copyWith(
        overrides: ov,
        textOverrides: tov,
      );

      expect(p2.overrides, equals(ov));
      expect(p2.textOverrides, equals(tov));
    });
  });
}
