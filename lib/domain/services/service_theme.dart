part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Contract for building application themes from a [ThemeState].
///
/// Implementations should be **pure** and **idempotent**: for the same
/// `[state]` and `platformBrightness`, `ThemeData` output must be identical.
///
/// Guidance
/// - `toThemeData` should delegate to [lightTheme] or [darkTheme] based on
///   `platformBrightness` and/or rules encoded in `state` (e.g. explicit mode).
/// - [schemeFromSeed] must derive a [ColorScheme] from a seed [Color] and a
///   concrete [Brightness].
/// - [colorRandom] exists for **demos/tests**. Production implementations
///   should avoid randomness in critical code paths to keep reproducibility.
///
/// Business validation should happen **before** calling this service; normal
/// usage should not throw.
///
/// Implementers are responsible for honoring `state.overrides` and
/// `state.textOverrides` when composing the final `ThemeData`.
abstract class ServiceTheme {
  /// Creates a theme service contract.
  const ServiceTheme();

  /// Builds a [ThemeData] from [state], considering the ambient brightness
  /// of the platform ([platformBrightness]).
  ///
  /// Contracts
  /// - Must be **pure** and **idempotent** given the same inputs.
  /// - Must not mutate [state] or perform side effects.
  /// - Should internally delegate to [lightTheme] or [darkTheme].
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  });

  /// Returns the light theme for the given [state].
  ///
  /// Contracts
  /// - Must be **pure** and **idempotent**.
  /// - Should apply `state.overrides` / `state.textOverrides` if present.
  ThemeData lightTheme(ThemeState state);

  /// Returns the dark theme for the given [state].
  ///
  /// Contracts
  /// - Must be **pure** and **idempotent**.
  /// - Should apply `state.overrides` / `state.textOverrides` if present.
  ThemeData darkTheme(ThemeState state);

  /// Derives a [ColorScheme] from a seed [Color] and the desired [brightness].
  ///
  /// Precondition:
  /// - [seed] is a valid ARGB color.
  ///
  /// Postconditions:
  /// - `result.brightness == brightness`.
  /// - The scheme is suitable for building `ThemeData` consistently with
  ///   the implementation’s palette strategy.
  ColorScheme schemeFromSeed(Color seed, Brightness brightness);

  /// Returns a pseudo-random, opaque color.
  ///
  /// Intended for **demos/tests**. Test doubles may implement this deterministically.
  /// Avoid using randomness in production-critical paths to preserve reproducibility.
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
