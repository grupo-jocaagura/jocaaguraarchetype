import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('Theme UseCases', () {
    late RepositoryTheme repo;

    setUp(() {
      final GatewayThemeImpl gw = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );
      repo = RepositoryThemeImpl(gateway: gw);
    });

    test('LoadTheme retorna defaults en memoria vacía', () async {
      final LoadTheme uc = LoadTheme(repo);
      final Either<ErrorItem, ThemeState> r = await uc();
      r.when(
        (_) => fail('Esperábamos Right(defaults)'),
        (ThemeState s) {
          expect(s.mode, ThemeMode.system);
          expect(s.useMaterial3, true);
        },
      );
    });

    test('SetThemeMode actualiza mode', () async {
      final SetThemeMode setMode = SetThemeMode(repo);
      final Either<ErrorItem, ThemeState> r = await setMode(ThemeMode.dark);
      r.when(
        (_) => fail('Esperábamos Right'),
        (ThemeState s) => expect(s.mode, ThemeMode.dark),
      );
    });

    test('SetThemeSeed actualiza seed', () async {
      final SetThemeSeed setSeed = SetThemeSeed(repo);
      final Either<ErrorItem, ThemeState> r =
          await setSeed(const Color(0xFF123456));
      r.when(
        (_) => fail('Esperábamos Right'),
        (ThemeState s) => expect(s.seed, const Color(0xFF123456)),
      );
    });

    test('ToggleMaterial3 invierte bandera', () async {
      final ToggleMaterial3 toggle = ToggleMaterial3(repo);
      final Either<ErrorItem, ThemeState> r1 = await toggle();
      r1.when(
        (_) => fail('Right esperado'),
        (ThemeState s1) => expect(s1.useMaterial3, isFalse),
      );
      final Either<ErrorItem, ThemeState> r2 = await toggle();
      r2.when(
        (_) => fail('Right esperado'),
        (ThemeState s2) => expect(s2.useMaterial3, isTrue),
      );
    });

    test('ApplyThemePreset cambia preset', () async {
      final ApplyThemePreset apply = ApplyThemePreset(repo);
      final Either<ErrorItem, ThemeState> r = await apply('brand-x');
      r.when(
        (_) => fail('Right esperado'),
        (ThemeState s) => expect(s.preset, 'brand-x'),
      );
    });

    test('SetThemeTextScale clampa y guarda', () async {
      final SetThemeTextScale setTs = SetThemeTextScale(repo);
      final Either<ErrorItem, ThemeState> r1 = await setTs(0.5);
      r1.when(
        (_) => fail('Right esperado'),
        (ThemeState s) => expect(s.textScale, 0.8),
      );
      final Either<ErrorItem, ThemeState> r2 = await setTs(1.3);
      r2.when(
        (_) => fail('Right esperado'),
        (ThemeState s) => expect(s.textScale, 1.3),
      );
      final Either<ErrorItem, ThemeState> r3 = await setTs(3.0);
      r3.when(
        (_) => fail('Right esperado'),
        (ThemeState s) => expect(s.textScale, 1.6),
      );
    });

    test('ResetTheme vuelve a defaults', () async {
      final ResetTheme reset = ResetTheme(repo);
      final Either<ErrorItem, ThemeState> r = await reset();
      r.when(
        (_) => fail('Right esperado'),
        (ThemeState s) {
          expect(s.mode, ThemeMode.system);
          expect(s.useMaterial3, true);
          expect(s.seed, const Color(0xFF6750A4));
        },
      );
    });

    test('RandomizeTheme usa FakeService (semilla determinista)', () async {
      final RandomizeTheme randomize = RandomizeTheme(
        repo,
        const FakeServiceJocaaguraArchetypeTheme(),
      );
      final Either<ErrorItem, ThemeState> r = await randomize();
      r.when(
        (_) => fail('Right esperado'),
        (ThemeState s) {
          expect(s.seed, const Color(0xFF0066CC));
          expect(s.preset, 'random');
        },
      );
    });
  });
}
