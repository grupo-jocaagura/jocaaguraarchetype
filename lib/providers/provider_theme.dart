part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A provider class for accessing theme-related functionalities.
///
/// The `ProviderTheme` class serves as a wrapper around the `ServiceTheme`,
/// exposing its methods for theme and color manipulation. It acts as a bridge
/// between the application's state and the underlying theme service.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/provider_theme.dart';
/// import 'package:jocaaguraarchetype/service_theme.dart';
///
/// void main() {
///   final providerTheme = ProviderTheme(ServiceTheme());
///
///   // Generate a random color
///   final randomColor = providerTheme.colorRandom();
///   print('Random Color: $randomColor');
///
///   // Create a MaterialColor from RGB
///   final materialColor = providerTheme.materialColorFromRGB(100, 150, 200);
///   print('MaterialColor: ${materialColor.shade500}');
/// }
/// ```
class ProviderTheme extends EntityProvider {
  /// Creates an instance of `ProviderTheme` with the provided [serviceTheme].
  ///
  /// The `serviceTheme` parameter provides the underlying functionality for
  /// theme-related operations.
  const ProviderTheme(this.serviceTheme);

  /// The underlying service for theme-related operations.
  final ServiceTheme serviceTheme;

  /// Generates a `MaterialColor` from the provided RGB values.
  ///
  /// Delegates to [ServiceTheme.materialColorFromRGB].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final providerTheme = ProviderTheme(ServiceTheme());
  /// final materialColor = providerTheme.materialColorFromRGB(255, 100, 50);
  /// print('MaterialColor: ${materialColor.shade500}');
  /// ```
  MaterialColor materialColorFromRGB(int r, int g, int b) {
    return serviceTheme.materialColorFromRGB(r, g, b);
  }

  /// Returns a darker version of the given [color].
  ///
  /// Delegates to [ServiceTheme.getDarker].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final providerTheme = ProviderTheme(ServiceTheme());
  /// final color = Color(0xFF2196F3);
  /// final darkerColor = providerTheme.getDarker(color, amount: 0.2);
  /// print('Darker Color: $darkerColor');
  /// ```
  Color getDarker(Color color, {double amount = .1}) {
    return serviceTheme.getDarker(color, amount: amount);
  }

  /// Returns a lighter version of the given [color].
  ///
  /// Delegates to [ServiceTheme.getLighter].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final providerTheme = ProviderTheme(ServiceTheme());
  /// final color = Color(0xFF2196F3);
  /// final lighterColor = providerTheme.getLighter(color, amount: 0.2);
  /// print('Lighter Color: $lighterColor');
  /// ```
  Color getLighter(Color color, {double amount = .1}) {
    return serviceTheme.getLighter(color, amount: amount);
  }

  /// Creates a custom `ThemeData` from the given [colorScheme] and [textTheme].
  ///
  /// Delegates to [ServiceTheme.customThemeFromColorScheme].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final providerTheme = ProviderTheme(ServiceTheme());
  /// final theme = providerTheme.customThemeFromColorScheme(
  ///   ColorScheme.light(),
  ///   TextTheme(),
  ///   false,
  /// );
  /// print('Custom Theme: $theme');
  /// ```
  ThemeData customThemeFromColorScheme(
    ColorScheme colorScheme,
    TextTheme textTheme, [
    bool isDark = false,
  ]) {
    return serviceTheme.customThemeFromColorScheme(
      colorScheme,
      textTheme,
      isDark,
    );
  }

  /// Generates a random `Color`.
  ///
  /// Delegates to [ServiceTheme.colorRandom].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final providerTheme = ProviderTheme(ServiceTheme());
  /// final randomColor = providerTheme.colorRandom();
  /// print('Random Color: $randomColor');
  /// ```
  Color colorRandom() {
    return serviceTheme.colorRandom();
  }
}
