part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Implementación de Gateway en memoria.
/// - Usa ServiceTheme para "smoke-test" (asegurar que el estado es renderizable).
/// - Sanea/normaliza payloads (mode/seed/useM3/textScale/preset).
/// - Mapea errores con DefaultErrorMapper.
///
/// Pensado para dev/example. Futuras variantes (prefs/file/http) pueden
/// reutilizar los mismos helpers de normalización.
class GatewayThemeImpl implements GatewayTheme {
  GatewayThemeImpl({
    ServiceTheme? themeService,
    ErrorMapper? errorMapper,
    Map<String, dynamic>? initial,
  })  : _theme = themeService ?? const FakeServiceJocaaguraArchetypeTheme(),
        _mapper = errorMapper ?? DefaultErrorMapper(),
        _doc = initial == null ? null : Map<String, dynamic>.from(initial);

  final ServiceTheme _theme;
  final ErrorMapper _mapper;

  Map<String, dynamic>? _doc;

  static const String _locRead = 'GatewayThemeImpl.read';
  static const String _locWrite = 'GatewayThemeImpl.write';

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
      // Devuelve copia saneada
      final Map<String, dynamic> norm = _normalize(_doc!);
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
      _smokeTest(norm); // valida que es renderizable
      _doc = Map<String, dynamic>.from(norm);
      return Right<ErrorItem, Map<String, dynamic>>(_doc!);
    } catch (e, st) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(e, st, location: _locWrite),
      );
    }
  }

  // ---------- helpers ----------

  Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    // mode
    final String modeName = (json['mode'] as String?) ?? ThemeMode.system.name;
    final ThemeMode mode = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == modeName,
      orElse: () => ThemeMode.system,
    );

    // seed (int ARGB32)
    final int seedInt = switch (json['seed']) {
      final int v => v,
      _ => 0xFF6750A4,
    };
    final Color seed = Color(seedInt & 0xFFFFFFFF);

    // useM3
    final bool useM3 = (json['useM3'] ??= true) == true;

    final double textScale =
        ((json['textScale'] as num?)?.toDouble() ?? 1.0).clamp(0.8, 1.6);

    final String preset = (json['preset'] as String?) ?? 'brand';

    final dynamic rawOverrides = json['overrides'];
    Map<String, dynamic>? overrides;
    if (rawOverrides is ThemeOverrides) {
      overrides = rawOverrides.toJson();
    } else if (rawOverrides is Map<String, dynamic>) {
      overrides = Map<String, dynamic>.from(rawOverrides);
    } else {
      overrides = null;
    }

    return <String, dynamic>{
      'mode': mode.name,
      'seed': seed.toARGB32(),
      'useM3': useM3,
      'textScale': textScale,
      'preset': preset,
      if (overrides != null) 'overrides': overrides, // 👈 mantenerlo
    };
  }

  void _smokeTest(Map<String, dynamic> json) {
    final ThemeState s = ThemeState.fromJson(json);
    // Si esto lanzara por algún estado inválido, lo capturamos arriba y mapeamos.
    _theme.lightTheme(s);
    _theme.darkTheme(s);
  }
}
