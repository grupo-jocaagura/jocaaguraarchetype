part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reactive variant of [BlocTheme].
///
/// Subscribes to a [WatchTheme] use case on construction and updates state
/// based on the repository stream while keeping the same imperative API from
/// [BlocTheme]. This enables end-to-end reactivity (Service → Gateway → Repo → Bloc → UI).
///
/// ### Example
/// ```dart
/// final service = FakeServiceThemeReact(autoStart: true);
/// final gateway = GatewayThemeReactImpl(service: service);
/// final repo    = RepositoryThemeReactImpl(gateway: gateway);
/// final ucs     = ThemeUsecases.fromRepo(repo);
/// final bloc    = BlocThemeReact(themeUsecases: ucs, watchTheme: WatchTheme(repo));
///
/// // UI rebuilds on each emission
/// StreamBuilder<ThemeState>(
///   stream: bloc.stream,
///   initialData: bloc.stateOrDefault,
///   builder: (context, snap) {
///     return MaterialApp(theme: bloc.themeData());
///   },
/// );
/// ```
///
/// ### Notes
/// - The reactive subscription is cancelled in [dispose].
/// - Imperative methods (e.g. [setMode], [setSeed]) still work; the actual
///   state applied is the one emitted by the repository.
class BlocThemeReact extends BlocTheme {
  BlocThemeReact({
    required super.themeUsecases,
    required this.watchTheme,
  }) {
    _sub = watchTheme().listen(_apply);
  }

  static const String name = 'BlocThemeReact';

  final WatchTheme watchTheme;

  StreamSubscription<Either<ErrorItem, ThemeState>>? _sub;

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _sub = null;
    super.dispose();
  }
}
