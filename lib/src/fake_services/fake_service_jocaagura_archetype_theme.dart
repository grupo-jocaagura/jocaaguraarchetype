part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Deterministic fake for building [ThemeData] during development and tests.
///
/// Use this fake when you need predictable ThemeData without platform-specific
/// quirks. It should not access I/O nor read runtime settings.
///
/// ### Example
/// ```dart
/// final ServiceJocaaguraArchetypeTheme service = FakeServiceJocaaguraArchetypeTheme();
/// final ThemeData theme = service.build(const ThemeState.light());
/// ```
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
