part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class BlocTheme extends BlocModule {
  BlocTheme({
    required this.themeUsecases,
  }) : _blocTheme = BlocGeneral<Either<ErrorItem, ThemeState>>(
          Right<ErrorItem, ThemeState>(ThemeState.defaults),
        );

  static const String name = 'BlocTheme';

  final ThemeUsecases themeUsecases;

  final BlocGeneral<Either<ErrorItem, ThemeState>> _blocTheme;

  // Exposición
  Stream<Either<ErrorItem, ThemeState>> get streamEither => _blocTheme.stream;
  Either<ErrorItem, ThemeState> get valueEither => _blocTheme.value;

  Stream<ThemeState> get stream => _blocTheme.stream.map(
        (Either<ErrorItem, ThemeState> e) =>
            e.when((_) => ThemeState.defaults, (ThemeState state) => state),
      );
  ThemeState get stateOrDefault =>
      _blocTheme.value.when((_) => ThemeState.defaults, (ThemeState s) => s);

  // Acciones (sin retorno significativo)
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

  Future<void> _run(Future<Either<ErrorItem, ThemeState>> Function() op) async {
    final Either<ErrorItem, ThemeState> r = await op();
    _blocTheme.value = r.when(
      (ErrorItem err) => Left<ErrorItem, ThemeState>(err),
      (ThemeState state) => Right<ErrorItem, ThemeState>(state),
    );
  }

  bool _disposed = false;
  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _blocTheme.dispose();
  }
}
