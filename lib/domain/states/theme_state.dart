// File: lib/src/theme_state.dart
part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for ThemeState.
enum ThemeEnum {
  mode,
  seed,
  useM3,
  textScale,
  preset,
  overrides,
  createdAt,
}

/// JSON keys for ThemeOverrides payload.
enum ThemeOverridesEnum {
  light,
  dark,
}

/// JSON keys inside a ColorScheme serialization.
enum ColorSchemeEnum {
  brightness,
  primary,
  onPrimary,
  secondary,
  onSecondary,
  tertiary,
  onTertiary,
  error,
  onError,
  surface,
  onSurface,
  surfaceTint,
  outline,
  onSurfaceVariant,
  inverseSurface,
  inversePrimary,
}

/// Modela un estado de tema **inmutable** con serialización JSON **canónica**.
///
/// - Los colores se serializan **siempre** como `#AARRGGBB` en mayúsculas para
///   garantizar determinismo de round-trip (`toJson` → `fromJson` → `toJson`).
/// - `fromJson` acepta enteros ARGB heredados por compatibilidad, pero
///   re-serializa a HEX canónico en `toJson`.
/// - `createdAt` (opcional) se serializa en ISO8601 UTC si está presente y se
///   trata como **metadata**: queda **excluido** de `==` y `hashCode`.
///
/// ### Contratos
/// - `textScale` debe ser finito (`isFinite`). En caso contrario lanza
///   `FormatException('ThemeState.textScale invalid')`.
/// - Si `mode` está ausente, vacío o inválido, se usa `ThemeMode.system`.
///
/// ### Ejemplo mínimo
/// ```dart
/// void main() {
///   final ThemeState s = ThemeState.defaults.copyWith(
///     mode: ThemeMode.dark,
///     seed: const Color(0xFF0061A4),
///     createdAt: DateTime.now().toUtc(),
///   );
///   final Map<String, dynamic> json = s.toJson();
///   final ThemeState round = ThemeState.fromJson(json);
///   // createdAt es metadata: no participa en igualdad/hashing.
///   assert(s == round);
/// }
/// ```
@immutable
class ThemeState {
  /// Crea una instancia inmutable de [ThemeState].
  ///
  /// - [mode]: Modo de tema (system/light/dark).
  /// - [seed]: Color semilla para generar paletas.
  /// - [useMaterial3]: `true` si se habilita Material 3.
  /// - [textScale]: Escala tipográfica (por defecto `1.0`, debe ser finita).
  /// - [preset]: Nombre del preset (por defecto `'brand'` si falta/está vacío en JSON).
  /// - [overrides]: Sobrescrituras de `ColorScheme` por tema claro/oscuro.
  /// - [createdAt]: Marca de tiempo en UTC ISO8601 (metadata, no afecta igualdad).
  const ThemeState({
    required this.mode,
    required this.seed,
    required this.useMaterial3,
    this.textScale = 1.0,
    this.preset = 'brand',
    this.overrides,
    this.createdAt,
  });

  /// Deserializa un [ThemeState] desde JSON con reglas de **retrocompatibilidad**.
  ///
  /// Acepta `mode` como `system|light|dark`. Si está ausente, vacío o no coincide,
  /// se usa `ThemeMode.system` (vía `orElse`).
  ///
  /// - `seed` admite `int` ARGB legado o `String` HEX. Se normaliza a HEX.
  /// - `useM3` y `textScale` se leen estrictamente; `textScale` debe ser finito.
  /// - `preset` vacío se normaliza a `'brand'`.
  /// - `overrides` se mapea con [ThemeOverrides.fromJson] si está presente.
  /// - `createdAt` se interpreta como instante UTC si existe.
  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final String modeName =
        UtilsForTheme.asStringOrEmpty(json, ThemeEnum.mode.name);
    final ThemeMode parsedMode = ThemeMode.values.firstWhere(
      (ThemeMode themeMode) =>
          themeMode.name == (modeName.isNotEmpty ? modeName : 'system'),
      orElse: () => ThemeMode.system,
    );

    final dynamic seedRaw = json[ThemeEnum.seed.name];
    final Color parsedSeed = seedRaw == null
        ? const Color(0xFF6750A4)
        : UtilsForTheme.parseColorCanonical(seedRaw, path: ThemeEnum.seed.name);

    final bool parsedM3 =
        UtilsForTheme.asBoolStrict(json, ThemeEnum.useM3.name);

    final double parsedScale =
        UtilsForTheme.asDoubleStrict(json, ThemeEnum.textScale.name, 1.0);
    if (!parsedScale.isFinite) {
      throw const FormatException('ThemeState.textScale invalid');
    }

    final String prevPreset =
        UtilsForTheme.asStringOrEmpty(json, ThemeEnum.preset.name);
    final String parsedPreset = prevPreset.isEmpty ? 'brand' : prevPreset;

    final ThemeOverrides? ov = json[ThemeEnum.overrides.name] == null
        ? null
        : ThemeOverrides.fromJson(
            UtilsForTheme.asMapStrict(json, ThemeEnum.overrides.name),
          );

    final DateTime? parsedCreatedAt =
        UtilsForTheme.asUtcInstant(json, ThemeEnum.createdAt.name);

    return ThemeState(
      mode: parsedMode,
      seed: parsedSeed,
      useMaterial3: parsedM3,
      textScale: parsedScale,
      preset: parsedPreset,
      overrides: ov,
      createdAt: parsedCreatedAt,
    );
  }

  /// Modo de tema actual (system/light/dark).
  final ThemeMode mode;

  /// Color semilla a partir del que se derivan esquemas de color.
  final Color seed;

  /// Habilita o no Material 3.
  final bool useMaterial3;

  /// Factor de escala tipográfica (debe ser finito).
  final double textScale;

  /// Nombre del preset (por defecto `'brand'` si JSON lo omite o viene vacío).
  final String preset;

  /// Sobrescrituras explícitas de esquema de color.
  final ThemeOverrides? overrides;

  /// Marca de tiempo opcional en UTC (metadata; se ignora en `==` y `hashCode`).
  final DateTime? createdAt;

  /// Crea una copia con cambios puntuales manteniendo inmutabilidad.
  ThemeState copyWith({
    ThemeMode? mode,
    Color? seed,
    bool? useMaterial3,
    double? textScale,
    String? preset,
    ThemeOverrides? overrides,
    DateTime? createdAt,
  }) =>
      ThemeState(
        mode: mode ?? this.mode,
        seed: seed ?? this.seed,
        useMaterial3: useMaterial3 ?? this.useMaterial3,
        textScale: textScale ?? this.textScale,
        preset: preset ?? this.preset,
        overrides: overrides ?? this.overrides,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Serializa el estado a JSON en formato canónico.
  ///
  /// - `seed` se emite como `#AARRGGBB`.
  /// - `createdAt` (si existe) se emite como ISO8601 en UTC.
  Map<String, dynamic> toJson() => <String, dynamic>{
        ThemeEnum.mode.name: mode.name,
        ThemeEnum.seed.name: UtilsForTheme.colorToHex(seed),
        ThemeEnum.useM3.name: useMaterial3,
        ThemeEnum.textScale.name: textScale,
        ThemeEnum.preset.name: preset,
        ThemeEnum.overrides.name: overrides?.toJson(),
        if (createdAt != null)
          ThemeEnum.createdAt.name: createdAt!.toUtc().toIso8601String(),
      };

  /// Estado por defecto.
  static const ThemeState defaults = ThemeState(
    mode: ThemeMode.system,
    seed: Color(0xFF6750A4),
    useMaterial3: true,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is ThemeState) {
      return mode == other.mode &&
          seed == other.seed &&
          useMaterial3 == other.useMaterial3 &&
          textScale == other.textScale &&
          preset == other.preset &&
          overrides == other.overrides;
    }
    return false;
  }

  @override
  int get hashCode {
    int h = mode.hashCode ^ seed.hashCode ^ useMaterial3.hashCode;
    h = 0x1fffffff & (h ^ textScale.hashCode);
    h = 0x1fffffff & (h ^ preset.hashCode);
    h = 0x1fffffff & (h ^ (overrides?.hashCode ?? 0));
    return h;
  }
}
