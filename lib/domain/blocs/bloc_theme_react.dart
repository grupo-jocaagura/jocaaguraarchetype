part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reactive Bloc that subscribes to ThemeUsecases.watch() on construction.
/// Keeps the same state/error conduits as the imperative BlocTheme, but the
/// source of truth is the repository stream.
///
/// - Requires ThemeUsecases.watch to be provided (non-null).
/// - Optional imperative helpers still available (they call the existing UCs);
///   the actual state update is reflected by the stream.
class BlocThemeReact extends BlocModule {
  BlocThemeReact({
    required this.themeUsecases,
    required this.watchTheme,
    ThemeState initial = ThemeState.defaults,
  })  : _state = BlocGeneral<ThemeState>(initial),
        _error = BlocGeneral<ErrorItem?>(null) {
    _sub = watchTheme().listen(_apply);
  }

  static const String name = 'BlocThemeReact';

  final ThemeUsecases themeUsecases;
  final WatchTheme watchTheme;

  final BlocGeneral<ThemeState> _state;
  final BlocGeneral<ErrorItem?> _error;
  StreamSubscription<Either<ErrorItem, ThemeState>>? _sub;

  // Outputs
  Stream<ThemeState> get stream => _state.stream;
  ThemeState get stateOrDefault => _state.value;
  Stream<ErrorItem?> get error$ => _error.stream;
  ErrorItem? get error => _error.value;

  Future<void> setMode(ThemeMode m) async =>
      _run(() => themeUsecases.setMode.call(m));
  Future<void> setSeed(Color c) async =>
      _run(() => themeUsecases.setSeed.call(c));
  Future<void> toggleM3() async => _run(themeUsecases.toggleM3.call);
  Future<void> applyPreset(String p) async =>
      _run(() => themeUsecases.applyPreset.call(p));
  Future<void> setTextScale(double s) async =>
      _run(() => themeUsecases.setTextScale.call(s));
  Future<void> reset() async => _run(themeUsecases.reset.call);
  Future<void> randomTheme() async => _run(themeUsecases.randomize.call);
  Future<void> applyPatch(ThemePatch patch) async =>
      _run(() => themeUsecases.applyPatch.call(patch));
  Future<void> setFromState(ThemeState next) async =>
      _run(() => themeUsecases.setFromState.call(next));

  /// Optional: set/clear text overrides (uses UC if present, else falls back to patch).
  Future<void> setTextThemeOverrides(TextThemeOverrides? next) async {
    final SetTextThemeOverrides? uc = themeUsecases.setTextThemeOverrides;
    if (uc != null) {
      await _run(() => uc.call(next));
    } else {
      await _run(
        () => themeUsecases.applyPatch.call(
          ThemePatch(textOverrides: next),
        ),
      );
    }
  }

  ThemeData themeData({TextTheme? baseTextTheme}) => const BuildThemeData()
      .fromState(stateOrDefault, baseTextTheme: baseTextTheme);

  // Internals
  Future<void> _run(Future<Either<ErrorItem, ThemeState>> Function() op) async {
    final Either<ErrorItem, ThemeState> r = await op();
    // No forzamos estado: dejamos que watch() sea la fuente de verdad.
    // Pero reflejamos un posible error inmediato (p.ej., save fallido).
    r.when((ErrorItem e) => _error.value = e, (_) => _error.value = null);
  }

  void _apply(Either<ErrorItem, ThemeState> result) {
    result.when(
      (ErrorItem err) => _error.value = err,
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
    unawaited(_sub?.cancel());
    _state.dispose();
    _error.dispose();
  }
}
