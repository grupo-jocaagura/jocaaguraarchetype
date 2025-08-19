import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class _GatewayReturnsLeft implements GatewayTheme {
  _GatewayReturnsLeft(this.item);
  final ErrorItem item;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Left<ErrorItem, Map<String, dynamic>>(item);

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> _,
  ) async =>
      Left<ErrorItem, Map<String, dynamic>>(item);
}

class _GatewayReturnsPayload implements GatewayTheme {
  _GatewayReturnsPayload(this.payload);
  final Map<String, dynamic> payload;

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async =>
      Right<ErrorItem, Map<String, dynamic>>(payload);

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  ) async =>
      Right<ErrorItem, Map<String, dynamic>>(json);
}

void main() {
  group('RepositoryThemeImpl', () {
    test('read(): ERR_NOT_FOUND => Right(defaults)', () async {
      final RepositoryThemeImpl repo = RepositoryThemeImpl(
        gateway: _GatewayReturnsLeft(
          const ErrorItem(
            title: 'not found',
            code: 'ERR_NOT_FOUND',
            description: 'none',
          ),
        ),
      );

      final Either<ErrorItem, ThemeState> r = await repo.read();
      r.when(
        (_) => fail('Esperábamos Right(defaults)'),
        (ThemeState state) {
          expect(state.mode, ThemeMode.system);
          expect(state.useMaterial3, true);
          expect(state.seed, const Color(0xFF6750A4));
        },
      );
    });

    test('read(): payload con {"error": {...}} => Left(ErrorItem)', () async {
      final RepositoryThemeImpl repo = RepositoryThemeImpl(
        gateway: _GatewayReturnsPayload(<String, dynamic>{
          'error': <String, dynamic>{
            'code': 'ERR_BIZ',
            'message': 'Business error',
          },
        }),
      );

      final Either<ErrorItem, ThemeState> r = await repo.read();
      r.when(
        (ErrorItem err) {
          expect(
            err.code,
            anyOf('ERR_BIZ', 'ERR_PAYLOAD'),
          ); // mapper decide el código
        },
        (_) => fail('Debió devolver Left(ErrorItem)'),
      );
    });

    test('save(): persiste y devuelve Right(state)', () async {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );
      final RepositoryThemeImpl repo = RepositoryThemeImpl(gateway: gw);

      final ThemeState state = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        seed: const Color(0xFF00AA00),
        useMaterial3: false,
        textScale: 1.2,
        preset: 'custom',
      );

      final Either<ErrorItem, ThemeState> r = await repo.save(state);
      r.when(
        (_) => fail('save() no debe fallar'),
        (ThemeState saved) {
          expect(saved.mode, ThemeMode.dark);
          expect(saved.useMaterial3, false);
          expect(saved.textScale, 1.2);
          expect(saved.preset, 'custom');
          expect(saved.seed, const Color(0xFF00AA00));
        },
      );

      final Either<ErrorItem, ThemeState> r2 = await repo.read();
      expect(r2.isRight, true);
    });
  });
}
