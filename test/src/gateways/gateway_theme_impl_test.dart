import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --- Fakes auxiliares ---

/// Service que siempre lanza al construir ThemeData para forzar el mapeo de errores.
class _ThrowingServiceTheme extends ServiceTheme {
  const _ThrowingServiceTheme();

  @override
  ColorScheme schemeFromSeed(Color seed, Brightness b) =>
      ColorScheme.fromSeed(seedColor: seed, brightness: b);

  @override
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  }) {
    throw StateError('boom-toThemeData');
  }

  @override
  ThemeData lightTheme(ThemeState state) {
    throw StateError('boom-light');
  }

  @override
  ThemeData darkTheme(ThemeState state) {
    throw StateError('boom-dark');
  }
}

void main() {
  group('GatewayThemeImpl · read()', () {
    test('sin documento inicial → Left(ERR_NOT_FOUND) y location=read',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();
      final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();

      r.when(
        (ErrorItem e) {
          expect(e.code, 'ERR_NOT_FOUND');
          expect(e.meta['location'], 'GatewayThemeImpl.read');
        },
        (_) => fail('Debió fallar con ERR_NOT_FOUND'),
      );
    });

    test('con documento inicial → Right(normalizado) + smoke-test OK',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        initial: <String, dynamic>{
          'mode': 'light',
          'seed': 0xFF123456,
          // useM3 omitido -> debe quedar true por normalización
          'textScale': 1.5,
          'preset': 'brandX',
        },
      );

      final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();

      r.when(
        (_) => fail('Se esperaba Right (map)'),
        (Map<String, dynamic> json) {
          expect(json['mode'], 'light');
          expect(json['seed'], 0xFF123456);
          expect(json['useM3'], isTrue);
          expect(json['textScale'], closeTo(1.5, 1e-9));
          expect(json['preset'], 'brandX');
        },
      );
    });

    test('con ServiceTheme que lanza → Left(error mapeado) y location=read',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        themeService: const _ThrowingServiceTheme(),
        initial: <String, dynamic>{
          'mode': 'system',
          'seed': 0xFF112233,
          'useM3': true,
          'textScale': 1.0,
          'preset': 'brand',
        },
      );

      final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();

      r.when(
        (ErrorItem e) {
          // No acoplamos a título/código del mapper por si cambian;
          // validamos que mapee y etiquete la ubicación.
          expect(e.code.isNotEmpty, isTrue);
          expect(e.meta['location'], 'GatewayThemeImpl.read');
        },
        (_) => fail('Debió fallar por _smokeTest (ServiceTheme lanza)'),
      );
    });
  });

  group('GatewayThemeImpl · write()', () {
    test(
        'normaliza payload: mode inválido, seed raro, useM3 omitido, clamp textScale',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

      final Either<ErrorItem, Map<String, dynamic>> r = await gw.write(
        <String, dynamic>{
          'mode': 'weird', // → system
          'seed': 'oops', // → default 0xFF6750A4
          // 'useM3' omitido        // → true
          'textScale': 3.2, // → 1.6 (clamp)
          // 'preset' omitido       // → 'brand'
        },
      );

      r.when(
        (_) => fail('Se esperaba Right (map normalizado)'),
        (Map<String, dynamic> json) {
          expect(json['mode'], 'system');
          expect(json['seed'], 0xFF6750A4);
          expect(json['useM3'], isTrue);
          expect(json['textScale'], closeTo(1.6, 1e-9));
          expect(json['preset'], 'brand');
        },
      );
    });

    test('respeta useM3=false si llega explícito', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

      final Either<ErrorItem, Map<String, dynamic>> r = await gw.write(
        <String, dynamic>{
          'mode': 'dark',
          'seed': 0xFF445566,
          'useM3': false,
          'textScale': 1.1,
          'preset': 'brandY',
        },
      );

      r.when(
        (_) => fail('Se esperaba Right'),
        (Map<String, dynamic> json) {
          expect(json['mode'], 'dark');
          expect(json['seed'], 0xFF445566);
          expect(json['useM3'], isFalse);
          expect(json['textScale'], closeTo(1.1, 1e-9));
          expect(json['preset'], 'brandY');
        },
      );
    });

    test('ServiceTheme que lanza durante smoke-test → Left(location=write)',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        themeService: const _ThrowingServiceTheme(),
      );

      final Either<ErrorItem, Map<String, dynamic>> r = await gw.write(
        <String, dynamic>{
          'mode': 'light',
          'seed': 0xFF010203,
          'useM3': true,
          'textScale': 1.0,
          'preset': 'brand',
        },
      );

      r.when(
        (ErrorItem e) {
          expect(e.code.isNotEmpty, isTrue);
          expect(e.meta['location'], 'GatewayThemeImpl.write');
        },
        (_) => fail('Debió fallar por _smokeTest (ServiceTheme lanza)'),
      );
    });

    test('write → read roundtrip mantiene normalización (idempotente)',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

      final Map<String, dynamic> input = <String, dynamic>{
        'mode': 'system',
        'seed': 0xFF0A0B0C,
        // omitimos useM3 → true
        'textScale': 0.1, // clamp a 0.8
        // omitimos preset → brand
      };

      final Either<ErrorItem, Map<String, dynamic>> w = await gw.write(input);
      w.when(
        (_) => fail('Se esperaba Right'),
        (Map<String, dynamic> jsonW) async {
          // Chequeo de normalización de write
          expect(jsonW['useM3'], isTrue);
          expect(jsonW['textScale'], closeTo(0.8, 1e-9));
          expect(jsonW['preset'], 'brand');

          // read posterior devuelve el mismo documento normalizado
          final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();
          r.when(
            (_) => fail('Se esperaba Right'),
            (Map<String, dynamic> jsonR) {
              expect(jsonR, jsonW);
            },
          );
        },
      );
    });
    test('GatewayThemeImpl.write preserva overrides', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();
      final RepositoryThemeImpl repo = RepositoryThemeImpl(gateway: gw);

      final ThemeOverrides overrides = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFFAA5500)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA5500),
          brightness: Brightness.dark,
        ),
      );

      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        textScale: 1.15,
        preset: 'designer',
        overrides: overrides,
      );

      final Either<ErrorItem, ThemeState> saved = await repo.save(s);
      saved.when(
        (_) => fail('No debía fallar'),
        (ThemeState out) {
          expect(out.overrides, isNotNull);
          expect(out.overrides!.light!.brightness, Brightness.light);
          expect(out.overrides!.dark!.brightness, Brightness.dark);
        },
      );

      final Either<ErrorItem, ThemeState> loaded = await repo.read();
      loaded.when(
        (_) => fail('No debía fallar'),
        (ThemeState out) => expect(out.overrides, isNotNull),
      );
    });
    test('GatewayThemeImpl.normalize accepts HEX and Color for seed', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );

      // Escribe HEX
      final Either<ErrorItem, Map<String, dynamic>> r1 =
          await gw.write(<String, dynamic>{
        'mode': 'light',
        'seed': '#FF0A1B2C',
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
      });
      r1.when(
        (ErrorItem e) => fail('write HEX failed: $e'),
        (Map<String, dynamic> json) =>
            expect(json['seed'], isA<int>()), // gateway persiste como int
      );

      // Lee y valida que ThemeState conserve el color correcto
      final Either<ErrorItem, Map<String, dynamic>> r2 = await gw.read();
      r2.when(
        (ErrorItem e) => fail('read failed: $e'),
        (Map<String, dynamic> json) {
          final ThemeState s = ThemeState.fromJson(json);
          expect(s.seed, const Color(0xFF0A1B2C));
        },
      );
    });
  });
  group('GatewayThemeImpl · textOverrides (TextTheme)', () {
    test('write acepta instancia directa de ThemeOverrides (branch toJson)',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

      final ThemeOverrides ov = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFFAA5500)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA5500),
          brightness: Brightness.dark,
        ),
      );

      // Pasa la INSTANCIA directa, no el mapa.
      final Either<ErrorItem, Map<String, dynamic>> w =
          await gw.write(<String, dynamic>{
        'mode': 'light',
        'seed': 0xFF334455,
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
        'overrides': ov, // <-- dispara overrides = rawOverrides.toJson();
      });

      w.when(
        (_) => fail('Se esperaba Right (map normalizado)'),
        (Map<String, dynamic> jsonW) async {
          // El gateway debe haber normalizado a MAP
          expect(jsonW.containsKey('overrides'), isTrue);
          expect(jsonW['overrides'], isA<Map<String, dynamic>>());

          // Roundtrip con ThemeState para validar estructura canónica
          final ThemeState s = ThemeState.fromJson(jsonW);
          expect(s.overrides, isNotNull);
          expect(s.overrides!.light!.brightness, Brightness.light);
          expect(s.overrides!.dark!.brightness, Brightness.dark);

          // Adicional: volver a leer del gateway y comprobar equivalencia
          final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();
          r.when(
            (ErrorItem e) => fail('read falló: $e'),
            (Map<String, dynamic> jsonR) {
              expect(jsonR['overrides'], isA<Map<String, dynamic>>());
              final ThemeOverrides restored = ThemeOverrides.fromJson(
                Utils.mapFromDynamic(jsonR['overrides']),
              )!;
              expect(restored, equals(ov));
            },
          );
        },
      );
    });

    test('write con textOverrides (MAP) → normaliza y preserva en read',
        () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

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

      final Either<ErrorItem, Map<String, dynamic>> w =
          await gw.write(<String, dynamic>{
        'mode': 'dark',
        'seed': 0xFF112233,
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
        'textOverrides': txt.toJson(), // <-- como mapa
      });

      w.when(
        (_) => fail('Se esperaba Right (map normalizado)'),
        (Map<String, dynamic> jsonW) async {
          // Gateway debe devolver sección textOverrides
          expect(jsonW.containsKey('textOverrides'), isTrue);
          expect(jsonW['textOverrides'], isA<Map<String, dynamic>>());

          // read posterior preserva el contenido
          final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();
          r.when(
            (_) => fail('Se esperaba Right'),
            (Map<String, dynamic> jsonR) {
              final ThemeState s = ThemeState.fromJson(jsonR);
              expect(s.mode, ThemeMode.dark);
              expect(s.textOverrides, isNotNull);
              expect(s.textOverrides!.light!.bodyMedium!.fontFamily, 'Inter');
              expect(
                s.textOverrides!.dark!.titleLarge!.fontWeight,
                FontWeight.w700,
              );
            },
          );
        },
      );
    });

    test('write acepta instancia directa de TextThemeOverrides', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          labelSmall: TextStyle(letterSpacing: 0.75),
        ),
      );

      final Either<ErrorItem, Map<String, dynamic>> w =
          await gw.write(<String, dynamic>{
        'mode': 'system',
        'seed': const Color(0xFF6750A4), // también acepta Color
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
        'textOverrides': txt, // <-- instancia directa
      });

      w.when(
        (_) => fail('Se esperaba Right (map normalizado)'),
        (Map<String, dynamic> jsonW) async {
          // La normalización conserva textOverrides
          final ThemeState s = ThemeState.fromJson(jsonW);
          expect(s.textOverrides, isNotNull);
          expect(s.textOverrides!.light!.labelSmall!.letterSpacing, 0.75);
          // dark no se envió → debe permanecer null
          expect(s.textOverrides!.dark, isNull);
        },
      );
    });

    test('read con initial que incluye textOverrides → Right(normalizado)',
        () async {
      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 13),
        ),
        dark: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 13),
        ),
      );

      final GatewayThemeImpl gw = GatewayThemeImpl(
        initial: <String, dynamic>{
          'mode': 'light',
          'seed': '#FF778899',
          'useM3': true,
          'textScale': 1.1,
          'preset': 'brand',
          'textOverrides': txt.toJson(), // initial como mapa válido
        },
      );

      final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();
      r.when(
        (ErrorItem e) => fail('No debía fallar, error: $e'),
        (Map<String, dynamic> json) {
          expect(json['mode'], 'light');
          expect(json.containsKey('textOverrides'), isTrue);

          final ThemeState s = ThemeState.fromJson(json);
          expect(s.textOverrides, isNotNull);
          expect(s.textOverrides!.light!.bodyMedium!.fontFamily, 'Roboto');
          expect(s.textOverrides!.dark!.bodyMedium!.fontSize, 13);
        },
      );
    });

    test('roundtrip parcial (solo light) preserva null en dark', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();

      const TextThemeOverrides partial = TextThemeOverrides(
        light: TextTheme(
          titleSmall: TextStyle(fontFamily: 'SpaceGrotesk', height: 1.1),
        ),
      );

      final Either<ErrorItem, Map<String, dynamic>> w =
          await gw.write(<String, dynamic>{
        'mode': 'dark',
        'seed': 0xFF0A1B2C,
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
        'textOverrides': partial.toJson(),
      });

      w.when(
        (_) => fail('Se esperaba Right'),
        (Map<String, dynamic> jsonW) async {
          final Either<ErrorItem, Map<String, dynamic>> r = await gw.read();
          r.when(
            (_) => fail('Se esperaba Right'),
            (Map<String, dynamic> jsonR) {
              final ThemeState s = ThemeState.fromJson(jsonR);
              expect(s.textOverrides, isNotNull);
              expect(
                s.textOverrides!.light!.titleSmall!.fontFamily,
                'SpaceGrotesk',
              );
              expect(s.textOverrides!.dark, isNull); // <-- preserva null
            },
          );
        },
      );
    });

    test('RepositoryThemeImpl.save/read mantiene textOverrides', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl();
      final RepositoryThemeImpl repo = RepositoryThemeImpl(gateway: gw);

      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16),
        ),
        dark: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, height: 1.3),
        ),
      );

      final ThemeState s = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        textScale: 1.05,
        preset: 'designer',
        textOverrides: txt,
      );

      final Either<ErrorItem, ThemeState> saved = await repo.save(s);
      saved.when(
        (_) => fail('No debía fallar al guardar'),
        (ThemeState out) {
          expect(out.textOverrides, equals(txt));
        },
      );

      final Either<ErrorItem, ThemeState> loaded = await repo.read();
      loaded.when(
        (_) => fail('No debía fallar al leer'),
        (ThemeState out) {
          expect(out.textOverrides, isNotNull);
          expect(out.textOverrides!.dark!.bodyLarge!.height, 1.3);
        },
      );
    });
  });
}
