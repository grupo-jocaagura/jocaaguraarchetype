part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reactive gateway that normalizes, smoke-tests and routes theme JSON.
///
/// ## Behavior
/// - `read()`: grabs the current JSON from the service bus, **normalizes** it,
///   runs a smoke test, and returns `Right(normalizedJson)`.
/// - `write(json)`: **normalizes** and smoke-tests the input, **broadcasts the
///   normalized JSON** to the service bus, and returns `Right(normalizedJson)`.
/// - `watch()`: listens to the raw service stream; for each event, normalizes
///   and smoke-tests, yielding `Right(normalizedJson)`, or `Left(error)` on failure.
///
/// ## Normalization
/// - `mode`: unknown/missing → `ThemeMode.system`.
/// - `seed`: accepts `int` ARGB32, `'#AARRGGBB'` or `Color`; output is **`int` ARGB32**.
/// - `useM3`: defaults to `true`.
/// - `textScale`: clamped to `[0.8, 1.6]`.
/// - `preset`: defaults to `'brand'`.
/// - `overrides` / `textOverrides`: accept either domain objects or `Map` and
///   are re-serialized via their `toJson()`.
///
/// ## Validation
/// - A lightweight smoke test is performed by constructing a [ThemeState] from
///   the normalized JSON and calling both `_theme.lightTheme()` and
///   `_theme.darkTheme()`. Any exception is mapped to an [ErrorItem] via
///   [ErrorMapper].
///
/// ## Notes
/// - Normalization may **write default values** (e.g., `useM3=true`) into the
///   provided map if the key is missing.
/// - Output `seed` is an `int` (ARGB32), not `'#AARRGGBB'`.
class GatewayThemeReactImpl implements GatewayThemeReact {
  GatewayThemeReactImpl({
    required ServiceThemeReact service,
    ServiceTheme? themeService,
    ErrorMapper? errorMapper,
  })  : _service = service,
        _theme = themeService ?? const FakeServiceJocaaguraArchetypeTheme(),
        _mapper = errorMapper ?? const DefaultErrorMapper();

  final ServiceThemeReact _service;
  final ServiceTheme _theme;
  final ErrorMapper _mapper;

  static const String _locRead = 'GatewayThemeReactImpl.read';
  static const String _locWrite = 'GatewayThemeReactImpl.write';
  static const String _locWatch = 'GatewayThemeReactImpl.watch';

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async {
    try {
      final Map<String, dynamic> norm = _normalize(_service.themeStateJson);
      _smokeTest(norm);
      return Right<ErrorItem, Map<String, dynamic>>(norm);
    } catch (e, st) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, st, location: _locRead),
      );
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  ) async {
    try {
      final Map<String, dynamic> norm = _normalize(json);
      _smokeTest(norm);
      // broadcast normalized json to the bus
      _service.updateTheme(norm);
      return Right<ErrorItem, Map<String, dynamic>>(norm);
    } catch (e, st) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, st, location: _locWrite),
      );
    }
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch() async* {
    await for (final Map<String, dynamic> raw in _service.themeStream) {
      try {
        final Map<String, dynamic> norm = _normalize(raw);
        _smokeTest(norm);
        yield Right<ErrorItem, Map<String, dynamic>>(norm);
      } catch (e, st) {
        yield Left<ErrorItem, Map<String, dynamic>>(
          _mapper.fromException(e, st, location: _locWatch),
        );
      }
    }
  }

  // ---------- helpers (copiados/adaptados del GatewayImperative) ----------

  Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    // mode
    final String modeName = (json['mode'] as String?) ?? ThemeMode.system.name;
    final ThemeMode mode = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == modeName,
      orElse: () => ThemeMode.system,
    );

    // seed: int | '#AARRGGBB' | Color
    final dynamic rawSeed = json['seed'];
    final int seedInt = switch (rawSeed) {
      final int v => v & 0xFFFFFFFF,
      final String s => _parseHexARGB32Safe(s) ?? 0xFF6750A4,
      final Color c => c.toARGB32() & 0xFFFFFFFF,
      _ => 0xFF6750A4,
    };
    final Color seed = Color(seedInt);

    // useM3
    final bool useM3 = (json['useM3'] ??= true) == true;

    // textScale (clamp)
    final double textScale =
        ((json['textScale'] as num?)?.toDouble() ?? 1.0).clamp(0.8, 1.6);

    // preset
    final String preset = (json['preset'] as String?) ?? 'brand';

    // overrides (ColorScheme)
    Map<String, dynamic>? overrides;
    final dynamic rawOverrides = json['overrides'];
    if (rawOverrides is ThemeOverrides) {
      overrides = rawOverrides.toJson();
    } else if (rawOverrides is Map<String, dynamic>) {
      final ThemeOverrides? o =
          ThemeOverrides.fromJson(Map<String, dynamic>.from(rawOverrides));
      overrides = o?.toJson();
    }

    // textOverrides (TextTheme)
    Map<String, dynamic>? textOverrides;
    final dynamic rawTextOv = json['textOverrides'];
    if (rawTextOv is TextThemeOverrides) {
      textOverrides = rawTextOv.toJson();
    } else if (rawTextOv is Map<String, dynamic>) {
      final TextThemeOverrides? t =
          TextThemeOverrides.fromJson(Map<String, dynamic>.from(rawTextOv));
      textOverrides = t?.toJson();
    }

    return <String, dynamic>{
      'mode': mode.name,
      'seed': seed.toARGB32() & 0xFFFFFFFF,
      'useM3': useM3,
      'textScale': textScale,
      'preset': preset,
      if (overrides != null) 'overrides': overrides,
      if (textOverrides != null) 'textOverrides': textOverrides,
    };
  }

  int? _parseHexARGB32Safe(String s) {
    final String hex = s.startsWith('#') ? s.substring(1) : s;
    if (hex.length != 8) {
      return null;
    }
    try {
      return int.parse(hex, radix: 16) & 0xFFFFFFFF;
    } catch (_) {
      return null;
    }
  }

  void _smokeTest(Map<String, dynamic> json) {
    final ThemeState s = ThemeState.fromJson(json);
    _theme.lightTheme(s);
    _theme.darkTheme(s);
  }
}
