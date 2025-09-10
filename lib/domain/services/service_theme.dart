part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Contrato para construir temas de la aplicación a partir de un [ThemeState].
///
/// Implementaciones típicas deben ser **puras** (sin efectos colaterales) e
/// **idempotentes**: el mismo `state` y `platformBrightness` deben producir el
/// mismo resultado.
///
/// Recomendación:
/// - `toThemeData` debe delegar en [lightTheme] o [darkTheme] según
///   [platformBrightness] o reglas propias del `state`.
/// - [schemeFromSeed] debe derivar un [ColorScheme] a partir de un color
///   semilla y un [Brightness] concreto.
/// - [colorRandom] existe para **demos/tests**; en un Fake puede hacerse
///   determinista.
///
/// Las implementaciones **no** deben lanzar excepciones en casos normales;
/// validaciones de negocio deben ocurrir antes de invocar el servicio.
abstract class ServiceTheme {
  /// Crea un contrato de servicio de temas.
  const ServiceTheme();

  /// Construye un [ThemeData] a partir de [state], considerando el brillo de
  /// la plataforma ([platformBrightness]).
  ///
  /// **Contratos:**
  /// - Debe ser **puro** e **idempotente** para los mismos parámetros.
  /// - No debe mutar [state].
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  });

  /// Retorna el tema claro para el [state] dado.
  ///
  /// Debe ser **puro** e **idempotente**.
  ThemeData lightTheme(ThemeState state);

  /// Retorna el tema oscuro para el [state] dado.
  ///
  /// Debe ser **puro** e **idempotente**.
  ThemeData darkTheme(ThemeState state);

  /// Deriva un [ColorScheme] a partir de un color semilla [seed] y el
  /// [brightness] deseado.
  ///
  /// **Precondición:** [seed] válido (ARGB/HEX correcto).
  /// **Postcondición:** `result.brightness == brightness`.
  ColorScheme schemeFromSeed(Color seed, Brightness brightness);

  /// Devuelve un color pseudoaleatorio.
  ///
  /// Útil para **demos/tests**. En Fakes de prueba puede implementarse de forma
  /// determinista. Evitar su uso en rutas críticas de producción para mantener
  /// reproducibilidad.
  Color colorRandom() {
    final Random rnd = Random();
    return Color.fromRGBO(
      rnd.nextInt(256),
      rnd.nextInt(256),
      rnd.nextInt(256),
      1,
    );
  }
}
