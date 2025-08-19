part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Utilitario UI-only para construir ThemeData desde ThemeState.
/// No forma parte del dominio ni del Bloc; no requiere DI.
class ThemeDataUtils {
  const ThemeDataUtils._(); // no instanciable

  static ColorScheme _scheme(Color seed, Brightness b) =>
      ColorScheme.fromSeed(seedColor: seed, brightness: b);

  static ThemeData light(ThemeState s) {
    final ThemeData base = ThemeData.from(
      colorScheme: _scheme(s.seed, Brightness.light),
      useMaterial3: s.useMaterial3,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: s.textScale),
      visualDensity: VisualDensity.standard,
    );
  }

  static ThemeData dark(ThemeState s) {
    final ThemeData base = ThemeData.from(
      colorScheme: _scheme(s.seed, Brightness.dark),
      useMaterial3: s.useMaterial3,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontSizeFactor: s.textScale),
      visualDensity: VisualDensity.standard,
    );
  }
}
