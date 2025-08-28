part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class ServiceTheme {
  const ServiceTheme();

  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  });
  ThemeData lightTheme(ThemeState state);
  ThemeData darkTheme(ThemeState state);
  ColorScheme schemeFromSeed(Color seed, Brightness brightness);

  /// Para demos/tests; en Fake puedes hacerlo determinista
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
