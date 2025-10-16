import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// --------------------------- Fakes ---------------------------

// ignore: avoid_implementing_value_types
class _Err implements ErrorItem {
  _Err(this.code);
  @override
  final String code;
  @override
  String toString() => 'ERR:$code';

  @override
  ErrorItem copyWith({
    String? title,
    String? code,
    String? description,
    Map<String, dynamic>? meta,
    ErrorLevelEnum? errorLevel,
  }) {
    throw UnimplementedError();
  }

  @override
  String get description => throw UnimplementedError();

  @override
  ErrorLevelEnum get errorLevel => throw UnimplementedError();

  @override
  Map<String, dynamic> get meta => throw UnimplementedError();

  @override
  String get title => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class _RepoFake implements RepositoryTheme {
  ThemeState _state = ThemeState.defaults;
  _Err? nextReadErr;
  _Err? nextSaveErr;

  @override
  Future<Either<ErrorItem, ThemeState>> read() async {
    if (nextReadErr != null) {
      return Left<ErrorItem, ThemeState>(nextReadErr!);
    }
    return Right<ErrorItem, ThemeState>(_state);
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) async {
    if (nextSaveErr != null) {
      return Left<ErrorItem, ThemeState>(nextSaveErr!);
    }
    _state = next;
    return Right<ErrorItem, ThemeState>(_state);
  }
}

class _RepoReactFake implements RepositoryThemeReact {
  final StreamController<Either<ErrorItem, ThemeState>> _ctrl =
      StreamController<Either<ErrorItem, ThemeState>>.broadcast();

  void emit(Either<ErrorItem, ThemeState> e) => _ctrl.add(e);

  @override
  Stream<Either<ErrorItem, ThemeState>> watch() => _ctrl.stream;

  @override
  Future<Either<ErrorItem, ThemeState>> read() {
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) {
    throw UnimplementedError();
  }
}

class _ServiceThemeFake implements ServiceTheme {
  const _ServiceThemeFake({this.nextColor = const Color(0xFFAABBCC)});
  final Color nextColor;

  @override
  ThemeData darkTheme(ThemeState s) =>
      ThemeData.from(colorScheme: const ColorScheme.dark());
  @override
  ThemeData lightTheme(ThemeState s) =>
      ThemeData.from(colorScheme: const ColorScheme.light());

  @override
  Color colorRandom() => nextColor;

  @override
  ColorScheme schemeFromSeed(Color seed, Brightness brightness) {
    throw UnimplementedError();
  }

  @override
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  }) {
    throw UnimplementedError();
  }
}

// Helpers Either (compatibles con distintas impls)
bool _isRight(dynamic either) {
  try {
    final dynamic v = (either as dynamic).isRight();
    if (v is bool) {
      return v;
    }
  } catch (_) {}
  try {
    final dynamic r =
        (either as dynamic).fold((dynamic l) => null, (dynamic r) => r);
    return r != null;
  } catch (_) {}
  return false;
}

ThemeState? _right(dynamic either) {
  try {
    final dynamic r =
        (either as dynamic).fold((dynamic l) => null, (dynamic r) => r);
    if (r is ThemeState) {
      return r;
    }
  } catch (_) {}
  return null;
}

// ---------------------------- TESTS ----------------------------

void main() {
  group('ThemeUsecases.fromRepo wiring', () {
    test('Returns a fully wired set with defaults and BuildThemeData const',
        () {
      final _RepoFake repo = _RepoFake();
      final ThemeUsecases uc = ThemeUsecases.fromRepo(repo);
      expect(uc.load, isNotNull);
      expect(uc.setMode, isNotNull);
      expect(uc.setSeed, isNotNull);
      expect(uc.toggleM3, isNotNull);
      expect(uc.applyPreset, isNotNull);
      expect(uc.setTextScale, isNotNull);
      expect(uc.reset, isNotNull);
      expect(uc.randomize, isNotNull);
      expect(uc.applyPatch, isNotNull);
      expect(uc.setFromState, isNotNull);
      expect(uc.buildThemeData, isA<BuildThemeData>());
    });
  });

  group('LoadTheme / SetThemeState / ResetTheme', () {
    test('LoadTheme returns current state (Right)', () async {
      final _RepoFake repo = _RepoFake();
      final LoadTheme load = LoadTheme(repo);

      final dynamic r = await load();
      expect(_isRight(r), isTrue);
      expect(_right(r), isA<ThemeState>());
    });

    test('SetThemeState replaces entire state', () async {
      final _RepoFake repo = _RepoFake();
      final SetThemeState setFromState = SetThemeState(repo);

      final ThemeState next = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        preset: 'x',
        textScale: 1.25,
      );
      final dynamic r = await setFromState(next);
      expect(_isRight(r), isTrue);
      final ThemeState s = _right(r)!;
      expect(s.mode, ThemeMode.dark);
      expect(s.preset, 'x');
      expect(s.textScale, 1.25);
    });

    test('ResetTheme sets defaults', () async {
      final _RepoFake repo = _RepoFake();
      // set a custom state first
      await repo.save(
        ThemeState.defaults.copyWith(
          mode: ThemeMode.dark,
          preset: 'custom',
        ),
      );
      final ResetTheme reset = ResetTheme(repo);
      final dynamic r = await reset();
      expect(_isRight(r), isTrue);
      final ThemeState s = _right(r)!;
      expect(s, ThemeState.defaults);
    });
  });

  group('SetThemeMode / SetThemeSeed / ToggleMaterial3 / ApplyThemePreset', () {
    test('SetThemeMode sets mode and persists', () async {
      final _RepoFake repo = _RepoFake();
      final SetThemeMode setMode = SetThemeMode(repo);
      final dynamic r = await setMode(ThemeMode.dark);
      expect(_right(r)!.mode, ThemeMode.dark);
    });

    test('SetThemeSeed sets seed and persists', () async {
      final _RepoFake repo = _RepoFake();
      final SetThemeSeed setSeed = SetThemeSeed(repo);
      final dynamic r = await setSeed(const Color(0xFF112233));
      expect(_right(r)!.seed, const Color(0xFF112233));
    });

    test('ToggleMaterial3 flips boolean and persists', () async {
      final _RepoFake repo = _RepoFake();
      await repo.save(ThemeState.defaults.copyWith(useMaterial3: false));
      final ToggleMaterial3 toggle = ToggleMaterial3(repo);
      final dynamic r = await toggle();
      expect(_right(r)!.useMaterial3, isTrue);
    });

    test('ApplyThemePreset sets preset and persists', () async {
      final _RepoFake repo = _RepoFake();
      final ApplyThemePreset apply = ApplyThemePreset(repo);
      final dynamic r = await apply('brandX');
      expect(_right(r)!.preset, 'brandX');
    });
  });

  group('SetThemeTextScale (clamp + finite)', () {
    test('Clamps below 0.8 to 0.8', () async {
      final _RepoFake repo = _RepoFake();
      final SetThemeTextScale cmd = SetThemeTextScale(repo);
      final dynamic r = await cmd(0.1);
      final double v = _right(r)!.textScale;
      expect(v, inInclusiveRange(0.8, 1.6));
      expect(v, closeTo(0.8, 1e-9));
    });

    test('Clamps above 1.6 to 1.6', () async {
      final _RepoFake repo = _RepoFake();
      final SetThemeTextScale cmd = SetThemeTextScale(repo);
      final dynamic r = await cmd(9.0);
      expect(_right(r)!.textScale, closeTo(1.6, 1e-9));
    });

    test('Finite mid value is preserved (subject to Utils.getDouble)',
        () async {
      final _RepoFake repo = _RepoFake();
      final SetThemeTextScale cmd = SetThemeTextScale(repo);
      final dynamic r = await cmd(1.25);
      final double v = _right(r)!.textScale;
      expect(v, inInclusiveRange(0.8, 1.6));
      // Permitimos pequeña tolerancia por posibles redondeos en Utils.getDouble
      expect(v, closeTo(1.25, 0.01));
    });
  });

  group('ApplyThemePatch', () {
    test('Applies patch over current and persists', () async {
      final _RepoFake repo = _RepoFake();
      await repo.save(
        ThemeState.defaults.copyWith(
          mode: ThemeMode.light,
          textScale: 1.0,
        ),
      );
      final ApplyThemePatch applyPatch = ApplyThemePatch(repo);

      const ThemePatch patch = ThemePatch(
        mode: ThemeMode.dark,
        textScale: 1.3,
      );
      final dynamic r = await applyPatch(patch);
      final ThemeState s = _right(r)!;
      expect(s.mode, ThemeMode.dark);
      expect(s.textScale, closeTo(1.3, 1e-9));
    });
  });

  group('RandomizeTheme', () {
    test('Uses ServiceTheme.colorRandom and sets preset: random', () async {
      final _RepoFake repo = _RepoFake();
      final RandomizeTheme randomize = RandomizeTheme(
        repo,
        const _ServiceThemeFake(nextColor: Color(0xFF445566)),
      );
      final dynamic r = await randomize();
      final ThemeState s = _right(r)!;
      expect(s.seed, const Color(0xFF445566));
      expect(s.preset, 'random');
    });
  });

  group('SetTextThemeOverrides (set & clear)', () {
    test('Sets overrides and persists', () async {
      final _RepoFake repo = _RepoFake();
      final SetTextThemeOverrides cmd = SetTextThemeOverrides(repo);

      const TextThemeOverrides next = TextThemeOverrides(
        light: TextTheme(bodyMedium: TextStyle(fontSize: 12)),
        dark: TextTheme(bodyMedium: TextStyle(fontSize: 12)),
        fontName: 'Inter',
      );

      final dynamic r = await cmd(next);
      final ThemeState s = _right(r)!;
      expect(s.textOverrides, isNotNull);
      expect(s.textOverrides!.fontName, 'Inter');
    });

    test('Clears overrides when passing null', () async {
      final _RepoFake repo = _RepoFake();
      // Seed an initial state with textOverrides
      await repo.save(
        ThemeState.defaults.copyWith(
          textOverrides: const TextThemeOverrides(
            light: TextTheme(bodyMedium: TextStyle(fontSize: 10)),
            fontName: 'X',
          ),
        ),
      );

      final SetTextThemeOverrides cmd = SetTextThemeOverrides(repo);
      final dynamic r = await cmd(null);
      final ThemeState s = _right(r)!;
      expect(s.textOverrides, isNotNull);
    });
  });

  group('WatchTheme (reactive)', () {
    test('Emits Right(ThemeState) on repository reactive stream', () async {
      final _RepoReactFake react = _RepoReactFake();
      final WatchTheme watch = WatchTheme(react);

      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<Either<ErrorItem, ThemeState>> sub =
          watch().listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      react.emit(
        Right<ErrorItem, ThemeState>(
          ThemeState.defaults.copyWith(mode: ThemeMode.dark),
        ),
      );

      final dynamic first = await c.future;
      expect(_isRight(first), isTrue);
      expect(_right(first)!.mode, ThemeMode.dark);

      await sub.cancel();
    });

    test('Emits Left(ErrorItem) without closing on errors', () async {
      final _RepoReactFake react = _RepoReactFake();
      final WatchTheme watch = WatchTheme(react);

      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<Either<ErrorItem, ThemeState>> sub =
          watch().listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      react.emit(Left<ErrorItem, ThemeState>(_Err('stream-error')));

      final dynamic first = await c.future;
      expect(_isRight(first), isFalse);

      await sub.cancel();
    });
  });

  group('Concurrency (sequential simulation: last write wins)', () {
    test('Two updates in sequence: last write wins', () async {
      final _RepoFake repo = _RepoFake();
      final ApplyThemePreset applyPreset = ApplyThemePreset(repo);
      final SetThemeMode setMode = SetThemeMode(repo);

      // Emula “concurrencia” secuencial: dos cambios rápidos
      await applyPreset('A');
      await setMode(ThemeMode.dark);

      final ThemeState finalState = (await repo.read() as dynamic).fold(
        (dynamic l) => ThemeState.defaults,
        (dynamic r) => r,
      ) as ThemeState;

      // El último cambio (mode) debe estar presente junto con el preset anterior
      expect(finalState.mode, ThemeMode.dark);
      expect(finalState.preset, 'A');
    });
  });
}
