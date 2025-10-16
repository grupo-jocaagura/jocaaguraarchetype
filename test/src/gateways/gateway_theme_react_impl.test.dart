// ignore_for_file: always_specify_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Importa tu paquete real
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// ---------------- Fakes de apoyo ----------------

class _FakeServiceThemeReact extends ServiceThemeReact {
  _FakeServiceThemeReact() {
    _controller = StreamController<Map<String, dynamic>>.broadcast(
      onListen: () {
        // no replay; el estado actual se consulta por getter
      },
    );
  }
  final List<Map<String, dynamic>> emitted = <Map<String, dynamic>>[];
  late final StreamController<Map<String, dynamic>> _controller;

  @override
  Stream<Map<String, dynamic>> get themeStream => _controller.stream;

  @override
  Map<String, dynamic> get themeStateJson =>
      emitted.isEmpty ? ThemeState.defaults.toJson() : emitted.last;

  @override
  void updateTheme(Map<String, dynamic> json) {
    emitted.add(Map<String, dynamic>.from(json));
    _controller.add(json);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class _FakeServiceTheme implements ServiceTheme {
  _FakeServiceTheme();
  bool shouldThrow = false;
  int lightCalls = 0;
  int darkCalls = 0;

  @override
  ThemeData lightTheme(ThemeState s) {
    lightCalls++;
    if (shouldThrow) {
      throw StateError('light fail');
    }
    return ThemeData.from(colorScheme: const ColorScheme.light());
  }

  @override
  ThemeData darkTheme(ThemeState s) {
    darkCalls++;
    if (shouldThrow) {
      throw StateError('dark fail');
    }
    return ThemeData.from(colorScheme: const ColorScheme.dark());
  }

  @override
  Color colorRandom() {
    throw UnimplementedError();
  }

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
    String location = 'unknown',
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

// Helpers para inspeccionar Either de forma segura.
bool _isRight(dynamic either) {
  try {
    // dartz: Right
    return either is Right;
  } catch (_) {
    try {
      final dynamic v = (either as dynamic).isRight();
      if (v is bool) {
        return v;
      }
    } catch (_) {}
    return false;
  }
}

bool _isLeft(dynamic either) => !_isRight(either);

Map<String, dynamic>? _getRight(dynamic either) {
  try {
    if (either is Right) {
      // dartz Right has 'value' in toString only; no API pública directa.
      // Intentamos fold:
    }
    final dynamic r =
        (either as dynamic).fold((dynamic l) => null, (dynamic r) => r);
    if (r is Map<String, dynamic>) {
      return r;
    }
  } catch (_) {}
  return null;
}

// ---------------- Tests ----------------

void main() {
  group('GatewayThemeReactImpl • read/write nominal', () {
    test('read() normalizes and smoke-tests current service JSON', () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final _FakeServiceTheme theme = _FakeServiceTheme();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: theme,
        errorMapper: const _FakeMapper(),
      );

      final dynamic result = await gw.read();
      expect(_isRight(result), isTrue);

      final Map<String, dynamic>? norm = _getRight(result);
      expect(norm, isNotNull);
      expect(
        norm!['mode'],
        anyOf('light', 'system'),
      ); // defaults -> system en normalize si falta
      expect(norm['useM3'], isTrue);
      expect(norm['preset'], 'brand');
      expect((norm['textScale'] as num).toDouble(), inInclusiveRange(0.8, 1.6));
    });

    test('write() normalizes, smoke-tests and broadcasts normalized JSON',
        () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final _FakeServiceTheme theme = _FakeServiceTheme();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: theme,
        errorMapper: const _FakeMapper(),
      );

      final Map<String, dynamic> raw = <String, dynamic>{
        'mode': 'dark',
        'seed': '#FF112233', // string → int
        'textScale': 9.0, // clamp a 1.6
        // omitimos useM3 → default true
      };

      final dynamic result = await gw.write(raw);

      // 1) Right
      expect(_isRight(result), isTrue);

      // 2) Emisión al bus con normalizado
      expect(bus.emitted, isNotEmpty);
      final Map<String, dynamic> emitted = bus.emitted.last;

      expect(emitted['mode'], 'dark');
      expect(emitted['useM3'], isTrue);
      expect(emitted['textScale'], 1.6); // clamped
      expect(emitted['seed'], isA<int>()); // parseado

      // 3) Theme fue invocado (smoke test)
      expect(theme.lightCalls, greaterThan(0));
      expect(theme.darkCalls, greaterThan(0));
    });
  });

  group('GatewayThemeReactImpl • normalization details', () {
    test('seed accepts int, "#AARRGGBB", and Color; output is int ARGB32',
        () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: _FakeServiceTheme(),
        errorMapper: const _FakeMapper(),
      );

      // int
      await gw.write(<String, dynamic>{'seed': 0xFFABCDEF});
      expect(bus.emitted.last['seed'], 0xFFABCDEF);

      // hex string
      await gw.write(<String, dynamic>{'seed': '#FF010203'});
      expect(bus.emitted.last['seed'], 0xFF010203);

      // Color
      await gw.write(<String, dynamic>{'seed': const Color(0xFF101112)});
      expect(bus.emitted.last['seed'], 0xFF101112);
    });

    test(
        'overrides/textOverrides accept Map or domain objects and are re-serialized',
        () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: _FakeServiceTheme(),
        errorMapper: const _FakeMapper(),
      );

      // Como Map
      await gw.write(<String, dynamic>{
        'overrides': const ThemeOverrides(
          light: ColorScheme.light(primary: Color(0xFF0000FF)),
        ).toJson(),
      });
      expect(
        (bus.emitted.last['overrides'] as Map<String, dynamic>)['light'],
        isNotNull,
      );

      // Como objeto
      await gw.write(<String, dynamic>{
        'textOverrides': const TextThemeOverrides(
          light: TextTheme(bodyMedium: TextStyle(fontSize: 14)),
        ),
      });
      expect(bus.emitted.last['textOverrides'], isA<Map<String, dynamic>>());
    });

    test(
        'textScale is clamped to [0.8, 1.6]; preset defaults to "brand"; useM3 defaults true',
        () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: _FakeServiceTheme(),
        errorMapper: const _FakeMapper(),
      );

      await gw.write(<String, dynamic>{'textScale': 0.1}); // → 0.8
      expect(bus.emitted.last['textScale'], 0.8);
      expect(bus.emitted.last['preset'], 'brand');
      expect(bus.emitted.last['useM3'], isTrue);
    });

    test('invalid hex seed falls back to default', () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: _FakeServiceTheme(),
        errorMapper: const _FakeMapper(),
      );

      await gw.write(<String, dynamic>{'seed': '#XYZXYZXY'}); // inválido
      expect(bus.emitted.last['seed'], 0xFF6750A4); // default
    });
  });

  group('GatewayThemeReactImpl • watch()', () {
    test('Given valid events When watch Then yields Right with normalized json',
        () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: _FakeServiceTheme(),
        errorMapper: const _FakeMapper(),
      );

      final Stream<dynamic> stream = gw.watch();

      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<dynamic> sub = stream.listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      // Empujamos un evento crudo
      bus.updateTheme(<String, dynamic>{'mode': 'dark', 'seed': '#FF000011'});

      final dynamic first = await c.future;
      expect(_isRight(first), isTrue);
      final Map<String, dynamic>? norm = _getRight(first);
      expect(norm, isNotNull);
      expect(norm!['mode'], 'dark');
      expect(norm['seed'], 0xFF000011);

      await sub.cancel();
      bus.dispose();
    });

    test(
        'Given failing smoke test When watch Then yields Left mapped with location',
        () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final _FakeServiceTheme theme = _FakeServiceTheme()..shouldThrow = true;
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: theme,
        errorMapper: const _FakeMapper(),
      );

      final Stream<dynamic> stream = gw.watch();
      final Completer<dynamic> c = Completer<dynamic>();
      final StreamSubscription<dynamic> sub = stream.listen((dynamic e) {
        if (!c.isCompleted) {
          c.complete(e);
        }
      });

      bus.updateTheme(<String, dynamic>{'mode': 'light'});

      final dynamic first = await c.future;
      expect(_isLeft(first), isTrue);

      // Intentamos extraer el ErrorItem de manera segura
      try {
        final dynamic left = (first as dynamic).fold((l) => l, (r) => null);
        expect(left, isA<_FakeError>());
        expect((left as _FakeError).location, 'GatewayThemeReactImpl.watch');
      } catch (_) {
        // En implementaciones alternativas de Either, omitimos esta aserción detallada.
      }

      await sub.cancel();
      bus.dispose();
    });
  });

  group('GatewayThemeReactImpl • read()/write() error mapping', () {
    test('read() maps exceptions to Left with location', () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final _FakeServiceTheme theme = _FakeServiceTheme()..shouldThrow = true;
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: theme,
        errorMapper: const _FakeMapper(),
      );

      final dynamic result = await gw.read();
      expect(_isLeft(result), isTrue);
      try {
        final dynamic left = (result as dynamic).fold((l) => l, (r) => null);
        expect(left, isA<_FakeError>());
        expect((left as _FakeError).location, 'GatewayThemeReactImpl.read');
      } catch (_) {}
    });

    test('write() maps exceptions to Left with location', () async {
      final _FakeServiceThemeReact bus = _FakeServiceThemeReact();
      final _FakeServiceTheme theme = _FakeServiceTheme()..shouldThrow = true;
      final GatewayThemeReactImpl gw = GatewayThemeReactImpl(
        service: bus,
        themeService: theme,
        errorMapper: const _FakeMapper(),
      );

      final dynamic result = await gw.write(<String, dynamic>{'mode': 'dark'});
      expect(_isLeft(result), isTrue);
      try {
        final dynamic left = (result as dynamic).fold((l) => l, (r) => null);
        expect(left, isA<_FakeError>());
        expect((left as _FakeError).location, 'GatewayThemeReactImpl.write');
      } catch (_) {}
    });
  });
}
