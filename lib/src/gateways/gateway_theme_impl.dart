part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// In-memory implementation of [GatewayTheme].
///
/// Purpose
/// - Normalize and sanitize incoming payloads (`mode`, `seed`, `useM3`, `textScale`, `preset`)
///   and optional overrides (`overrides`, `textOverrides`).
/// - Run a lightweight *smoke test* with [ServiceTheme] to ensure the normalized
///   state can be rendered into `ThemeData` (both light and dark).
/// - Map thrown exceptions into domain errors via [ErrorMapper] (defaults to [DefaultErrorMapper]).
///
/// Characteristics
/// - **Scope:** development/examples. Future variants (prefs/file/http) can reuse the
///   same normalization helpers and smoke-test strategy.
/// - **Persistence:** in-memory only; not shared across isolates; not durable.
/// - **Normalization rules:**
///   - `mode`: falls back to `ThemeMode.system` when missing/unknown.
///   - `seed`: accepts ARGB `int`, canonical HEX `#AARRGGBB`, or `Color`; default `0xFF6750A4`.
///   - `useM3`: defaults to `true`.
///   - `textScale`: coerced to `double` and **clamped to `[0.8, 1.6]`**.
///   - `preset`: defaults to `'brand'`.
///   - `overrides` / `textOverrides`: accept either their typed objects or `Map<String, dynamic>`.
///     Both are normalized to canonical JSON via their `toJson()`.
///
/// Contracts
/// - **Smoke test:** the normalized payload must be convertible to [ThemeState] and renderable
///   via `_theme.lightTheme(state)` and `_theme.darkTheme(state)`. Any failure is mapped to [ErrorItem].
/// - **Read semantics:** returns `ERR_NOT_FOUND` when nothing has been persisted yet.
/// - **Write semantics:** persists the **normalized** payload and echoes it back.
///
/// Example
/// ```dart
/// void main() async {
///   final GatewayTheme gw = GatewayThemeImpl(); // uses FakeServiceJocaaguraArchetypeTheme + DefaultErrorMapper
///
///   // Write a minimal payload (HEX seed; M3 enabled by default; clamped textScale)
///   final writeEither = await gw.write(<String, dynamic>{
///     'mode': ThemeMode.dark.name,
///     'seed': '#FF0061A4',
///     'textScale': 2.0, // will be clamped to 1.6
///     'preset': 'brand',
///   });
///
///   writeEither.fold(
///     (err) => print('write error: ${err.code} ${err.title}'),
///     (json) => print('persisted: $json'),
///   );
///
///   // Read back (Either<ErrorItem, Map>) and build ThemeState
///   final readEither = await gw.read();
///   readEither.fold(
///     (err) => print('read error: ${err.code}'),
///     (json) {
///       final ThemeState state = ThemeState.fromJson(json);
///       // At this point, ServiceTheme.lightTheme/darkTheme can build ThemeData successfully.
///       print('mode=${state.mode} seed=${state.seed}');
///     },
///   );
/// }
/// ```
class GatewayThemeImpl implements GatewayTheme {
  /// Creates an in-memory [GatewayTheme] gateway.
  ///
  /// - [themeService]: optional [ServiceTheme] used for smoke-testing renderability.
  ///   Defaults to [FakeServiceJocaaguraArchetypeTheme].
  /// - [errorMapper]: optional [ErrorMapper] to translate exceptions to [ErrorItem].
  ///   Defaults to [DefaultErrorMapper].
  /// - [initial]: optional initial payload to seed the in-memory store; it is copied
  ///   and **normalized** on first read/write.
  GatewayThemeImpl({
    ServiceTheme? themeService,
    ErrorMapper? errorMapper,
    Map<String, dynamic>? initial,
  })  : _theme = themeService ?? const FakeServiceJocaaguraArchetypeTheme(),
        _mapper = errorMapper ?? const DefaultErrorMapper(),
        _doc = initial == null ? null : Map<String, dynamic>.from(initial);

  final ServiceTheme _theme;
  final ErrorMapper _mapper;

  Map<String, dynamic>? _doc;

  static const String _locRead = 'GatewayThemeImpl.read';
  static const String _locWrite = 'GatewayThemeImpl.write';

  /// Reads the persisted theme payload (normalized) as `Either<ErrorItem, Map>`.
  ///
  /// Returns
  /// - `Right<Map<String, dynamic>>` with a **normalized** payload when present.
  /// - `Left<ErrorItem>` with code `ERR_NOT_FOUND` when there is no persisted theme.
  ///
  /// Behavior
  /// - Always normalizes the stored document before returning it.
  /// - Runs a smoke test (`_theme.lightTheme` / `_theme.darkTheme`) to guarantee renderability.
  ///   Errors are mapped via [_mapper] and surfaced as `Left`.
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read() async {
    try {
      if (_doc == null) {
        return Left<ErrorItem, Map<String, dynamic>>(
          const ErrorItem(
            title: 'Theme not found',
            code: 'ERR_NOT_FOUND',
            description: 'No persisted theme was found.',
            meta: <String, dynamic>{'location': _locRead},
          ),
        );
      }
      final Map<String, dynamic> norm = _normalize(_doc!);
      _smokeTest(norm);
      return Right<ErrorItem, Map<String, dynamic>>(norm);
    } catch (e, st) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, st, location: _locRead),
      );
    }
  }

  /// Writes and persists a theme payload after normalization and smoke-testing.
  ///
  /// Parameters
  /// - [json]: raw user/config payload. Accepts:
  ///   - `mode`: `String` (`ThemeMode.name`)
  ///   - `seed`: `int` ARGB, `String` `#AARRGGBB`, or `Color`
  ///   - `useM3`: `bool` (defaults to `true` if missing)
  ///   - `textScale`: `num` → coerced to `double` and clamped to `[0.8, 1.6]`
  ///   - `preset`: `String` (defaults to `'brand'`)
  ///   - `overrides`: [ThemeOverrides] or `Map<String, dynamic>`
  ///   - `textOverrides`: [TextThemeOverrides] or `Map<String, dynamic>`
  ///
  /// Returns
  /// - `Right<Map<String, dynamic>>` with the **persisted normalized** payload.
  /// - `Left<ErrorItem>` if normalization or smoke test fails; the error is mapped
  ///   via [_mapper] and includes `location: GatewayThemeImpl.write`.
  ///
  /// Notes
  /// - The stored value replaces the previous one entirely.
  /// - Numeric color values are persisted as **32-bit ARGB int**; HEX is accepted on input.
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  ) async {
    try {
      final Map<String, dynamic> norm = _normalize(json);
      _smokeTest(norm);
      _doc = Map<String, dynamic>.from(norm);
      return Right<ErrorItem, Map<String, dynamic>>(_doc!);
    } catch (e, st) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, st, location: _locWrite),
      );
    }
  }

  // ---------- helpers ----------

  /// Normalizes the raw input into a canonical JSON map expected by [ThemeState].
  ///
  /// See class-level *Normalization rules* for field-by-field behavior.
  Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    // mode
    final String modeName = (json['mode'] as String?) ?? ThemeMode.system.name;
    final ThemeMode mode = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == modeName,
      orElse: () => ThemeMode.system,
    );

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

    // textScale (bounded)
    final double textScale =
        ((json['textScale'] as num?)?.toDouble() ?? 1.0).clamp(0.8, 1.6);

    // preset
    final String preset = (json['preset'] as String?) ?? 'brand';

    // overrides (ColorScheme per scheme)
    final dynamic rawOverrides = json['overrides'];
    Map<String, dynamic>? overrides;
    if (rawOverrides is ThemeOverrides) {
      overrides = rawOverrides.toJson();
    } else if (rawOverrides is Map<String, dynamic>) {
      final ThemeOverrides? o = ThemeOverrides.fromJson(
        Map<String, dynamic>.from(rawOverrides),
      );
      overrides = o?.toJson();
    }

    final dynamic rawTextOv = json['textOverrides'];
    Map<String, dynamic>? textOverrides;
    if (rawTextOv is TextThemeOverrides) {
      textOverrides = rawTextOv.toJson();
    } else if (rawTextOv is Map<String, dynamic>) {
      final TextThemeOverrides? t = TextThemeOverrides.fromJson(
        Map<String, dynamic>.from(rawTextOv),
      );
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

  /// Parses a canonical HEX `#AARRGGBB` (or `AARRGGBB`) string into a 32-bit ARGB int.
  /// Returns `null` for invalid length or parse errors.
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

  /// Verifies that the normalized JSON can be converted to [ThemeState] and
  /// rendered into `ThemeData` for both light and dark schemes using [_theme].
  /// Any thrown exception is meant to be caught by callers and mapped to [ErrorItem].
  void _smokeTest(Map<String, dynamic> json) {
    final ThemeState s = ThemeState.fromJson(json);
    _theme.lightTheme(s);
    _theme.darkTheme(s);
  }
}
