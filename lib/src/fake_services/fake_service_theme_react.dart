part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Demo/dev reactive provider that seeds the theme JSON bus with default
/// light/dark payloads and (optionally) text typography overrides, and can
/// auto-toggle between both every [period].
///
/// Notes
/// - It pushes raw JSON into the [ServiceThemeReact] bus. Canonicalization and
///   validation are handled downstream by `GatewayThemeReactImpl` and `Repository`.
/// - If you omit `lightJson`/`darkJson`, it builds minimal payloads based on
///   `ThemeState.defaults` with `mode: light/dark`.
/// - If `textOverridesJson` is provided, it is merged into both light/dark
///   payloads under the `textOverrides` key (non-destructive).
///
/// Example
/// ```dart
/// final service = FakeServiceThemeReact(
///   lightJson: {
///     'mode': 'light',
///     'seed': '#FF6750A4',
///     'useM3': true,
///     'textScale': 1.0,
///     'preset': 'brand',
///   },
///   darkJson: {
///     'mode': 'dark',
///     'seed': '#FF6750A4',
///     'useM3': true,
///     'textScale': 1.0,
///     'preset': 'brand',
///   },
///   textOverridesJson: const TextThemeOverrides(
///     light: TextTheme(
///       bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
///     ),
///     dark: TextTheme(
///       bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
///     ),
///   ).toJson(),
///   autoStart: true,                     // start auto toggling now
///   period: Duration(seconds: 10),       // toggle every 10s
/// );
///
/// // Later, you can stop:
/// service.stopAutoToggle();
/// // Or start again with a different period:
/// service.startAutoToggle(period: const Duration(seconds: 5));
/// ```
///
/// Tip
/// - Downstream, use `GatewayThemeReactImpl.watch()` → `RepositoryThemeImplReact.watch()`
///   → `BlocThemeReact` to visualize the reactivity.
class FakeServiceThemeReact extends ServiceThemeReact {
  FakeServiceThemeReact({
    Map<String, dynamic>? lightJson,
    Map<String, dynamic>? darkJson,
    Map<String, dynamic>? textOverridesJson,
    bool autoStart = false,
    Duration period = const Duration(seconds: 10),
  }) : _period = period {
    // Seed defaults
    final Map<String, dynamic> lightDefaults = _ensureMode(
      lightJson ?? ThemeState.defaults.copyWith(mode: ThemeMode.light).toJson(),
      ThemeMode.light,
    );
    final Map<String, dynamic> darkDefaults = _ensureMode(
      darkJson ?? ThemeState.defaults.copyWith(mode: ThemeMode.dark).toJson(),
      ThemeMode.dark,
    );

    _light = _mergeTextOverrides(lightDefaults, textOverridesJson);
    _dark = _mergeTextOverrides(darkDefaults, textOverridesJson);

    // Initialize bus with light as the first emission
    updateTheme(_light);

    if (autoStart) {
      startAutoToggle(period: _period);
    }
  }

  late Map<String, dynamic> _light;
  late Map<String, dynamic> _dark;

  Duration _period;
  Timer? _timer;
  bool _isLightNext = false; // next flip target

  /// Starts auto toggling between light/dark payloads.
  /// If a timer is already running, it is restarted with the new [period] (if provided).
  void startAutoToggle({Duration? period}) {
    stopAutoToggle();
    if (period != null) {
      _period = period;
    }
    _timer = Timer.periodic(_period, (_) {
      _isLightNext = !_isLightNext;
      updateTheme(_isLightNext ? _light : _dark);
    });
  }

  /// Stops the auto toggle timer (if running).
  void stopAutoToggle() {
    _timer?.cancel();
    _timer = null;
  }

  /// Updates the light payload (merged with `textOverridesJson` if provided).
  void setLightJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? textOverridesJson,
  }) {
    _light = _mergeTextOverrides(
      _ensureMode(json, ThemeMode.light),
      textOverridesJson,
    );
    // If current mode is light, reflect immediately:
    if (_currentModeIs(ThemeMode.light)) {
      updateTheme(_light);
    }
  }

  /// Updates the dark payload (merged with `textOverridesJson` if provided).
  void setDarkJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? textOverridesJson,
  }) {
    _dark = _mergeTextOverrides(
      _ensureMode(json, ThemeMode.dark),
      textOverridesJson,
    );
    // If current mode is dark, reflect immediately:
    if (_currentModeIs(ThemeMode.dark)) {
      updateTheme(_dark);
    }
  }

  /// Updates only the text overrides, merging into both light/dark payloads.
  void setTextOverridesJson(Map<String, dynamic>? textOverridesJson) {
    _light = _mergeTextOverrides(_light, textOverridesJson);
    _dark = _mergeTextOverrides(_dark, textOverridesJson);
    // Reflect current immediately:
    final ThemeMode curr = _currentMode();
    updateTheme(curr == ThemeMode.dark ? _dark : _light);
  }

  /// Returns the currently configured light/dark payloads (for inspection/testing).
  Map<String, dynamic> get lightJson => Map<String, dynamic>.from(_light);
  Map<String, dynamic> get darkJson => Map<String, dynamic>.from(_dark);

  @override
  void dispose() {
    stopAutoToggle();
    super.dispose();
  }

  // ----------------- helpers -----------------

  static Map<String, dynamic> _ensureMode(
    Map<String, dynamic> json,
    ThemeMode mode,
  ) {
    // Shallow copy and enforce a mode key (gateway will normalize anyway).
    final Map<String, dynamic> out = Map<String, dynamic>.from(json);
    out['mode'] = mode.name;
    return out;
  }

  static Map<String, dynamic> _mergeTextOverrides(
    Map<String, dynamic> base,
    Map<String, dynamic>? textOverridesJson,
  ) {
    if (textOverridesJson == null) {
      return base;
    }
    // Non-destructive merge under 'textOverrides' only if absent.
    final Map<String, dynamic> out = Map<String, dynamic>.from(base);
    out['textOverrides'] =
        out['textOverrides'] ?? Map<String, dynamic>.from(textOverridesJson);
    return out;
  }

  ThemeMode _currentMode() {
    final String? m = themeStateJson['mode'] as String?;
    return ThemeMode.values.firstWhere(
      (ThemeMode tm) => tm.name == (m ?? ThemeMode.light.name),
      orElse: () => ThemeMode.light,
    );
  }

  bool _currentModeIs(ThemeMode mode) => _currentMode() == mode;
}
