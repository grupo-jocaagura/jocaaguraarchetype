part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reactive source of truth for theme state as canonical JSON.
///
/// ## Behavior
/// - Exposes a broadcast-like `themeStream` and the current `themeStateJson`.
/// - `updateTheme(json)` emits **only** if the provided map is **not the same
///   instance** as the current one (identity check). Providing a new instance,
///   even with deep-equal contents, **will emit**.
/// - You can plug processing functions into the stream via
///   `addFunctionToProcessValueOnStream(key, fn)`. Removal is done by `key`.
///
/// ## Notes
/// - JSON shape is not validated here; produce it via `ThemeState.toJson()`
///   or your canonical serializer upstream.
/// - `executeNow` parameters in add/delete are currently ignored.
/// - Call `dispose()` to release resources.
///
/// ## Example
/// ```dart
/// class FakeServiceThemeReact extends ServiceThemeReact {
///   void toggleDark() {
///     final Map<String, dynamic> current = Map<String, dynamic>.from(themeStateJson);
///     current['mode'] = (current['mode'] == 'dark') ? 'light' : 'dark';
///     updateTheme(current); // emits because it's a new Map instance
///   }
/// }
///
/// void main() {
///   final FakeServiceThemeReact s = FakeServiceThemeReact();
///   final StreamSubscription sub = s.themeStream.listen((m) {
///     // react to theme json...
///   });
///   s.toggleDark();
///   s.dispose();
///   sub.cancel();
/// }
/// ```
abstract class ServiceThemeReact {
  final BlocGeneral<Map<String, dynamic>> _themeStateJson =
      BlocGeneral<Map<String, dynamic>>(ThemeState.defaults.toJson());

  bool _disposed = false;

  Stream<Map<String, dynamic>> get themeStream => _themeStateJson.stream;
  Map<String, dynamic> get themeStateJson => _themeStateJson.value;

  void updateTheme(Map<String, dynamic> json) {
    if (_disposed) {
      return;
    }
    if (identical(themeStateJson, json)) {
      return;
    }
    _themeStateJson.value = json;
  }

  void addFunctionToProcessValueOnStream(
    String key,
    Function(Map<String, dynamic> val) function, [
    bool executeNow = false,
  ]) {
    _themeStateJson.addFunctionToProcessTValueOnStream(key, function);
  }

  void deleteFunctionToProcessValueOnStream(
    String key,
  ) {
    _themeStateJson.deleteFunctionToProcessTValueOnStream(key);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _themeStateJson.dispose();
  }
}
