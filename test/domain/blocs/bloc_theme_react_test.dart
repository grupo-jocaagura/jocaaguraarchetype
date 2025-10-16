import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// --------------------- Fakes de apoyo ---------------------

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

  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_state);

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) async {
    _state = next;
    return Right<ErrorItem, ThemeState>(_state);
  }
}

class _RepoReactFake implements RepositoryThemeReact {
  final StreamController<Either<ErrorItem, ThemeState>> _ctrl =
      StreamController<Either<ErrorItem, ThemeState>>.broadcast();

  bool get hasListener => _ctrl.hasListener;

  void emit(Either<ErrorItem, ThemeState> e) => _ctrl.add(e);

  @override
  Stream<Either<ErrorItem, ThemeState>> watch() => _ctrl.stream;

  void close() => _ctrl.close();

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
  const _ServiceThemeFake();
  @override
  ThemeData darkTheme(ThemeState s) =>
      ThemeData.from(colorScheme: const ColorScheme.dark());
  @override
  ThemeData lightTheme(ThemeState s) =>
      ThemeData.from(colorScheme: const ColorScheme.light());
  @override
  Color colorRandom() => const Color(0xFFAABBCC);

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

// --------------------- Tests ---------------------

void main() {
  group('BlocThemeReact • subscription lifecycle', () {
    test(
        'Given WatchTheme stream When constructing Then subscribes immediately',
        () async {
      // Arrange
      final _RepoFake repo = _RepoFake();
      final _RepoReactFake reactRepo = _RepoReactFake();
      final WatchTheme watch = WatchTheme(reactRepo);
      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
        serviceTheme: const _ServiceThemeFake(),
      );

      // Act
      final BlocThemeReact bloc =
          BlocThemeReact(themeUsecases: uc, watchTheme: watch);

      // Assert: el stream tiene listener
      expect(reactRepo.hasListener, isTrue);

      // Cleanup
      bloc.dispose();
      reactRepo.close();
    });

    test(
        'Given disposed bloc When emitting Then no listener remains and no throw',
        () async {
      final _RepoFake repo = _RepoFake();
      final _RepoReactFake reactRepo = _RepoReactFake();
      final WatchTheme watch = WatchTheme(reactRepo);
      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
        serviceTheme: const _ServiceThemeFake(),
      );

      final BlocThemeReact bloc =
          BlocThemeReact(themeUsecases: uc, watchTheme: watch);
      expect(reactRepo.hasListener, isTrue);

      // Act: dispose cancela suscripción de forma no bloqueante
      bloc.dispose();

      // Assert: sin listener
      // Nota: cancelar es async; damos un microtask para asentarse
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(reactRepo.hasListener, isFalse);

      // Emitir después de dispose no debe lanzar
      reactRepo.emit(Right<ErrorItem, ThemeState>(ThemeState.defaults));

      // Cleanup
      reactRepo.close();
    });
  });

  group('BlocThemeReact • event forwarding tolerance', () {
    test('Right(ThemeState) events are accepted without throwing', () async {
      final _RepoFake repo = _RepoFake();
      final _RepoReactFake reactRepo = _RepoReactFake();
      final WatchTheme watch = WatchTheme(reactRepo);
      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
        serviceTheme: const _ServiceThemeFake(),
      );

      final BlocThemeReact bloc =
          BlocThemeReact(themeUsecases: uc, watchTheme: watch);

      // Emit varios eventos; no debe lanzar
      reactRepo.emit(
        Right<ErrorItem, ThemeState>(
          ThemeState.defaults.copyWith(mode: ThemeMode.dark),
        ),
      );
      reactRepo.emit(
        Right<ErrorItem, ThemeState>(
          ThemeState.defaults.copyWith(useMaterial3: false),
        ),
      );

      // Espera breve para procesamiento
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(true, isTrue);

      bloc.dispose();
      reactRepo.close();
    });

    test('Left(ErrorItem) events are accepted without throwing', () async {
      final _RepoFake repo = _RepoFake();
      final _RepoReactFake reactRepo = _RepoReactFake();
      final WatchTheme watch = WatchTheme(reactRepo);
      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
        serviceTheme: const _ServiceThemeFake(),
      );

      final BlocThemeReact bloc =
          BlocThemeReact(themeUsecases: uc, watchTheme: watch);

      // Emit error; _apply (en BlocTheme) debe manejar Either
      reactRepo.emit(Left<ErrorItem, ThemeState>(_Err('stream-failure')));

      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(true, isTrue);

      bloc.dispose();
      reactRepo.close();
    });
  });

  group('BlocThemeReact • idempotent dispose', () {
    test('Calling dispose() multiple times is safe', () async {
      final _RepoFake repo = _RepoFake();
      final _RepoReactFake reactRepo = _RepoReactFake();
      final WatchTheme watch = WatchTheme(reactRepo);
      final ThemeUsecases uc = ThemeUsecases.fromRepo(
        repo,
        serviceTheme: const _ServiceThemeFake(),
      );

      final BlocThemeReact bloc =
          BlocThemeReact(themeUsecases: uc, watchTheme: watch);

      // Múltiples disposes no deben lanzar
      bloc.dispose();
      bloc.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      reactRepo.close();
      expect(true, isTrue);
    });
  });
}
