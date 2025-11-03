part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class AppConfigBuilder {
  static AppConfig byMode({
    required AppMode mode,
    required AppConfig production,
    required AppConfig qa,
    required AppConfig dev,
  }) {
    switch (mode) {
      case AppMode.prod:
        return production;
      case AppMode.qa:
        return production;
      case AppMode.dev:
        return dev;
    }
  }
}
