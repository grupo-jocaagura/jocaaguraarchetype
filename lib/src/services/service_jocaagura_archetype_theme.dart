part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Service that builds [ThemeData] from a [ThemeState].
///
/// Encapsulates Material 3 flags, seed color, text scale, and optional
/// component overrides. Pure function: no I/O nor side effects.
///
/// ### Example
/// ```dart
/// final ServiceJocaaguraArchetypeTheme service = ServiceJocaaguraArchetypeTheme();
/// final ThemeData theme = service.build(
///   const ThemeState(mode: ThemeMode.dark, useMaterial3: true),
/// );
/// ```
class ServiceJocaaguraArchetypeTheme extends ServiceTheme {
  const ServiceJocaaguraArchetypeTheme();

  @override
  ColorScheme schemeFromSeed(Color seed, Brightness b) =>
      ColorScheme.fromSeed(seedColor: seed, brightness: b);

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
    final ColorScheme scheme = schemeFromSeed(state.seed, b);
    return ThemeData.from(colorScheme: scheme, useMaterial3: state.useMaterial3)
        .copyWith(visualDensity: VisualDensity.standard);
  }

  @override
  ThemeData lightTheme(ThemeState state) => ThemeData.from(
        colorScheme: schemeFromSeed(state.seed, Brightness.light),
        useMaterial3: state.useMaterial3,
      );

  @override
  ThemeData darkTheme(ThemeState state) => ThemeData.from(
        colorScheme: schemeFromSeed(state.seed, Brightness.dark),
        useMaterial3: state.useMaterial3,
      );
}
