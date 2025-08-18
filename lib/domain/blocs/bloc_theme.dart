part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A BLoC (Business Logic Component) for managing application themes.
///
/// The `BlocTheme` class manages the state of the application's theme using
/// reactive streams. It interacts with the `ProviderTheme` to generate and
/// modify themes dynamically.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// void main() {
///   final providerTheme = ProviderTheme(ServiceTheme());
///   final blocTheme = BlocTheme(providerTheme);
///
///   // Listen to theme changes
///   blocTheme.themeDataStream.listen((theme) {
///     print('Theme Updated: $theme');
///   });
///
///   // Set a custom theme
///   blocTheme.customThemeFromColorScheme(
///     ColorScheme.light(),
///     TextTheme(),
///   );
///
///   // Generate a random theme
///   blocTheme.randomTheme();
/// }
/// ```
class BlocTheme extends BlocModule {
  /// Creates an instance of `BlocTheme` with the given [providerTheme].
  ///
  /// The [providerTheme] is used to access theme-related functionalities.
  BlocTheme(this.providerTheme);

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'blocTheme';

  /// The underlying provider for theme functionalities.
  final ProviderTheme providerTheme;

  /// The internal controller for managing the theme state.
  final BlocGeneral<ThemeData> _themeDataController =
      BlocGeneral<ThemeData>(ThemeData());

  /// The current theme data.
  ///
  /// Accesses the latest theme data from the controller.
  ThemeData get themeData => _themeDataController.value;

  /// A stream of `ThemeData` that emits changes to the theme.
  ///
  /// Use this stream to listen to updates and reflect theme changes in the UI.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocTheme.themeDataStream.listen((theme) {
  ///   print('Theme Updated: $theme');
  /// });
  /// ```
  Stream<ThemeData> get themeDataStream => _themeDataController.stream;

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocTheme.dispose();
  /// ```
  @override
  void dispose() {
    _themeDataController.dispose();
  }

  /// Sets a custom theme based on the provided [colorScheme] and [textTheme].
  ///
  /// The [isDark] parameter determines if the theme should be dark or light.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocTheme.customThemeFromColorScheme(
  ///   ColorScheme.light(),
  ///   TextTheme(),
  ///   false,
  /// );
  /// ```
  void customThemeFromColorScheme(
    ColorScheme colorScheme,
    TextTheme textTheme, [
    bool isDark = false,
  ]) {
    _themeDataController.value = providerTheme.customThemeFromColorScheme(
      colorScheme,
      textTheme,
      isDark,
    );
  }

  /// Sets a custom theme based on the provided [primaryColor].
  ///
  /// Generates a theme using the [primaryColor] as the seed color.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocTheme.customThemeFromColor(Color(0xFF2196F3));
  /// ```
  void customThemeFromColor(Color primaryColor) {
    _themeDataController.value =
        providerTheme.serviceTheme.customThemeFromColorScheme(
      ColorScheme.fromSeed(seedColor: primaryColor),
      themeData.textTheme,
    );
  }

  /// Generates and sets a random theme.
  ///
  /// This method creates a theme using a random color as the primary color.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocTheme.randomTheme();
  /// ```
  void randomTheme() {
    customThemeFromColor(providerTheme.colorRandom());
  }
}
