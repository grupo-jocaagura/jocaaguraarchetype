import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// ---------------- Fakes ----------------

// ignore: avoid_implementing_value_types
class _FakeError implements ErrorItem {
  _FakeError(this.location, this.message);
  final String location;
  final String message;
  @override
  String toString() => '$_FakeError($location): $message';

  @override
  String get code => throw UnimplementedError();

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

class _FakeMapper implements ErrorMapper {
  const _FakeMapper();
  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknow',
  }) {
    return _FakeError(location, error.toString());
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknow',
  }) {
    throw UnimplementedError();
  }
}

class _GatewayFake implements GatewayThemeReact {
  _GatewayFake();

  Either<ErrorItem, Map<String, dynamic>>? nextRead;
  Either<ErrorItem, Map<String, dynamic>>? nextWrite;
  final StreamController<Either<ErrorItem, Map<String, dynamic>>> _ctrl =
      StreamController<Either<ErrorItem, Map<String, dynamic>>>.broadcast();

  // Helpers
  void emit(Either<ErrorItem, Map<String, dynamic>> e) => _ctrl.add(e);

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async {
    return nextRead ??
        Right<ErrorItem, Map<String, dynamic>>(ThemeState.defaults.toJson());
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  ) async {
    return nextWrite ?? Right<ErrorItem, Map<String, dynamic>>(json);
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch() => _ctrl.stream;
}

// Helpers Either (resilientes a la implementación)
bool _isRight(dynamic either) {
  try {
    final dynamic v = (either as dynamic).isRight();
    if (v is bool) {
      return v;
    }
  } catch (_) {}
  try {
    // ignore: always_specify_types
    final r = (either as dynamic).fold((l) => null, (r) => r);
    return r != null;
  } catch (_) {}
  return false;
}

bool _isLeft(dynamic either) => !_isRight(either);
ThemeState? _rightTheme(dynamic either) {
  try {
    // ignore: always_specify_types
    final dynamic r = (either as dynamic).fold((l) => null, (r) => r);
    if (r is ThemeState) {
      return r;
    }
  } catch (_) {}
  return null;
}

_FakeError? _leftError(dynamic either) {
  try {
    // ignore: always_specify_types
    final dynamic l = (either as dynamic).fold((l) => l, (r) => null);
    if (l is _FakeError) {
      return l;
    }
  } catch (_) {}
  return null;
}

// ---------------- Tests ----------------

void main() {
  group('RepositoryThemeReactImpl • read', () {
    test('Given gateway Right(valid map) When read Then Right(ThemeState)',
        () async {
      final _GatewayFake g = _GatewayFake();
      g.nextRead =
          Right<ErrorItem, Map<String, dynamic>>(ThemeState.defaults.toJson());
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final dynamic r = await repo.read();
      expect(_isRight(r), isTrue);
      expect(_rightTheme(r), isA<ThemeState>());
    });

    test(
        'Given gateway Right(malformed map) When read Then Left(ErrorItem) with location',
        () async {
      final _GatewayFake g = _GatewayFake();
      // Mal formado: textScale no finito provoca FormatException en ThemeState.fromJson
      g.nextRead =
          Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
        'useM3': true,
        'textScale': double.infinity,
      });

      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final dynamic r = await repo.read();
      expect(_isLeft(r), isTrue);
      final _FakeError? e = _leftError(r);
      expect(e, isNotNull);
      expect(e!.location, 'RepositoryThemeReactImpl.read');
    });

    test('Given gateway Left(error) When read Then propagates Left as-is',
        () async {
      final _GatewayFake g = _GatewayFake();
      g.nextRead =
          Left<ErrorItem, Map<String, dynamic>>(_FakeError('gw.read', 'oops'));
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final dynamic r = await repo.read();
      expect(_isLeft(r), isTrue);
    });
  });

  group('RepositoryThemeReactImpl • save', () {
    test(
        'Given gateway Right(echos json) When save valid Then Right(ThemeState)',
        () async {
      final _GatewayFake g = _GatewayFake();
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final ThemeState next = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        seed: const Color(0xFF112233),
        textScale: 1.1,
      );

      final dynamic r = await repo.save(next);
      expect(_isRight(r), isTrue);
      final ThemeState? s = _rightTheme(r);
      expect(s, isNotNull);
      expect(s!.mode, ThemeMode.dark);
    });

    test(
        'Given gateway Right(malformed map) When save Then Left(ErrorItem) with location',
        () async {
      final _GatewayFake g = _GatewayFake();
      // Forzamos que el gateway devuelva un mapa roto tras write:
      g.nextWrite =
          Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
        'useM3': true,
        'textScale': double.nan, // hará fallar ThemeState.fromJson
      });

      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final dynamic r = await repo.save(ThemeState.defaults);
      expect(_isLeft(r), isTrue);
      final _FakeError? e = _leftError(r);
      expect(e, isNotNull);
      expect(e!.location, 'RepositoryThemeReactImpl.save');
    });

    test('Given gateway Left(error) When save Then propagates Left', () async {
      final _GatewayFake g = _GatewayFake();
      g.nextWrite =
          Left<ErrorItem, Map<String, dynamic>>(_FakeError('gw.write', 'boom'));
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final dynamic r = await repo.save(ThemeState.defaults);
      expect(_isLeft(r), isTrue);
    });
  });

  group('RepositoryThemeReactImpl • watch', () {
    test('Given stream Right(valid) When watch Then Right(ThemeState)',
        () async {
      final _GatewayFake g = _GatewayFake();
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<Either<ErrorItem, ThemeState>> sub =
          repo.watch().listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      g.emit(
        Right<ErrorItem, Map<String, dynamic>>(
          ThemeState.defaults.copyWith(mode: ThemeMode.dark).toJson(),
        ),
      );

      final dynamic first = await c.future;
      expect(_isRight(first), isTrue);
      expect(_rightTheme(first)!.mode, ThemeMode.dark);

      await sub.cancel();
    });

    test(
        'Given stream Right(malformed) When watch Then Left(ErrorItem) with location',
        () async {
      final _GatewayFake g = _GatewayFake();
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<Either<ErrorItem, ThemeState>> sub =
          repo.watch().listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      g.emit(
        Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
          'useM3': true,
          'textScale': double.infinity,
        }),
      );

      final dynamic first = await c.future;
      expect(_isLeft(first), isTrue);
      final _FakeError? e = _leftError(first);
      expect(e, isNotNull);
      expect(e!.location, 'RepositoryThemeReactImpl.watch');

      await sub.cancel();
    });

    test('Given stream Left(error) When watch Then propagates Left', () async {
      final _GatewayFake g = _GatewayFake();
      final RepositoryThemeReactImpl repo = RepositoryThemeReactImpl(
        gateway: g,
        errorMapper: const _FakeMapper(),
      );

      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<Either<ErrorItem, ThemeState>> sub =
          repo.watch().listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      g.emit(
        Left<ErrorItem, Map<String, dynamic>>(
          _FakeError('gw.watch', 'nope'),
        ),
      );

      final dynamic first = await c.future;
      expect(_isLeft(first), isTrue);

      await sub.cancel();
    });
  });
}
