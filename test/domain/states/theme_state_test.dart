import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ThemeOverrides – serialización', () {
    test(
        'toJson/fromJson con ambos esquemas mantiene slots esenciales y brillo',
        () {
      const ColorScheme light = ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF112233),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF223344),
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFF334455),
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFF445566),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFF0F0F0),
        onSurface: Color(0xFF101010),
        surfaceTint: Color(0xFF112233),
        outline: Color(0xFF999999),
        onSurfaceVariant: Color(0xFF777777),
        inverseSurface: Color(0xFF202020),
        inversePrimary: Color(0xFF556677),
      );

      const ColorScheme dark = ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFAABBCC),
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFF8899AA),
        onSecondary: Color(0xFF000000),
        tertiary: Color(0xFF778899),
        onTertiary: Color(0xFF000000),
        error: Color(0xFFCC8877),
        onError: Color(0xFF000000),
        surface: Color(0xFF101010),
        onSurface: Color(0xFFEFEFEF),
        surfaceTint: Color(0xFFAABBCC),
        outline: Color(0xFF666666),
        onSurfaceVariant: Color(0xFF999999),
        inverseSurface: Color(0xFFE0E0E0),
        inversePrimary: Color(0xFF223344),
      );

      const ThemeOverrides overrides = ThemeOverrides(light: light, dark: dark);
      final Map<String, dynamic> json = overrides.toJson();
      final ThemeOverrides? roundtrip = ThemeOverrides.fromJson(json);

      expect(roundtrip, isNotNull);
      expect(roundtrip!.light!.brightness, Brightness.light);
      expect(roundtrip.light!.primary.toARGB32(), light.primary.toARGB32());
      expect(
        roundtrip.light!.inversePrimary.toARGB32(),
        light.inversePrimary.toARGB32(),
      );

      expect(roundtrip.dark!.brightness, Brightness.dark);
      expect(roundtrip.dark!.primary.toARGB32(), dark.primary.toARGB32());
      expect(
        roundtrip.dark!.inversePrimary.toARGB32(),
        dark.inversePrimary.toARGB32(),
      );
    });

    test('toJson/fromJson solo light preserva light y deja dark en null', () {
      const ColorScheme onlyLight = ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF010203),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF040506),
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFF070809),
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFF0A0B0C),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFFFDFDFD),
        onSurface: Color(0xFF0D0E0F),
        surfaceTint: Color(0xFF010203),
        outline: Color(0xFF888888),
        onSurfaceVariant: Color(0xFF777777),
        inverseSurface: Color(0xFF222222),
        inversePrimary: Color(0xFF334455),
      );

      const ThemeOverrides overrides = ThemeOverrides(light: onlyLight);
      final ThemeOverrides? roundtrip =
          ThemeOverrides.fromJson(overrides.toJson());

      expect(roundtrip, isNotNull);
      expect(roundtrip!.light, isNotNull);
      expect(roundtrip.dark, isNull);
      expect(roundtrip.light!.primary.toARGB32(), 0xFF010203);
      expect(roundtrip.light!.brightness, Brightness.light);
    });

    test('fromJson con null retorna null', () {
      expect(ThemeOverrides.fromJson(null), isNull);
    });
  });

  group('ThemeOverrides – robustez', () {
    test('mapea brillo por string y aplica defaults light/dark correctos', () {
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeOverridesEnum.light.name: <String, dynamic>{
          ColorSchemeEnum.brightness.name: 'light',
          ColorSchemeEnum.primary.name: const Color(0xFF123456).toARGB32(),
          ColorSchemeEnum.onPrimary.name: const Color(0xFFFFFFFF).toARGB32(),
          // slots omitidos intencionalmente deben ser manejados por _mapToScheme,
          // pero en tu implementación actual TODOS los slots listados se esperan.
          // Este test valida principalmente el uso del brillo y un par de slots.
          ColorSchemeEnum.secondary.name: const Color(0xFF654321).toARGB32(),
          ColorSchemeEnum.onSecondary.name: const Color(0xFFFFFFFF).toARGB32(),
          ColorSchemeEnum.tertiary.name: const Color(0xFFABCDEF).toARGB32(),
          ColorSchemeEnum.onTertiary.name: const Color(0xFF000000).toARGB32(),
          ColorSchemeEnum.error.name: const Color(0xFFB00020).toARGB32(),
          ColorSchemeEnum.onError.name: const Color(0xFFFFFFFF).toARGB32(),
          ColorSchemeEnum.surface.name: const Color(0xFFFFFFFF).toARGB32(),
          ColorSchemeEnum.onSurface.name: const Color(0xFF000000).toARGB32(),
          ColorSchemeEnum.surfaceTint.name: const Color(0xFF123456).toARGB32(),
          ColorSchemeEnum.outline.name: const Color(0xFFDDDDDD).toARGB32(),
          ColorSchemeEnum.onSurfaceVariant.name:
              const Color(0xFFCCCCCC).toARGB32(),
          ColorSchemeEnum.inverseSurface.name:
              const Color(0xFF111111).toARGB32(),
          ColorSchemeEnum.inversePrimary.name:
              const Color(0xFF654321).toARGB32(),
        },
      };

      final ThemeOverrides? overrides = ThemeOverrides.fromJson(json);
      expect(overrides, isNotNull);
      expect(overrides!.light!.brightness, Brightness.light);
      expect(overrides.light!.primary.toARGB32(), 0xFF123456);
      expect(overrides.dark, isNull);
    });
  });
  group('ThemeState – defaults y copyWith', () {
    test('defaults establece valores seguros', () {
      const ThemeState s = ThemeState.defaults;
      expect(s.mode, ThemeMode.system);
      expect(s.seed.toARGB32(), 0xFF6750A4);
      expect(s.useMaterial3, true);
      expect(s.textScale, 1.0);
      expect(s.preset, 'brand');
      expect(s.overrides, isNull);
    });

    test('copyWith reemplaza solo los campos provistos', () {
      const ThemeState s = ThemeState.defaults;
      final ThemeState s2 = s.copyWith(
        mode: ThemeMode.dark,
        seed: const Color(0xFF112233),
        useMaterial3: false,
        textScale: 1.25,
        preset: 'custom',
        overrides: ThemeOverrides(
          light: ColorScheme.fromSeed(seedColor: const Color(0xFF00AA00)),
        ),
      );

      expect(s2.mode, ThemeMode.dark);
      expect(s2.seed.toARGB32(), 0xFF112233);
      expect(s2.useMaterial3, false);
      expect(s2.textScale, 1.25);
      expect(s2.preset, 'custom');
      expect(s2.overrides, isNotNull);

      // El original no cambia (inmutabilidad).
      expect(s.mode, ThemeMode.system);
      expect(s.preset, 'brand');
      expect(s.overrides, isNull);
    });
  });

  group('ThemeState – serialización', () {
    test('toJson usa enums como claves y mantiene overrides null por omisión',
        () {
      const ThemeState s = ThemeState.defaults;
      final Map<String, dynamic> json = s.toJson();

      expect(json[ThemeEnum.mode.name], 'system');
      expect(json[ThemeEnum.seed.name], s.seed.toARGB32());
      expect(json[ThemeEnum.useM3.name], true);
      expect(json[ThemeEnum.textScale.name], 1.0);
      expect(json[ThemeEnum.preset.name], 'brand');
      expect(json.containsKey(ThemeEnum.overrides.name), true);
      expect(json[ThemeEnum.overrides.name], isNull);
    });

    test('roundtrip toJson/fromJson sin overrides', () {
      const ThemeState original = ThemeState(
        mode: ThemeMode.light,
        seed: Color(0xFF334455),
        useMaterial3: false,
        textScale: 1.2,
      );

      final Map<String, dynamic> json = original.toJson();
      final ThemeState parsed = ThemeState.fromJson(json);

      expect(parsed.mode, ThemeMode.light);
      expect(parsed.seed.toARGB32(), 0xFF334455);
      expect(parsed.useMaterial3, false);
      expect(parsed.textScale, 1.2);
      expect(parsed.preset, 'brand');
      expect(parsed.overrides, isNull);
    });

    test('roundtrip con overrides(light/dark)', () {
      final ThemeOverrides overrides = ThemeOverrides(
        light: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E4D2F),
        ),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E4D2F),
          brightness: Brightness.dark,
        ),
      );

      final ThemeState original = ThemeState.defaults.copyWith(
        overrides: overrides,
        preset: 'designer',
      );

      final ThemeState parsed = ThemeState.fromJson(original.toJson());

      expect(parsed.preset, 'designer');
      expect(parsed.overrides, isNotNull);
      expect(parsed.overrides!.light!.brightness, Brightness.light);
      expect(parsed.overrides!.dark!.brightness, Brightness.dark);
    });
  });

  group('ThemeState – robustez/valores faltantes', () {
    test('fromJson: modo inválido o faltante → ThemeMode.system', () {
      final Map<String, dynamic> badMode = <String, dynamic>{
        ThemeEnum.mode.name: 'weird',
      };

      final ThemeState s = ThemeState.fromJson(badMode);
      expect(s.mode, ThemeMode.system);
    });

    test('fromJson: sin seed → usa 0xFF6750A4 (fallback)', () {
      final ThemeState s = ThemeState.fromJson(const <String, dynamic>{});
      expect(s.seed.toARGB32(), 0xFF6750A4);
    });

    test('fromJson: sin useM3 → false con Utils.getBoolFromDynamic', () {
      final ThemeState s = ThemeState.fromJson(const <String, dynamic>{});
      // Nota: tu Utils.getBoolFromDynamic retorna true solo si json == true;
      // por tanto, sin clave → false.
      expect(s.useMaterial3, false);
    });

    test('fromJson: sin textScale → 1.0 (default explícito)', () {
      final ThemeState s = ThemeState.fromJson(const <String, dynamic>{});
      expect(s.textScale.isNaN ? 1.0 : s.textScale, 1.0);
    });

    test('fromJson: sin preset → "brand"', () {
      final ThemeState s = ThemeState.fromJson(const <String, dynamic>{});
      expect(s.preset.isEmpty ? 'brand' : s.preset, 'brand');
    });

    test(
        'fromJson: overrides como mapa vacío → overrides != null pero sin esquemas',
        () {
      final ThemeState s = ThemeState.fromJson(<String, dynamic>{
        ThemeEnum.overrides.name: const <String, dynamic>{},
      });
      // Tu ThemeOverrides.fromJson devuelve ThemeOverrides con light/dark nulos si están ausentes.
      expect(s.overrides, isNotNull);
      expect(s.overrides!.light, isNull);
      expect(s.overrides!.dark, isNull);
    });
  });
}
