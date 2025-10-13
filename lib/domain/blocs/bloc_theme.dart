part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class BlocTheme extends BlocModule {
  BlocTheme({required this.themeUsecases})
      : _state = BlocGeneral<ThemeState>(ThemeState.defaults),
        _error = BlocGeneral<ErrorItem?>(null);

  static const String name = 'BlocTheme';

  final ThemeUsecases themeUsecases;

  final BlocGeneral<ThemeState> _state;
  final BlocGeneral<ErrorItem?> _error;

  /// Stream of the current [ThemeState].
  Stream<ThemeState> get stream => _state.stream;

  /// Synchronous snapshot of [ThemeState].
  ThemeState get stateOrDefault => _state.value;

  /// Emits the last error (if any). Null means “no error”.
  Stream<ErrorItem?> get error$ => _error.stream;
  ErrorItem? get error => _error.value;

  // ---------------------
  // Actions
  // ---------------------

  Future<void> load() => _run(themeUsecases.load.call);
  Future<void> setMode(ThemeMode m) =>
      _run(() => themeUsecases.setMode.call(m));
  Future<void> setSeed(Color c) => _run(() => themeUsecases.setSeed.call(c));
  Future<void> toggleM3() => _run(themeUsecases.toggleM3.call);
  Future<void> applyPreset(String p) =>
      _run(() => themeUsecases.applyPreset.call(p));
  Future<void> setTextScale(double s) =>
      _run(() => themeUsecases.setTextScale.call(s));
  Future<void> reset() => _run(themeUsecases.reset.call);
  Future<void> randomTheme() => _run(themeUsecases.randomize.call);
  Future<void> applyPatch(ThemePatch patch) =>
      _run(() => themeUsecases.applyPatch.call(patch));
  Future<void> setFromState(ThemeState next) =>
      _run(() => themeUsecases.setFromState.call(next));

  /// Builds a `ThemeData` from the current [ThemeState].
  ThemeData themeData({TextTheme? baseTextTheme}) => const BuildThemeData()
      .fromState(stateOrDefault, baseTextTheme: baseTextTheme);

  /// Sets (or clears) the per-scheme text theme overrides and persists them.
  ///
  /// Retro-compat behavior:
  /// - If `ThemeUsecases.setTextThemeOverrides` is available (new versions),
  ///   it will be used directly.
  /// - Otherwise, it falls back to `applyPatch(ThemePatch(textOverrides: next))`.
  ///
  /// Example:
  /// ```dart
  /// await bloc.setTextThemeOverrides(const TextThemeOverrides(
  ///   light: TextTheme(
  ///     bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
  ///   ),
  ///   dark: TextTheme(
  ///     bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
  ///   ),
  /// ));
  ///
  /// // Clear later:
  /// await bloc.setTextThemeOverrides(null);
  /// ```
  Future<void> setTextThemeOverrides(TextThemeOverrides? next) {
    final SetTextThemeOverrides? uc = themeUsecases.setTextThemeOverrides;
    if (uc != null) {
      return _run(() => uc.call(next));
    }
    return _run(
      () => themeUsecases.applyPatch.call(
        ThemePatch(textOverrides: next),
      ),
    );
  }

  /// Convenience: clears the current text overrides (same as `setTextThemeOverrides(null)`).
  Future<void> clearTextThemeOverrides() => setTextThemeOverrides(null);

  // ---------------------
  // Internals
  // ---------------------

  Future<void> _run(Future<Either<ErrorItem, ThemeState>> Function() op) async {
    final Either<ErrorItem, ThemeState> r = await op();
    _apply(r);
  }

  void _apply(Either<ErrorItem, ThemeState> result) {
    result.when(
      (ErrorItem err) {
        _error.value = err; // keep last good state; just report the error
      },
      (ThemeState s) {
        _error.value = null;
        _state.value = s;
      },
    );
  }

  bool _disposed = false;
  bool get isClosed => _disposed;

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _state.dispose();
    _error.dispose();
  }
}
