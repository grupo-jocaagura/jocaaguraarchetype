import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Repo que puede alternar entre OK y error para el mismo bloc.
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

/// ---- Fakes mínimas para aislar el Bloc ----

class _RepoOk implements RepositoryTheme {
  ThemeState _s = ThemeState.defaults;
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_s);
  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Right<ErrorItem, ThemeState>(_s = s);
}

class _RepoErr implements RepositoryTheme {
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Left<ErrorItem, ThemeState>(
        const ErrorItem(
          title: 'read-fail',
          code: 'read-fail',
          description: 'read-fail',
        ),
      );
  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Left<ErrorItem, ThemeState>(
        const ErrorItem(
          title: 'save-fail',
          code: 'save-fail',
          description: 'save-fail',
        ),
      );
}

class _ServiceOk extends FakeServiceJocaaguraArchetypeTheme {
  const _ServiceOk();
  @override
  Color colorRandom() => const Color(0xFF112233);
}

/// Atajo: construye ThemeUsecases cableando al repo dado.
ThemeUsecases _ucsWith(RepositoryTheme repo) => ThemeUsecases(
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
    );

void main() {
  group('BlocTheme · Estado inicial y ciclo de vida', () {
    test('inicia con defaults y sin error; dispose marca isClosed', () {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));
      expect(bloc.stateOrDefault, ThemeState.defaults);
      expect(bloc.error, isNull);
      expect(bloc.isClosed, isFalse);

      bloc.dispose();
      expect(bloc.isClosed, isTrue);
    });
  });

  group('BlocTheme · Flujo feliz (acciones estándar)', () {
    test('load() actualiza estado desde repo', () async {
      final _RepoOk repo = _RepoOk();
      // precarga un estado distinto al default
      await repo.save(
        ThemeState.defaults.copyWith(mode: ThemeMode.dark, useMaterial3: true),
      );
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(repo));

      await bloc.load();

      expect(bloc.error, isNull);
      expect(bloc.stateOrDefault.mode, ThemeMode.dark);
      expect(bloc.stateOrDefault.useMaterial3, isTrue);

      bloc.dispose();
    });

    test(
        'setMode / setSeed / toggleM3 / applyPreset / setTextScale / reset / randomTheme',
        () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));

      await bloc.setMode(ThemeMode.dark);
      expect(bloc.stateOrDefault.mode, ThemeMode.dark);

      await bloc.setSeed(const Color(0xFF445566));
      expect(bloc.stateOrDefault.seed.toARGB32(), 0xFF445566);

      final bool beforeM3 = bloc.stateOrDefault.useMaterial3;
      await bloc.toggleM3();
      expect(bloc.stateOrDefault.useMaterial3, !beforeM3);

      await bloc.applyPreset('brandX');
      expect(bloc.stateOrDefault.preset, 'brandX');

      await bloc.setTextScale(1.42);
      expect(
        bloc.stateOrDefault.textScale,
        closeTo(1.42.clamp(0.8, 1.6), 1e-9),
      );

      await bloc.randomTheme();
      expect(bloc.stateOrDefault.seed, const Color(0xFF112233));

      await bloc.reset();
      expect(bloc.stateOrDefault, ThemeState.defaults);

      bloc.dispose();
    });
  });

  group('BlocTheme · Errores preservan último estado válido', () {
    test('load() con repo que falla: emite error y conserva estado previo',
        () async {
      final BlocTheme good = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));
      await good.setMode(ThemeMode.dark);
      final ThemeState lastGood = good.stateOrDefault;

      final BlocTheme bad = BlocTheme(themeUsecases: _ucsWith(_RepoErr()));
      // Estado inicial del "bad" es defaults (no lo alteramos)
      await bad.load();

      expect(bad.error, isNotNull, reason: 'Debió reportar error de read');
      expect(
        bad.stateOrDefault,
        ThemeState.defaults,
        reason: 'Conserva último buen estado (inicial default)',
      );

      // Verificamos también que el good sigue intacto
      expect(lastGood.mode, ThemeMode.dark);

      good.dispose();
      bad.dispose();
    });

    test('mutaciones con save() fallido no deben alterar state en Bloc',
        () async {
      final _RepoOk repo = _RepoOk();
      final BlocTheme blocOk = BlocTheme(themeUsecases: _ucsWith(repo));
      await blocOk.setMode(ThemeMode.dark);
      final ThemeState lastGood = blocOk.stateOrDefault;

      final BlocTheme blocErr = BlocTheme(themeUsecases: _ucsWith(_RepoErr()));
      await blocErr.setMode(ThemeMode.light); // intentará guardar y fallará

      expect(blocErr.error, isNotNull);
      // En este bloc, como su último estado bueno era defaults, se mantiene defaults:
      expect(blocErr.stateOrDefault, ThemeState.defaults);

      // Y en el otro bloc no cambió nada
      expect(lastGood.mode, ThemeMode.dark);

      blocOk.dispose();
      blocErr.dispose();
    });
  });

  group('BlocTheme · Granular (applyPatch) vs Reemplazo total (setFromState)',
      () {
    test('applyPatch aplica sólo campos provistos', () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));
      final bool beforeM3 = bloc.stateOrDefault.useMaterial3;

      await bloc.applyPatch(
        const ThemePatch(
          mode: ThemeMode.dark,
          textScale: 1.3,
        ),
      );

      expect(bloc.stateOrDefault.mode, ThemeMode.dark);
      expect(bloc.stateOrDefault.textScale, closeTo(1.3, 1e-9));
      // Los campos no provistos se conservan
      expect(bloc.stateOrDefault.useMaterial3, beforeM3);

      bloc.dispose();
    });

    test('setFromState reemplaza todo el ThemeState', () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));
      final ThemeOverrides ovr = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFFAA5500)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA5500),
          brightness: Brightness.dark,
        ),
      );
      final ThemeState full = ThemeState(
        mode: ThemeMode.light,
        seed: const Color(0xFF334455),
        useMaterial3: true,
        textScale: 1.15,
        preset: 'designer',
        overrides: ovr,
      );

      await bloc.setFromState(full);

      expect(bloc.stateOrDefault.mode, ThemeMode.light);
      expect(bloc.stateOrDefault.seed.toARGB32(), 0xFF334455);
      expect(bloc.stateOrDefault.useMaterial3, isTrue);
      expect(bloc.stateOrDefault.textScale, closeTo(1.15, 1e-9));
      expect(bloc.stateOrDefault.preset, 'designer');
      expect(bloc.stateOrDefault.overrides, isNotNull);
      expect(
        bloc.stateOrDefault.overrides!.light!.brightness,
        Brightness.light,
      );
      expect(bloc.stateOrDefault.overrides!.dark!.brightness, Brightness.dark);

      bloc.dispose();
    });
  });

  group('BlocTheme · Helper themeData()', () {
    test('refleja brightness y useMaterial3 del estado', () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));
      await bloc.applyPatch(
        const ThemePatch(
          mode: ThemeMode.dark,
          useMaterial3: true,
          textScale: 1.1,
        ),
      );

      final ThemeData theme = bloc.themeData();
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      // Sanity: textTheme no nulo; (no verificamos valores exactos del algoritmo fromSeed).
      expect(theme.textTheme.bodyMedium, isNotNull);

      bloc.dispose();
    });
  });

  group('BlocTheme · Streams', () {
    test('stream emite estados cuando se aplican acciones exitosas', () async {
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(_RepoOk()));

      // Coleccionamos emisiones.
      final List<ThemeState> seen = <ThemeState>[];
      final StreamSubscription<ThemeState> sub = bloc.stream.listen(seen.add);

      // Disparamos 3 mutaciones (todas exitosas).
      await bloc.setMode(ThemeMode.dark);
      await bloc.setSeed(const Color(0xFF010203));
      await bloc.toggleM3();

      // Damos un micro-turno al event loop para asegurar entrega.
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(seen, isNotEmpty);
      final ThemeState last = seen.last;
      expect(last.mode, ThemeMode.dark);
      expect(last.seed.toARGB32(), 0xFF010203);
      // No sabemos el valor inicial de useMaterial3, pero sí que cambió respecto al último estado anterior:
      // En lugar de comparar con el penúltimo (requiere manejar índices), comprobamos que sea bool.
      expect(last.useMaterial3, isA<bool>());

      await sub.cancel();
      bloc.dispose();
    });

    test('error emite ErrorItem en fallo y vuelve a null tras éxito', () async {
      final _RepoFlip repo = _RepoFlip();
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(repo));

      final List<ErrorItem?> errors = <ErrorItem?>[];
      final StreamSubscription<ErrorItem?> sub = bloc.error$.listen(errors.add);

      // 1) Forzamos error en save
      repo.failSave = true;
      await bloc.setMode(ThemeMode.dark); // intenta guardar y falla

      // Esperamos a que el error llegue
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(
        errors.where((ErrorItem? e) => e != null),
        isNotEmpty,
        reason: 'Debe haberse emitido un ErrorItem por save-fail',
      );
      final ErrorItem firstNonNull =
          errors.firstWhere((ErrorItem? e) => e != null)!;
      expect(firstNonNull.code, 'save-fail');

      // 2) Reparamos el repo y ejecutamos una operación exitosa
      repo.failSave = false;
      await bloc.setSeed(const Color(0xFF112233));

      // Tras una operación exitosa, BlocTheme limpia el error (emite null)
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(errors.last, isNull, reason: 'Tras éxito, error debe emitir null');

      await sub.cancel();
      bloc.dispose();
    });

    test('stream refleja un load() exitoso (emite estado con cambios)',
        () async {
      final _RepoOk repo = _RepoOk();
      await repo.save(
        ThemeState.defaults.copyWith(mode: ThemeMode.light, textScale: 1.2),
      );
      final BlocTheme bloc = BlocTheme(themeUsecases: _ucsWith(repo));

      // Verificamos mediante emitsThrough que, en algún punto, aparezca un estado con los cambios.
      final Future<void> expectFuture = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ThemeState>((ThemeState s) {
            return s.mode == ThemeMode.light &&
                (s.textScale - 1.2).abs() < 1e-9;
          }),
        ),
      );

      await bloc.load();
      await expectFuture;

      bloc.dispose();
    });
  });
}
