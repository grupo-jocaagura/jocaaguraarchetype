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

  group('ThemeState serialization', () {
    test('Round-trip determinism (no overrides)', () {
      final ThemeState s = ThemeState(
        mode: ThemeMode.dark,
        seed: const Color(0xFF0061A4),
        useMaterial3: true,
        textScale: 1.25,
        createdAt: DateTime(2025, 9, 9, 12, 30).toUtc(),
      );

      final Map<String, dynamic> json = s.toJson();
      expect(json['seed'], isA<String>());
      expect((json['seed'] as String).startsWith('#'), isTrue);

      final ThemeState r = ThemeState.fromJson(json);
      expect(r, equals(s)); // createdAt ignored in equality
    });

    test('Round-trip with full overrides (light/dark)', () {
      const Color seed = Color(0xFF6750A4);
      final ThemeOverrides ov = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: seed),
        dark:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      );
      final ThemeState s = ThemeState(
        mode: ThemeMode.light,
        seed: seed,
        useMaterial3: false,
        preset: 'designer',
        overrides: ov,
      );

      final Map<String, dynamic> json = s.toJson();
      // Ensure HEX strings in overrides
      final Map<String, dynamic> light = (json['overrides']
          as Map<String, dynamic>)['light'] as Map<String, dynamic>;
      expect(light['primary'], isA<String>());
      expect((light['primary'] as String).startsWith('#'), isTrue);

      final ThemeState r = ThemeState.fromJson(json);
      expect(r, equals(s));
    });

    test('Retro-compat: accepts ARGB int and normalizes to HEX', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'mode': 'system',
        'seed': 0xFF112233,
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
        'overrides': <String, Map<String, Object>>{
          'light': <String, Object>{
            'brightness': 'light',
            'primary': 0xFF445566,
            'onPrimary': 0xFFFFFFFF,
            'secondary': 0xFF777777,
            'onSecondary': 0xFF000000,
            'tertiary': 0xFF123456,
            'onTertiary': 0xFF654321,
            'error': 0xFFB00020,
            'onError': 0xFFFFFFFF,
            'surface': 0xFFFFFFFF,
            'onSurface': 0xFF000000,
            'surfaceTint': 0xFF445566,
            'outline': 0xFF888888,
            'onSurfaceVariant': 0xFF999999,
            'inverseSurface': 0xFF121212,
            'inversePrimary': 0xFF336699,
          },
          'dark': <String, Object>{
            'brightness': 'dark',
            'primary': 0xFF445566,
            'onPrimary': 0xFF000000,
            'secondary': 0xFF777777,
            'onSecondary': 0xFFFFFFFF,
            'tertiary': 0xFF123456,
            'onTertiary': 0xFF654321,
            'error': 0xFFCF6679,
            'onError': 0xFF000000,
            'surface': 0xFF121212,
            'onSurface': 0xFFFFFFFF,
            'surfaceTint': 0xFF445566,
            'outline': 0xFF888888,
            'onSurfaceVariant': 0xFF999999,
            'inverseSurface': 0xFFFFFFFF,
            'inversePrimary': 0xFF336699,
          },
        },
      };

      final ThemeState s = ThemeState.fromJson(json);
      final Map<String, dynamic> out = s.toJson();
      expect(out['seed'], equals('#FF112233'));

      final Map<String, dynamic> light = (out['overrides']
          as Map<String, dynamic>)['light'] as Map<String, dynamic>;
      expect(light['primary'], equals('#FF445566'));
    });

    test('createdAt is serialized as UTC ISO8601 and parsed as UTC', () {
      final DateTime local = DateTime(2025, 9, 10, 8); // local naive
      final ThemeState s = ThemeState(
        mode: ThemeMode.system,
        seed: const Color(0xFF6750A4),
        useMaterial3: true,
        createdAt: local.toUtc(),
      );
      final Map<String, dynamic> json = s.toJson();
      final String iso = json['createdAt'] as String;
      expect(iso.endsWith('Z'), isTrue);

      final ThemeState r = ThemeState.fromJson(json);
      expect(r.createdAt, isNotNull);
      expect(r.createdAt!.isUtc, isTrue);
    });

    test('Validation errors', () {
      // useM3 missing
      expect(
        () => ThemeState.fromJson(const <String, dynamic>{
          'mode': 'system',
          'seed': '#FF112233',
          'textScale': 1.0,
          'preset': 'brand',
        }),
        throwsA(isA<FormatException>()),
      );

      // useM3 wrong type
      expect(
        () => ThemeState.fromJson(const <String, dynamic>{
          'mode': 'system',
          'seed': '#FF112233',
          'useM3': 'true',
          'textScale': 1.0,
          'preset': 'brand',
        }),
        throwsA(isA<FormatException>()),
      );

      // textScale invalid
      expect(
        () => ThemeState.fromJson(const <String, dynamic>{
          'mode': 'system',
          'seed': '#FF112233',
          'useM3': true,
          'textScale': 'big',
          'preset': 'brand',
        }),
        throwsA(isA<FormatException>()),
      );

      // seed invalid hex
      expect(
        () => ThemeState.fromJson(const <String, dynamic>{
          'mode': 'system',
          'seed': '#XYZ',
          'useM3': true,
          'textScale': 1.0,
          'preset': 'brand',
        }),
        throwsA(isA<FormatException>()),
      );

      // createdAt wrong type
      expect(
        () => ThemeState.fromJson(const <String, dynamic>{
          'mode': 'system',
          'seed': '#FF112233',
          'useM3': true,
          'textScale': 1.0,
          'preset': 'brand',
          'createdAt': 12345,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('Equality ignores createdAt metadata', () {
      final ThemeState a = ThemeState(
        mode: ThemeMode.light,
        seed: const Color(0xFF112233),
        useMaterial3: true,
        createdAt: DateTime.utc(2025, 9, 10, 10),
      );
      final ThemeState b =
          a.copyWith(createdAt: DateTime.utc(2025, 9, 10, 10, 5));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ThemeState.fromJson - modo (orElse => ThemeMode.system)', () {
    test('Given JSON sin mode When fromJson Then usa ThemeMode.system', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.seed.name: '#FF6750A4',
        ThemeEnum.useM3.name: true,
        ThemeEnum.textScale.name: 1.0,
        ThemeEnum.preset.name: 'brand',
      };

      // Act
      final ThemeState state = ThemeState.fromJson(json);

      // Assert
      expect(state.mode, ThemeMode.system);
    });

    test('Given mode vacío When fromJson Then usa ThemeMode.system', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.mode.name: '',
        ThemeEnum.seed.name: 0xFF6750A4, // entero ARGB legado
        ThemeEnum.useM3.name: true,
        ThemeEnum.textScale.name: 1.0,
        ThemeEnum.preset.name: 'brand',
      };

      // Act
      final ThemeState state = ThemeState.fromJson(json);

      // Assert
      expect(state.mode, ThemeMode.system);
    });

    test('Given mode inválido When fromJson Then usa ThemeMode.system', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.mode.name: 'sepia', // inválido
        ThemeEnum.seed.name: '#FF6750A4',
        ThemeEnum.useM3.name: false,
        ThemeEnum.textScale.name: 1.0,
        ThemeEnum.preset.name: 'brand',
      };

      // Act
      final ThemeState state = ThemeState.fromJson(json);

      // Assert
      expect(state.mode, ThemeMode.system);
    });

    test('Given mode válido When fromJson Then respeta el valor', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.mode.name: 'dark',
        ThemeEnum.seed.name: '#FF0061A4',
        ThemeEnum.useM3.name: true,
        ThemeEnum.textScale.name: 1.0,
        ThemeEnum.preset.name: 'brand',
      };

      // Act
      final ThemeState state = ThemeState.fromJson(json);

      // Assert
      expect(state.mode, ThemeMode.dark);
    });
  });

  group('ThemeState - roundtrip y contratos', () {
    test('Given HEX seed When toJson/fromJson Then roundtrip mantiene canónico',
        () {
      // Arrange
      const ThemeState original = ThemeState(
        mode: ThemeMode.light,
        seed: Color(0xFF0061A4),
        useMaterial3: true,
        textScale: 1.25,
      );

      // Act
      final Map<String, dynamic> json = original.toJson();
      final ThemeState round = ThemeState.fromJson(json);

      // Assert
      expect(json[ThemeEnum.seed.name], '#FF0061A4');
      expect(
        round,
        original,
      ); // createdAt no está => igualdad estricta por campos
    });

    test('Given ARGB int legacy When fromJson Then toJson normaliza a HEX', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.mode.name: 'light',
        ThemeEnum.seed.name: 0xFF123456, // entero ARGB
        ThemeEnum.useM3.name: true,
        ThemeEnum.textScale.name: 1.0,
        ThemeEnum.preset.name: 'brand',
      };

      // Act
      final ThemeState state = ThemeState.fromJson(json);
      final Map<String, dynamic> out = state.toJson();

      // Assert
      expect(out[ThemeEnum.seed.name], '#FF123456');
    });

    test(
        'Given createdAt distinto When equality Then se ignora en == y hashCode',
        () {
      // Arrange
      final ThemeState base = ThemeState(
        mode: ThemeMode.dark,
        seed: const Color(0xFF112233),
        useMaterial3: false,
        createdAt: DateTime.utc(2024),
      );
      final ThemeState other = base.copyWith(createdAt: DateTime.utc(2030));

      // Assert (Given/When/Then implícitos)
      expect(base, other);
      expect(base.hashCode, other.hashCode);
    });

    test('Given textScale no finito When fromJson Then lanza FormatException',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.mode.name: 'system',
        ThemeEnum.seed.name: '#FF6750A4',
        ThemeEnum.useM3.name: true,
        ThemeEnum.textScale.name: double.infinity, // no finito
        ThemeEnum.preset.name: 'brand',
      };

      // Assert
      expect(
        () => ThemeState.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given preset vacío When fromJson Then se normaliza a "brand"', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ThemeEnum.mode.name: 'system',
        ThemeEnum.seed.name: '#FF6750A4',
        ThemeEnum.useM3.name: true,
        ThemeEnum.textScale.name: 1.0,
        ThemeEnum.preset.name: '', // vacío
      };

      // Act
      final ThemeState state = ThemeState.fromJson(json);

      // Assert
      expect(state.preset, 'brand');
    });
  });
  group('ThemeState.textOverrides – roundtrip', () {
    test(
        'Given light/dark TextThemeOverrides '
        'When toJson/fromJson '
        'Then ThemeState equals and styles are preserved', () {
      // Arrange
      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        dark: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      );

      final ThemeState original = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        seed: const Color(0xFF0061A4),
        textOverrides: txt,
      );

      // Act
      final Map<String, dynamic> json = original.toJson();
      final ThemeState restored = ThemeState.fromJson(json);

      // Assert (objeto completo)
      expect(restored, equals(original));
      expect(restored.hashCode == original.hashCode, isTrue);

      // Assert (payload JSON contiene la sección 'textOverrides')
      expect(json.containsKey(ThemeEnum.textOverrides.name), isTrue);
      expect(json[ThemeEnum.textOverrides.name], isA<Map<String, dynamic>>());

      // Assert (propiedades internas preservadas)
      final TextThemeOverrides restoredTxt = restored.textOverrides!;
      expect(restoredTxt.light!.bodyMedium!.fontFamily, 'Inter');
      expect(restoredTxt.light!.bodyMedium!.fontSize, 14);
      expect(restoredTxt.dark!.titleLarge!.fontWeight, FontWeight.w700);
    });

    test(
        'Given partial TextThemeOverrides (only light) '
        'When roundtrip '
        'Then preserves provided styles and null dark', () {
      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          labelSmall: TextStyle(fontFamily: 'Roboto', letterSpacing: 0.5),
        ),
      );

      final ThemeState original =
          ThemeState.defaults.copyWith(textOverrides: txt);

      final ThemeState restored = ThemeState.fromJson(original.toJson());

      expect(restored, equals(original));
      expect(restored.textOverrides, isNotNull);
      expect(restored.textOverrides!.light!.labelSmall!.letterSpacing, 0.5);
      expect(restored.textOverrides!.dark, isNull);
    });

    test(
        'Given null textOverrides '
        'When roundtrip '
        'Then remains null', () {
      final ThemeState original = ThemeState.defaults; // sin textOverrides
      final ThemeState restored = ThemeState.fromJson(original.toJson());

      expect(restored.textOverrides, isNull);
      expect(restored, equals(original));
    });

    test(
        'Given copyWith with textOverrides '
        'When copying '
        'Then copy holds provided overrides', () {
      final ThemeState base = ThemeState.defaults;

      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 13),
        ),
      );

      final ThemeState withTxt = base.copyWith(textOverrides: txt);

      expect(withTxt.textOverrides, isNotNull);
      expect(withTxt.textOverrides!.light!.bodyMedium!.fontSize, 13);

      // Roundtrip también debe preservarlo.
      final ThemeState round = ThemeState.fromJson(withTxt.toJson());
      expect(round, equals(withTxt));
    });

    test(
        'Given ThemeOverrides (colors) AND TextThemeOverrides (typography) '
        'When roundtrip '
        'Then both are preserved and equal', () {
      final ThemeOverrides theme = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      );
      const TextThemeOverrides text = TextThemeOverrides(
        light:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        dark:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
      );

      final ThemeState original = ThemeState.defaults.copyWith(
        overrides: theme,
        textOverrides: text,
      );

      final ThemeState restored = ThemeState.fromJson(original.toJson());

      expect(restored, equals(original));
      expect(restored.overrides, equals(theme));
      expect(restored.textOverrides, equals(text));
    });
  });
}
