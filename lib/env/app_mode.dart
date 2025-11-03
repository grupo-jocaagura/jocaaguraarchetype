part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Defines the application runtime mode.
///
/// Usage
/// ```dart
/// const String raw = String.fromEnvironment('APP_MODE', defaultValue: 'dev');
/// final AppMode mode = parseAppMode(raw);
/// ```
enum AppMode { dev, qa, prod }

/// Maps a raw `APP_MODE` string into [AppMode].
/// Unknown values fallback to [AppMode.dev].
AppMode parseAppMode(String raw) {
  switch (raw) {
    case 'prod':
      return AppMode.prod;
    case 'qa':
      return AppMode.qa;
    case 'dev':
    default:
      return AppMode.dev;
  }
}
