part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Bloc to switch AppConfig at runtime.
/// Keeps navigation stack by default; rethemes and rewires blocs/services.
///
/// ### Example
/// ```dart
/// final blocAppConfig = BlocAppConfig(initial: AppConfig.dev());
/// blocAppConfig.switchTo(AppConfig.dev(featureFlags: {'demo:projectorMode': false}));
/// ```
class BlocAppConfig {
  BlocAppConfig({required AppConfig initial}) : _current = initial;
  AppConfig _current;
  final StreamController<AppConfig> _controller =
      StreamController<AppConfig>.broadcast();

  AppConfig get state => _current;
  Stream<AppConfig> get stream => _controller.stream;

  /// Switch config in runtime. If [resetStack] is true, AppManager should clear stack.
  void switchTo(AppConfig next, {bool resetStack = false}) {
    _current = next;
    _controller.add(_current);
    // AppManager.applyConfig(next, resetStack: resetStack) will be called by the app shell.
  }

  void dispose() => _controller.close();
}
