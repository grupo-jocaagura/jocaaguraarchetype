part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

@immutable
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.seed,
    required this.useMaterial3,
    this.textScale = 1.0,
    this.preset = 'brand',
  });
  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final String modeName = (json['mode'] as String?) ?? 'system';
    return ThemeState(
      mode: ThemeMode.values.firstWhere(
        (ThemeMode e) => e.name == modeName,
        orElse: () => ThemeMode.system,
      ),
      seed: Color((json['seed'] as int?) ?? 0xFF6750A4),
      useMaterial3: (json['useM3'] as bool?) ?? true,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      preset: (json['preset'] as String?) ?? 'brand',
    );
  }

  final ThemeMode mode; // system/light/dark
  final Color seed; // semilla para ColorScheme.fromSeed
  final bool useMaterial3; // toggle M3
  final double textScale; // opcional
  final String preset; // nombre de preset (brand/…​)

  ThemeState copyWith({
    ThemeMode? mode,
    Color? seed,
    bool? useMaterial3,
    double? textScale,
    String? preset,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seed: seed ?? this.seed,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      textScale: textScale ?? this.textScale,
      preset: preset ?? this.preset,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mode': mode.name,
        'seed': seed.toARGB32(),
        'useM3': useMaterial3,
        'textScale': textScale,
        'preset': preset,
      };

  /// Fallback inicial seguro antes de cargar persistencia.
  static const ThemeState defaults = ThemeState(
    mode: ThemeMode.system,
    seed: Color(0xFF6750A4),
    useMaterial3: true,
  );
}
