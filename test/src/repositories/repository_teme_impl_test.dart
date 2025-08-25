import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------------
/// Fakes / Stubs helpers
/// ----------------------

class _GwNotFound implements GatewayTheme {
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'not-found',
          code: 'ERR_NOT_FOUND',
          description: 'not-found',
        ),
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'write-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );
}

class _GwReadRight implements GatewayTheme {
  _GwReadRight(this.payload);
  final Map<String, dynamic> payload;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Right<ErrorItem, Map<String, dynamic>>(payload);

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'write-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );
}

class _GwReadLeft implements GatewayTheme {
  _GwReadLeft(this.errCode);
  final String errCode;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(
        ErrorItem(
          title: 'boom',
          code: errCode,
          description: 'boom',
        ),
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'write-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );
}

class _GwThrowOnRead implements GatewayTheme {
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async {
    throw StateError('kaboom-read');
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'write-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );
}

class _GwWriteEcho implements GatewayTheme {
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'read-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async =>
      Right<ErrorItem, Map<String, dynamic>>(Map<String, dynamic>.from(json));
}

class _GwWriteLeft implements GatewayTheme {
  _GwWriteLeft(this.errCode);
  final String errCode;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'read-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async =>
      Left<ErrorItem, Map<String, dynamic>>(
        ErrorItem(
          title: 'boom-write',
          code: errCode,
          description: 'boom-write',
        ),
      );
}

class _GwThrowOnWrite implements GatewayTheme {
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'read-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async {
    throw ArgumentError('kaboom-write');
  }
}

/// ErrorMapper fake:
/// - fromException => ErrorItem code 'mapped-ex' y meta.location
/// - fromPayload => si payload['__bizError'] == true, devuelve ErrorItem
class _FakeMapper extends ErrorMapper {
  @override
  ErrorItem fromException(Object e, StackTrace s, {String? location}) {
    return ErrorItem(
      title: 'mapped-ex',
      code: 'mapped-ex',
      description: e.toString(),
      meta: <String, dynamic>{'location': location ?? ''},
    );
  }

  @override
  ErrorItem? fromPayload(Map<String, dynamic> payload, {String? location}) {
    final bool isBiz = payload['__bizError'] == true;
    if (isBiz) {
      return ErrorItem(
        title: 'biz-error',
        code: 'BIZ',
        description: 'payload says business error',
        meta: <String, dynamic>{'location': location ?? ''},
      );
    }
    return null;
  }
}

void main() {
  group('RepositoryThemeImpl.read()', () {
    test('ERR_NOT_FOUND => retorna ThemeState.defaults (éxito)', () async {
      final RepositoryTheme repo = RepositoryThemeImpl(
        gateway: _GwNotFound(),
        errorMapper: _FakeMapper(),
      );

      final Either<ErrorItem, ThemeState> r = await repo.read();
      r.when(
            (ErrorItem e) => fail('Debió ser éxito con defaults, obtuvo Left: $e'),
            (ThemeState s) {
          expect(s, ThemeState.defaults);
        },
      );
    });

    test('Left con otro código => propaga error (meta.location = RepositoryTheme.read)',
            () async {
          final RepositoryTheme repo = RepositoryThemeImpl(
            gateway: _GwReadLeft('ANY'),
            errorMapper: _FakeMapper(),
          );

          final Either<ErrorItem, ThemeState> r = await repo.read();
          r.when(
                (ErrorItem e) {
              expect(e.code, 'ANY');
              expect(e.meta['location'], 'RepositoryTheme.read');
            },
                (ThemeState _) => fail('Debió fallar'),
          );
        });

    test('Right payload válido => mapea a ThemeState', () async {
      final Map<String, dynamic> payload = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        useMaterial3: false,
        textScale: 1.25,
        seed: const Color(0xFF112233),
        preset: 'brandX',
      ).toJson();

      final RepositoryTheme repo = RepositoryThemeImpl(
        gateway: _GwReadRight(payload),
        errorMapper: _FakeMapper(),
      );

      final Either<ErrorItem, ThemeState> r = await repo.read();
      r.when(
            (ErrorItem _) => fail('No debía fallar'),
            (ThemeState s) {
          expect(s.mode, ThemeMode.dark);
          expect(s.useMaterial3, false);
          expect(s.textScale, 1.25);
          expect(s.seed.toARGB32(), 0xFF112233);
          expect(s.preset, 'brandX');
        },
      );
    });

    test('Right payload con error de negocio => Left(BIZ)', () async {
      final Map<String, dynamic> payload = <String, dynamic>{
        ...ThemeState.defaults.toJson(),
        '__bizError': true,
      };

      final RepositoryTheme repo = RepositoryThemeImpl(
        gateway: _GwReadRight(payload),
        errorMapper: _FakeMapper(),
      );

      final Either<ErrorItem, ThemeState> r = await repo.read();
      r.when(
            (ErrorItem e) {
          expect(e.code, 'BIZ');
          expect(e.meta['location'], 'RepositoryTheme.read');
        },
            (ThemeState _) => fail('Debió ser Left por error de negocio'),
      );
    });

    test('Excepción del gateway => mapea with fromException (code mapped-ex, location RepositoryTheme.read)',
            () async {
          final RepositoryTheme repo = RepositoryThemeImpl(
            gateway: _GwThrowOnRead(),
            errorMapper: _FakeMapper(),
          );

          final Either<ErrorItem, ThemeState> r = await repo.read();
          r.when(
                (ErrorItem e) {
              expect(e.code, 'mapped-ex');
              expect(e.meta['location'], 'RepositoryTheme.read');
            },
                (ThemeState _) => fail('Debió ser Left por excepción'),
          );
        });
  });

  group('RepositoryThemeImpl.save()', () {
    test('Right echo => retorna ThemeState del payload', () async {
      final RepositoryTheme repo = RepositoryThemeImpl(
        gateway: _GwWriteEcho(),
        errorMapper: _FakeMapper(),
      );

      final ThemeState next = ThemeState.defaults.copyWith(
        mode: ThemeMode.light,
        seed: const Color(0xFF445566),
        useMaterial3: true,
        textScale: 1.1,
        preset: 'designer',
      );

      final Either<ErrorItem, ThemeState> r = await repo.save(next);
      r.when(
            (ErrorItem _) => fail('No debía fallar'),
            (ThemeState s) {
          expect(s.mode, ThemeMode.light);
          expect(s.seed.toARGB32(), 0xFF445566);
          expect(s.useMaterial3, isTrue);
          expect(s.textScale, 1.1);
          expect(s.preset, 'designer');
        },
      );
    });

    test('Left del gateway => propaga con meta.location=RepositoryTheme.save',
            () async {
          final RepositoryTheme repo = RepositoryThemeImpl(
            gateway: _GwWriteLeft('FAIL_WRITE'),
            errorMapper: _FakeMapper(),
          );

          final Either<ErrorItem, ThemeState> r =
          await repo.save(ThemeState.defaults);
          r.when(
                (ErrorItem e) {
              expect(e.code, 'FAIL_WRITE');
              expect(e.meta['location'], 'RepositoryTheme.save');
            },
                (ThemeState _) => fail('Debió fallar'),
          );
        });

    test('Right payload con error de negocio => Left(BIZ)', () async {
      final GatewayTheme gw = _GwWriteEcho();

      // Forzamos que el gateway "devuelva" un payload con bandera de negocio:
      // Como _GwWriteEcho retorna exactamente lo que enviamos, enviamos la bandera
      const ThemeState next = ThemeState.defaults;
      final Map<String, dynamic> json = <String, dynamic>{
        ...next.toJson(),
        '__bizError': true,
      };

      // Llamamos al gateway directo para simular write(payload con bandera)
      final Either<ErrorItem, Map<String, dynamic>> raw =
      await gw.write(json);
      expect(raw.isRight, isTrue);

      // Ahora pasamos por el repo.save (que construye su propio json desde ThemeState)
      // Para asegurarnos del caso de negocio dentro del repo, creamos un pequeño
      // proxy del gateway que siempre responde Right con bizError.
      final RepositoryTheme repoBiz = RepositoryThemeImpl(
        gateway: _GwWriteAlwaysBiz(),
        errorMapper: _FakeMapper(),
      );

      final Either<ErrorItem, ThemeState> r = await repoBiz.save(next);
      r.when(
            (ErrorItem e) {
          expect(e.code, 'BIZ');
          expect(e.meta['location'], 'RepositoryTheme.save');
        },
            (ThemeState _) => fail('Debió ser Left por error de negocio'),
      );
    });

    test('Excepción del gateway => mapeada via fromException (mapped-ex, RepositoryTheme.save)',
            () async {
          final RepositoryTheme repo = RepositoryThemeImpl(
            gateway: _GwThrowOnWrite(),
            errorMapper: _FakeMapper(),
          );

          final Either<ErrorItem, ThemeState> r =
          await repo.save(ThemeState.defaults);
          r.when(
                (ErrorItem e) {
              expect(e.code, 'mapped-ex');
              expect(e.meta['location'], 'RepositoryTheme.save');
            },
                (ThemeState _) => fail('Debió ser Left por excepción'),
          );
        });
  });
}

/// Gateway que siempre devuelve Right con bandera de negocio para test de save()
class _GwWriteAlwaysBiz implements GatewayTheme {
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          title: 'read-unreachable',
          code: 'UNUSED',
          description: 'UNUSED',
        ),
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
      Map<String, dynamic> json,) async {
    return Right<ErrorItem, Map<String, dynamic>>(<String, dynamic>{
      ...json,
      '__bizError': true, // disparará fromPayload() en el mapper
    });
  }
}
