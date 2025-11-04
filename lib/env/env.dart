part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Base Environment contract to be **extended per project**.
///
/// - `_mode` is **static** and resolved at compile time from `--dart-define`.
/// - Instance getters (`mode`, `isQa`, `isProd`) delegate to the static `_mode`,
///   so subclasses only add project-specific keys.
///
/// # Usage
/// ```dart
/// class MyEnv extends Env {
///   const MyEnv({
///     this.apiBaseUrl = const String.fromEnvironment('API_BASE_URL'),
///   });
///
///   /// Project-specific key.
///   final String apiBaseUrl;
/// }
///
/// void main() {
///   // Prefer explicit DI: pass an Env instance down your App layer.
///   const MyEnv env = MyEnv();
///   runApp(MyApp(env: env));
/// }
///
/// // Inside your AppManager / DI root:
/// class AppManager {
///   const AppManager({required this.env});
///   final Env env;
/// }
///
/// // Anywhere below, depend on Env via DI:
/// class ProductsRepository {
///   const ProductsRepository({required this.env});
///   final MyEnv env; // or Env if you want to keep it generic
///
///   Uri get baseUri => Uri.parse(env.apiBaseUrl);
/// }
/// ```
abstract class Env {
  /// Instance constructor (subclasses add their own keys).
  const Env([this.modeTest]);

  final String? modeTest;

  /// Raw mode from `--dart-define=APP_MODE=dev|qa|prod` (compile-time).
  static const String _mode =
      String.fromEnvironment('APP_MODE', defaultValue: 'dev');

  /// Instance: current [AppMode] (delegates to static).
  AppMode get mode => parseAppMode(modeTest ?? _mode);

  /// Instance: true when QA (delegates to static).
  bool get isQa => mode == AppMode.qa;

  /// Instance: true when PROD (delegates to static).
  bool get isProd => mode == AppMode.prod;
}

class DefaultEnv extends Env {
  const DefaultEnv(super.modeTest);
}

const Env defaultEnv = DefaultEnv(null);
