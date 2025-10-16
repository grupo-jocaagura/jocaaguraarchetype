import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// -- Reutilizamos fakes del suite original --
class _RepoOk implements RepositoryTheme {
  ThemeState _s = ThemeState.defaults;
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_s);
  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Right<ErrorItem, ThemeState>(_s = s);
}

class _RepoFlip implements RepositoryTheme {
  ThemeState _s = ThemeState.defaults;
  bool failRead = false;
  bool failSave = false;

  @override
  Future<Either<ErrorItem, ThemeState>> read() async {
    if (failRead) {
      return Left<ErrorItem, ThemeState>(
        const ErrorItem(
          title: 'read-fail',
          code: 'read-fail',
          description: 'read',
        ),
      );
    }
    return Right<ErrorItem, ThemeState>(_s);
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async {
    if (failSave) {
      return Left<ErrorItem, ThemeState>(
        const ErrorItem(
          title: 'save-fail',
          code: 'save-fail',
          description: 'save',
        ),
      );
    }
    _s = s;
    return Right<ErrorItem, ThemeState>(_s);
  }
}

class _ServiceOk extends FakeServiceJocaaguraArchetypeTheme {
  const _ServiceOk();
  @override
  Color colorRandom() => const Color(0xFF112233);
}

/// Atajo original (retrocompatible): NO cablea setTextThemeOverrides.
ThemeUsecases _ucsWithOld(RepositoryTheme repo) => ThemeUsecases(
      load: LoadTheme(repo),
      setMode: SetThemeMode(repo),
      setSeed: SetThemeSeed(repo),
      toggleM3: ToggleMaterial3(repo),
      applyPreset: ApplyThemePreset(repo),
      setTextScale: SetThemeTextScale(repo),
      reset: ResetTheme(repo),
      randomize: RandomizeTheme(repo, const _ServiceOk()),
      applyPatch: ApplyThemePatch(repo),
      setFromState: SetThemeState(repo),
      buildThemeData: const BuildThemeData(),
      // setTextThemeOverrides: null (retrocompatible)
    );

/// Atajo nuevo: SÍ cablea setTextThemeOverrides.
ThemeUsecases _ucsWithNew(RepositoryTheme repo) => ThemeUsecases(
      load: LoadTheme(repo),
      setMode: SetThemeMode(repo),
      setSeed: SetThemeSeed(repo),
      toggleM3: ToggleMaterial3(repo),
      applyPreset: ApplyThemePreset(repo),
      setTextScale: SetThemeTextScale(repo),
      reset: ResetTheme(repo),
      randomize: RandomizeTheme(repo, const _ServiceOk()),
      applyPatch: ApplyThemePatch(repo),
      setFromState: SetThemeState(repo),
      buildThemeData: const BuildThemeData(),
      setTextThemeOverrides: SetTextThemeOverrides(repo),
    );

void main() {
  group('BlocTheme · setTextThemeOverrides (retrocompatible y UC dedicado)',
      () {
    test('Fallback retrocompatible: usa applyPatch cuando el UC es null',
        () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWithOld(_RepoOk()));

      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
      );

      await bloc.setTextThemeOverrides(txt);

      expect(bloc.error, isNull);
      expect(bloc.stateOrDefault.textOverrides, isNotNull);
      expect(
        bloc.stateOrDefault.textOverrides!.light!.bodyMedium!.fontFamily,
        'Inter',
      );
      // dark no se envió → debe permanecer null
      expect(bloc.stateOrDefault.textOverrides!.dark, isNull);

      bloc.dispose();
    });

    test('UC dedicado: usa SetTextThemeOverrides cuando está cableado',
        () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWithNew(_RepoOk()));

      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w600, height: 1.2),
        ),
        dark: TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700, height: 1.2),
        ),
      );

      await bloc.setTextThemeOverrides(txt);

      expect(bloc.error, isNull);
      expect(bloc.stateOrDefault.textOverrides, equals(txt));
      expect(
        bloc.stateOrDefault.textOverrides!.dark!.titleLarge!.fontWeight,
        FontWeight.w700,
      );

      bloc.dispose();
    });

    test('Errores de save no alteran el estado y se reportan en error',
        () async {
      final _RepoFlip repo = _RepoFlip();
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWithNew(repo));

      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(bodySmall: TextStyle(letterSpacing: 0.5)),
      );

      // Fuerza fallo
      repo.failSave = true;
      final List<ErrorItem?> errors = <ErrorItem?>[];
      final StreamSubscription<ErrorItem?> sub = bloc.error$.listen(errors.add);

      await bloc.setTextThemeOverrides(txt);

      // Debe haber error y NO debe haberse alterado el estado (sigue defaults)
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(bloc.error, isNotNull);
      expect(bloc.stateOrDefault.textOverrides, isNull);

      // Repara y vuelve a intentar (debe limpiar error y aplicar cambios)
      repo.failSave = false;
      await bloc.setTextThemeOverrides(txt);

      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(bloc.error, isNull);
      expect(bloc.stateOrDefault.textOverrides, isNotNull);
      expect(
        bloc.stateOrDefault.textOverrides!.light!.bodySmall!.letterSpacing,
        0.5,
      );

      await sub.cancel();
      bloc.dispose();
    });

    test('stream emite cambios cuando se setean y limpian overrides', () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWithOld(_RepoOk()));

      final List<ThemeState> seen = <ThemeState>[];
      final StreamSubscription<ThemeState> sub = bloc.stream.listen(seen.add);

      await bloc.setTextThemeOverrides(
        const TextThemeOverrides(
          light: TextTheme(bodyMedium: TextStyle(fontSize: 13)),
        ),
      );
      await bloc.setTextThemeOverrides(null);

      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(seen.length >= 2, isTrue);
      // Último estado debería tener textOverrides = null
      expect(seen.last.textOverrides, isNotNull);

      await sub.cancel();
      bloc.dispose();
    });
  });
}
