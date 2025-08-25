part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Manages [ThemeState] with clear state/error streams and side-effectful usecases.
/// UI subscribes to [stream] for state and optionally to [error$] for errors.
///
/// ### Why this shape?
/// - Keep `ThemeState` as the single source-of-truth (DTO).
/// - Avoid exposing `Either` to the UI (reduce mapping in widgets).
/// - Provide granular updates via `applyPatch` and full replacement via `setFromState`.
/// - Offer a canonical `ThemeData` builder through [themeData] using BuildThemeData.
///
/// ### Example
/// ```dart
/// final bloc = BlocTheme(themeUsecases: ThemeUsecases.fromRepo(repo));
/// await bloc.load();                 // loads persisted theme
/// await bloc.applyPatch(ThemePatch(seed: Colors.teal));
/// final theme = bloc.themeData();    // ThemeData for MaterialApp
/// ```
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

  /// Loads the persisted theme state from repository.
  Future<void> load() => _run(themeUsecases.load.call);

  /// Sets the ThemeMode.
  Future<void> setMode(ThemeMode m) =>
      _run(() => themeUsecases.setMode.call(m));

  /// Sets the seed color.
  Future<void> setSeed(Color c) => _run(() => themeUsecases.setSeed.call(c));

  /// Toggles Material3 flag.
  Future<void> toggleM3() => _run(themeUsecases.toggleM3.call);

  /// Applies a preset name (brand, etc). Repository decides the mapping.
  Future<void> applyPreset(String p) =>
      _run(() => themeUsecases.applyPreset.call(p));

  /// Sets text scale (clamped and normalized by the usecase).
  Future<void> setTextScale(double s) =>
      _run(() => themeUsecases.setTextScale.call(s));

  /// Resets to defaults and persists.
  Future<void> reset() => _run(themeUsecases.reset.call);

  /// Randomizes via ServiceTheme and persists (e.g., seed color).
  Future<void> randomTheme() => _run(themeUsecases.randomize.call);

  /// Applies a partial update intent (granular) on top of the current state.
  /// If ya definiste `ThemePatch`/`ApplyThemePatch`, usa ese; si usas `ApplyThemeConfig`, delega a él.
  Future<void> applyPatch(ThemePatch patch) =>
      _run(() => themeUsecases.applyPatch.call(patch));

  /// Replaces the entire ThemeState at once (when UI already built a full state).
  Future<void> setFromState(ThemeState next) =>
      _run(() => themeUsecases.setFromState.call(next));

  /// Canonical way to produce ThemeData for MaterialApp (seed + overrides + M3 + textScale).
  ThemeData themeData({TextTheme? baseTextTheme}) =>
      const BuildThemeData().fromState(stateOrDefault, baseTextTheme: baseTextTheme);

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
        // keep last good state; just report the error
        _error.value = err;
      },
      (ThemeState s) {
        _error.value = null;
        _state.value = s;
      },
    );
  }

  bool _disposed = false;
  bool get isClosed => _disposed; // alias-friendly

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
