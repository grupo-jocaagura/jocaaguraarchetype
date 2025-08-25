part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Jocaagura shell wiring around MaterialApp.router.
///
/// - Navigation source of truth: [PageManager] (from AppConfig).
/// - Theme source of truth: [BlocTheme] -> emits [ThemeState].
/// - UI builds ThemeData via [ThemeDataUtils] (UI-only).
/// - Requires a [PageRegistry] to resolve slugs/builders.
/// - `projectorMode` is required and passed to the RouterDelegate.
/// - `initialLocation` is provided via RouteInformation (uri-based).
///
/// ### Example (factory)
/// ```dart
/// final registry = buildExampleRegistry();
/// runApp(JocaaguraApp.dev(
///   registry: registry,
///   projectorMode: false,
///   initialLocation: '/home',
/// ));
/// ```
///
/// ### Example (advanced)
/// ```dart
/// final registry = buildExampleRegistry();
/// final cfg = AppConfig.dev(registry: registry);
/// final manager = AppManager(cfg);
/// runApp(JocaaguraApp(
///   appManager: manager,
///   registry: registry,
///   projectorMode: true,
///   initialLocation: '/settings',
/// ));
/// ```
class JocaaguraApp extends StatefulWidget {
  const JocaaguraApp({
    required this.appManager,
    required this.registry,
    super.key,
    this.projectorMode = true,
    this.initialLocation = '/home',
  });

  /// Factory for DEV flavour using archetype defaults.
  factory JocaaguraApp.dev({
    required PageRegistry registry,
    required bool projectorMode,
    Key? key,
    String initialLocation = '/home',
    List<OnboardingStep> onboardingSteps = const <OnboardingStep>[],
  }) {
    final AppConfig config = AppConfig.dev(
      registry: registry,
      onboardingSteps: onboardingSteps,
    );
    final AppManager manager = AppManager(config);
    return JocaaguraApp(
      key: key,
      appManager: manager,
      registry: registry,
      projectorMode: projectorMode,
      initialLocation: initialLocation,
    );
  }

  /// Fully built manager (theme, loading, notifications, pageManager, etc.).
  final AppManager appManager;

  /// Page registry used by the RouterDelegate to build pages from slugs.
  final PageRegistry registry;

  /// Enables projector-specific behaviors in the RouterDelegate.
  final bool projectorMode;

  /// First location to load when the app starts (defaults to '/home').
  final String initialLocation;

  @override
  State<JocaaguraApp> createState() => _JocaaguraAppState();
}

class _JocaaguraAppState extends State<JocaaguraApp> {
  late MyRouteInformationParser _parser;
  late MyAppRouterDelegate _delegate;

  @override
  void initState() {
    super.initState();
    _parser = const MyRouteInformationParser();
    _delegate = MyAppRouterDelegate(
      registry: widget.registry,
      pageManager: widget.appManager.pageManager,
      projectorMode: widget.projectorMode,
    );
  }

  @override
  void didUpdateWidget(covariant JocaaguraApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool managerChanged =
        !identical(oldWidget.appManager, widget.appManager);
    final bool registryChanged =
        !identical(oldWidget.registry, widget.registry);
    final bool projectorChanged =
        oldWidget.projectorMode != widget.projectorMode;

    if (managerChanged || registryChanged || projectorChanged) {
      // recrea el delegate con las nuevas dependencias
      _delegate = MyAppRouterDelegate(
        registry: widget.registry,
        pageManager: widget.appManager.pageManager,
        projectorMode: widget.projectorMode,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(
      appManager: widget.appManager,
      child: StreamBuilder<ThemeState>(
        stream: widget.appManager.theme.stream,
        initialData: widget.appManager.theme.stateOrDefault,
        builder: (__, AsyncSnapshot<ThemeState> snap) {
          final ThemeState s = snap.data ?? ThemeState.defaults;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerDelegate: _delegate,
            routeInformationParser: _parser,
            routeInformationProvider: PlatformRouteInformationProvider(
              initialRouteInformation: RouteInformation(
                uri: Uri.parse(widget.initialLocation),
              ),
            ),
            theme: const BuildThemeData().fromState(s.copyWith(mode: ThemeMode.light)),
            darkTheme:
            const BuildThemeData().fromState(s.copyWith(mode: ThemeMode.dark)),
            themeMode: s.mode,
          );
        },
      ),
    );
  }
}
