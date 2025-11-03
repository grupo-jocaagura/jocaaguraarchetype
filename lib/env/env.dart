part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Minimal environment reader intended to be **extended per project**.
/// Only carries the mode; concrete apps should subclass and add their own keys.
///
/// Example
/// ```dart
/// class MyEnv extends Env {
///   static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
/// }
/// final AppMode mode = Env.mode;
/// ```
class Env {
  static const String _mode =
      String.fromEnvironment('APP_MODE', defaultValue: 'dev');

  /// True when running against QA backend/services.
  static bool get isQa => _mode == 'qa';

  /// True when running against PROD backend/services.
  static bool get isProd => _mode == 'prod';

  /// Current [AppMode] parsed from `APP_MODE`.
  static AppMode get mode => parseAppMode(_mode);
}
