part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class FakeServiceJocaaguraArchetypeTheme
    extends ServiceJocaaguraArchetypeTheme {
  const FakeServiceJocaaguraArchetypeTheme();
  @override
  Color colorRandom() => const Color(0xFF0066CC);
  @override
  ColorScheme schemeFromSeed(Color seed, Brightness b) =>
      ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC), brightness: b);
  @override
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  }) {
    final Brightness b = switch (state.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
    return ThemeData(
      brightness: b,
      colorScheme: schemeFromSeed(state.seed, b),
      useMaterial3: state.useMaterial3,
    );
  }
}
