import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ThemeOverrides – roundtrip & equality', () {
    test('Given full light/dark When toJson/fromJson Then preserves all fields',
        () {
      const Color seed = Color(0xFF6750A4);
      final ThemeOverrides original = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: seed),
        dark:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      );

      final ThemeOverrides restored =
          ThemeOverrides.fromJson(original.toJson())!;

      expect(restored, equals(original));
      expect(restored.light!.brightness, Brightness.light);
      expect(restored.dark!.brightness, Brightness.dark);
    });

    test('Given only light scheme When roundtrip Then dark remains null', () {
      final ThemeOverrides a = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF0B57D0)),
      );
      final ThemeOverrides b = ThemeOverrides.fromJson(a.toJson())!;
      expect(b.dark, isNull);
      expect(b, equals(a));
    });

    test('Given identical schemes When hashCode Then equal hashes', () {
      final ThemeOverrides x = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF006E1C)),
      );
      final ThemeOverrides y = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF006E1C)),
      );
      expect(x, equals(y));
      expect(x.hashCode, equals(y.hashCode));
    });

    test(
        'Given copyWith When overriding light Then keeps dark and changes light',
        () {
      final ThemeOverrides base = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF006E1C)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006E1C),
          brightness: Brightness.dark,
        ),
      );
      final ThemeOverrides changed = base.copyWith(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFFA00000)),
      );

      expect(changed.dark, equals(base.dark));
      expect(changed.light, isNot(equals(base.light)));
    });
  });

  group('ThemeOverrides – error paths', () {
    test('Given malformed HEX color When fromJson Then throws', () {
      final Map<String, dynamic> bad = <String, dynamic>{
        ThemeOverridesEnum.light.name: <String, dynamic>{
          ColorSchemeEnum.brightness.name: 'light',
          // Campo obligatorio presente pero con HEX inválido
          ColorSchemeEnum.primary.name: '#GGFFFF00',
          ColorSchemeEnum.onPrimary.name: '#FFFFFFFF',
          ColorSchemeEnum.secondary.name: '#FF000000',
          ColorSchemeEnum.onSecondary.name: '#FFFFFFFF',
          ColorSchemeEnum.tertiary.name: '#FF000000',
          ColorSchemeEnum.onTertiary.name: '#FFFFFFFF',
          ColorSchemeEnum.error.name: '#FF000000',
          ColorSchemeEnum.onError.name: '#FFFFFFFF',
          ColorSchemeEnum.surface.name: '#FF000000',
          ColorSchemeEnum.onSurface.name: '#FFFFFFFF',
          ColorSchemeEnum.surfaceTint.name: '#00000000',
          ColorSchemeEnum.outline.name: '#11000000',
          ColorSchemeEnum.onSurfaceVariant.name: '#22000000',
          ColorSchemeEnum.inverseSurface.name: '#33000000',
          ColorSchemeEnum.inversePrimary.name: '#44000000',
        },
        ThemeOverridesEnum.dark.name: null,
      };

      expect(() => ThemeOverrides.fromJson(bad), throwsA(isA<Exception>()));
    });

    test(
        'Given missing required key in present scheme When fromJson Then throws',
        () {
      final Map<String, dynamic> missing = <String, dynamic>{
        ThemeOverridesEnum.light.name: <String, dynamic>{
          ColorSchemeEnum.brightness.name: 'light',
          // Falta primary
          ColorSchemeEnum.onPrimary.name: '#FFFFFFFF',
          ColorSchemeEnum.secondary.name: '#FF000000',
          ColorSchemeEnum.onSecondary.name: '#FFFFFFFF',
          ColorSchemeEnum.tertiary.name: '#FF000000',
          ColorSchemeEnum.onTertiary.name: '#FFFFFFFF',
          ColorSchemeEnum.error.name: '#FF000000',
          ColorSchemeEnum.onError.name: '#FFFFFFFF',
          ColorSchemeEnum.surface.name: '#FF000000',
          ColorSchemeEnum.onSurface.name: '#FFFFFFFF',
          ColorSchemeEnum.surfaceTint.name: '#00000000',
          ColorSchemeEnum.outline.name: '#11000000',
          ColorSchemeEnum.onSurfaceVariant.name: '#22000000',
          ColorSchemeEnum.inverseSurface.name: '#33000000',
          ColorSchemeEnum.inversePrimary.name: '#44000000',
        },
        ThemeOverridesEnum.dark.name: null,
      };

      // parseColorCanonical recibirá null y debe lanzar
      expect(() => ThemeOverrides.fromJson(missing), throwsA(isA<Exception>()));
    });

    test('Given null json When fromJson Then returns null', () {
      expect(ThemeOverrides.fromJson(null), isNull);
    });

    test('Expect they are not identical', () {
      const Color seed = Color(0xFF6750A4);
      final ThemeOverrides original = ThemeOverrides(
        light: ColorScheme.fromSeed(
          seedColor: seed,
        ),
        dark:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      );
      final ThemeOverrides copy = ThemeOverrides(
        light: ColorScheme.fromSeed(
          seedColor: seed,
        ),
      );

      expect(original == copy, isFalse);
    });
  });
}
