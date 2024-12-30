/// An enumeration representing different screen sizes for responsive design.
///
/// The `ScreenSizeEnum` provides values for categorizing devices based on their
/// screen dimensions. It is commonly used in responsive design to adapt layouts
/// and behaviors according to the device type.
///
/// ## Values
///
/// - `movil`: Represents mobile devices (e.g., phones).
/// - `tablet`: Represents tablet devices.
/// - `desktop`: Represents desktop or laptop devices.
/// - `tv`: Represents TV or large screen devices.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/screen_size_enum.dart';
///
/// void main() {
///   final ScreenSizeEnum screenSize = ScreenSizeEnum.desktop;
///
///   switch (screenSize) {
///     case ScreenSizeEnum.movil:
///       print('Device is a mobile.');
///       break;
///     case ScreenSizeEnum.tablet:
///       print('Device is a tablet.');
///       break;
///     case ScreenSizeEnum.desktop:
///       print('Device is a desktop.');
///       break;
///     case ScreenSizeEnum.tv:
///       print('Device is a TV.');
///       break;
///   }
/// }
/// ```
enum ScreenSizeEnum {
  /// Represents mobile devices (e.g., phones).
  movil,

  /// Represents tablet devices.
  tablet,

  /// Represents desktop or laptop devices.
  desktop,

  /// Represents TV or large screen devices.
  tv,
}
