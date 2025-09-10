import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --------- Gateways de prueba para forzar errores ---------

/// Falla en read() con un error distinto a ERR_NOT_FOUND (debe propagarse como Left).
class FailingReadGateway implements GatewayTheme {
  const FailingReadGateway({this.code = 'ERR_IO'});
  final String code;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async {
    return Left<ErrorItem, Map<String, dynamic>>(
      ErrorItem(
        title: 'Read failed',
        code: code,
        description: 'Injected read failure',
        meta: const <String, dynamic>{'location': 'FailingReadGateway.read'},
      ),
    );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  ) async {
    // No se usa en estas pruebas.
    return Right<ErrorItem, Map<String, dynamic>>(json);
  }
}

/// Falla en write() (RepositoryTheme.save debe propagar Left con location mapeada).
class FailingWriteGateway implements GatewayTheme {
  const FailingWriteGateway();

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async {
    // Devuelve algo válido para permitir la ruta de update -> save.
    return Right<ErrorItem, Map<String, dynamic>>(
      ThemeState.defaults.toJson(),
    );
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  ) async {
    return Left<ErrorItem, Map<String, dynamic>>(
      const ErrorItem(
        title: 'Write failed',
        code: 'ERR_WRITE',
        description: 'Injected write failure',
        meta: <String, dynamic>{'location': 'FailingWriteGateway.write'},
      ),
    );
  }
}

void main() {
  group(
      'ThemeUsecases - integración feliz con RepositoryThemeImpl/GatewayThemeImpl',
      () {
    late GatewayThemeImpl gateway;
    late RepositoryThemeImpl repository;
    const FakeServiceJocaaguraArchetypeTheme fakeService =
        FakeServiceJocaaguraArchetypeTheme();
    late ThemeUsecases usecases;

    setUp(() {
      // Sin estado inicial => Gateway.read() responderá ERR_NOT_FOUND.
      gateway = GatewayThemeImpl(themeService: fakeService);
      repository = RepositoryThemeImpl(gateway: gateway);
      usecases = ThemeUsecases.fromRepo(repository);
    });

    test(
        'Given no persisted theme When load Then returns defaults (ERR_NOT_FOUND → defaults)',
        () async {
      // Act
      final Either<ErrorItem, ThemeState> r = await usecases.load();

      // Assert
      r.when(
        (ErrorItem e) => fail('Expected Right(defaults) but got Left: $e'),
        (ThemeState s) => expect(s, ThemeState.defaults),
      );
    });

    test('Given setMode(dark) When load Then persisted mode is dark', () async {
      // Act
      final Either<ErrorItem, ThemeState> r1 =
          await usecases.setMode(ThemeMode.dark);
      final Either<ErrorItem, ThemeState> r2 = await usecases.load();

      // Assert
      r1.when(
        (ErrorItem e) => fail('setMode failed: $e'),
        (ThemeState s) => expect(s.mode, ThemeMode.dark),
      );
      r2.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) => expect(s.mode, ThemeMode.dark),
      );
    });

    test('Given setSeed(color) When load Then persisted seed matches',
        () async {
      const Color next = Color(0xFF123456);

      final Either<ErrorItem, ThemeState> r1 = await usecases.setSeed(next);
      final Either<ErrorItem, ThemeState> r2 = await usecases.load();

      r1.when(
        (ErrorItem e) => fail('setSeed failed: $e'),
        (ThemeState s) => expect(s.seed, next),
      );
      r2.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) => expect(s.seed, next),
      );
    });

    test('Given toggleM3 When load Then useMaterial3 is flipped', () async {
      // defaults.useMaterial3 == true
      final Either<ErrorItem, ThemeState> r1 = await usecases.toggleM3();
      final Either<ErrorItem, ThemeState> r2 = await usecases.load();

      r1.when(
        (ErrorItem e) => fail('toggleM3 failed: $e'),
        (ThemeState s) => expect(s.useMaterial3, isFalse),
      );
      r2.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) => expect(s.useMaterial3, isFalse),
      );
    });

    test(
        'Given setTextScale out of bounds When load Then value is clamped [0.8, 1.6]',
        () async {
      // 1) por debajo (0.5 -> 0.8)
      final Either<ErrorItem, ThemeState> r1 = await usecases.setTextScale(0.5);
      r1.when(
        (ErrorItem e) => fail('setTextScale failed: $e'),
        (ThemeState s) => expect(s.textScale, 0.8),
      );

      // 2) por encima (1.8 -> 1.6)
      final Either<ErrorItem, ThemeState> r2 = await usecases.setTextScale(1.8);
      r2.when(
        (ErrorItem e) => fail('setTextScale failed: $e'),
        (ThemeState s) => expect(s.textScale, 1.6),
      );

      // 3) dentro de rango (1.2 -> 1.2)
      final Either<ErrorItem, ThemeState> r3 = await usecases.setTextScale(1.2);
      r3.when(
        (ErrorItem e) => fail('setTextScale failed: $e'),
        (ThemeState s) => expect(s.textScale, 1.2),
      );

      // Verificación persistida tras el último cambio
      final Either<ErrorItem, ThemeState> r4 = await usecases.load();
      r4.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) => expect(s.textScale, 1.2),
      );
    });

    test('Given applyPreset("brand-2") When load Then preset is persisted',
        () async {
      final Either<ErrorItem, ThemeState> r1 =
          await usecases.applyPreset('brand-2');
      final Either<ErrorItem, ThemeState> r2 = await usecases.load();

      r1.when(
        (ErrorItem e) => fail('applyPreset failed: $e'),
        (ThemeState s) => expect(s.preset, 'brand-2'),
      );
      r2.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) => expect(s.preset, 'brand-2'),
      );
    });

    test(
        'Given randomize() with FakeService When load Then seed is deterministic and preset=random',
        () async {
      final Either<ErrorItem, ThemeState> r1 = await usecases.randomize();
      final Either<ErrorItem, ThemeState> r2 = await usecases.load();

      r1.when(
        (ErrorItem e) => fail('randomize failed: $e'),
        (ThemeState s) {
          expect(
            s.seed,
            const Color(0xFF0066CC),
          ); // determinista por FakeService
          expect(s.preset, 'random');
        },
      );
      r2.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) {
          expect(s.seed, const Color(0xFF0066CC));
          expect(s.preset, 'random');
        },
      );
    });

    test(
        'Given modified state When reset() Then ThemeState.defaults is restored',
        () async {
      await usecases.setMode(ThemeMode.dark);
      await usecases.setSeed(const Color(0xFF00AA00));
      await usecases.applyPreset('alt');
      await usecases.toggleM3();

      final Either<ErrorItem, ThemeState> rReset = await usecases.reset();
      final Either<ErrorItem, ThemeState> rLoad = await usecases.load();

      rReset.when(
        (ErrorItem e) => fail('reset failed: $e'),
        (ThemeState s) => expect(s, ThemeState.defaults),
      );
      rLoad.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) => expect(s, ThemeState.defaults),
      );
    });
  });

  group('ThemeUsecases - propagación de errores', () {
    test(
        'Given read() returns Left(ERR_IO) When load Then returns Left with location RepositoryTheme.read',
        () async {
      final RepositoryThemeImpl repo = RepositoryThemeImpl(
        gateway: const FailingReadGateway(),
      );

      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
      );

      final Either<ErrorItem, ThemeState> r = await uc.load();

      r.when(
        (ErrorItem e) {
          expect(e.code, 'ERR_IO');
          // RepositoryThemeImpl añade location en meta
          expect(e.meta['location'], 'RepositoryTheme.read');
        },
        (ThemeState _) => fail('Expected Left but got Right'),
      );
    });

    test(
        'Given write() returns Left(ERR_WRITE) When setMode Then returns Left with location RepositoryTheme.save',
        () async {
      final RepositoryThemeImpl repo =
          RepositoryThemeImpl(gateway: const FailingWriteGateway());

      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
      );

      final Either<ErrorItem, ThemeState> r = await uc.setMode(ThemeMode.dark);

      r.when(
        (ErrorItem e) {
          expect(e.code, 'ERR_WRITE');
          expect(e.meta['location'], 'RepositoryTheme.save');
        },
        (ThemeState _) => fail('Expected Left but got Right'),
      );
    });
  });

  group('ThemeUsecases - canonicidad de color (sanity)', () {
    test('Given setSeed Then toJson emits HEX #AARRGGBB', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );
      final RepositoryThemeImpl repo = RepositoryThemeImpl(gateway: gw);
      final ThemeUsecases uc = ThemeUsecases.fromRepo(repo);

      await uc.setSeed(const Color(0xFF0A1B2C));
      final Either<ErrorItem, ThemeState> r = await uc.load();

      r.when(
        (ErrorItem e) => fail('load failed: $e'),
        (ThemeState s) {
          final Map<String, dynamic> json = s.toJson();
          expect(json['seed'], '#FF0A1B2C'); // HEX canónico
        },
      );
    });
  });
}
