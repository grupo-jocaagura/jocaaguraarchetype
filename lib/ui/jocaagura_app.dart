part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Top-level application shell for Jocaagura apps.
///
/// This widget wires the domain-level [AppManager] to the Flutter routing stack
/// using a custom `RouterDelegate` and a `RouteInformationParser`.
///
/// ### Key points
/// - Public API is **stateless**; internal state is encapsulated in a private
///   shell to keep router instances stable.
/// - When [ownsManager] is `true`, the app **disposes** the provided
///   [appManager] on teardown to free resources.
/// - App lifecycle changes are forwarded to [AppManager.handleLifecycle].
///
/// ### Example
/// ```dart
/// void main() {
///   final PageRegistry registry = PageRegistry.fromDefs(<PageDef>[
///     // ... your page defs here
///   ]);
///
///   runApp(
///     JocaaguraApp.dev(
///       registry: registry,
///       projectorMode: true,
///       initialLocation: '/home',
///     ),
///   );
/// }
/// ```
class JocaaguraApp extends StatelessWidget {
  const JocaaguraApp({
    required this.appManager,
    required this.registry,
    this.ownsManager = false,
    this.projectorMode = false,
    this.initialLocation = '/home',
    this.seedInitialFromPageManager = false,
    this.splashOverlayBuilder,
    super.key,
  });

  factory JocaaguraApp.dev({
    required PageRegistry registry,
    required bool projectorMode,
    Key? key,
    String initialLocation = '/home',
    List<OnboardingStep> onboardingSteps = const <OnboardingStep>[],
    bool seedInitialFromPageManager = false, // <— NUEVO
    Widget Function(BuildContext, OnboardingState)?
        splashOverlayBuilder, // <— NUEVO
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
      initialLocation: initialLocation,
      ownsManager: true,
      seedInitialFromPageManager: seedInitialFromPageManager,
      splashOverlayBuilder: splashOverlayBuilder,
    );
  }

  final AppManager appManager;
  final PageRegistry registry;
  final bool projectorMode;
  final String initialLocation;
  final bool ownsManager;

  /// If true, the initial URL is seeded from PageManager.top (if any).
  /// Keeps initial stack ownership on first Router sync.
  final bool seedInitialFromPageManager; // <— NUEVO

  /// Optional overlay builder for splash screens drawn above the app.
  /// When provided, it renders while onboarding is idle/running.
  final Widget Function(BuildContext, OnboardingState)? splashOverlayBuilder;

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(
      appManager: appManager,
      child: _JocaaguraAppShell(
        appManager: appManager,
        registry: registry,
        initialLocation: initialLocation,
        ownsManager: ownsManager,
        seedInitialFromPageManager: seedInitialFromPageManager, // <— NUEVO
        splashOverlayBuilder: splashOverlayBuilder, // <— NUEVO
      ),
    );
  }
}

class _JocaaguraAppShell extends StatefulWidget {
  const _JocaaguraAppShell({
    required this.appManager,
    required this.registry,
    required this.initialLocation,
    required this.ownsManager,
    required this.seedInitialFromPageManager,
    required this.splashOverlayBuilder,
  });

  final AppManager appManager;
  final PageRegistry registry;
  final String initialLocation;
  final bool ownsManager;
  final bool seedInitialFromPageManager;
  final Widget Function(BuildContext, OnboardingState)? splashOverlayBuilder;

  @override
  State<_JocaaguraAppShell> createState() => _JocaaguraAppShellState();
}

class _JocaaguraAppShellState extends State<_JocaaguraAppShell>
    with WidgetsBindingObserver {
  late final MyRouteInformationParser _parser;
  late final MyAppRouterDelegate _delegate;
  late final PlatformRouteInformationProvider _routeInfoProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _parser = const MyRouteInformationParser();
    _delegate = MyAppRouterDelegate(
      registry: widget.registry,
      pageManager: widget.appManager.pageManager,
    );

    final String seedPath = () {
      if (widget.seedInitialFromPageManager) {
        final PageModel top = widget.appManager.pageManager.stack.top;
        if (top.name.isNotEmpty) {
          return '/${top.name}';
        }
      }
      return widget.initialLocation;
    }();

    _routeInfoProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri.parse(seedPath)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.appManager.handleLifecycle(state);
    if (state == AppLifecycleState.detached) {
      if (widget.ownsManager && !widget.appManager.isDisposed) {
        widget.appManager.dispose();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _routeInfoProvider.dispose();
    } catch (_) {}
    try {
      _delegate.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager am = widget.appManager;

    _delegate.update(pageManager: am.pageManager, registry: widget.registry);

    Widget app = StreamBuilder<ThemeState>(
      stream: am.theme.stream,
      initialData: am.theme.stateOrDefault,
      builder: (_, __) {
        final ThemeState s = am.theme.stateOrDefault;
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerDelegate: _delegate,
          routeInformationParser: _parser,
          routeInformationProvider: _routeInfoProvider,
          restorationScopeId: 'app',
          theme: const BuildThemeData()
              .fromState(s.copyWith(mode: ThemeMode.light)),
          darkTheme: const BuildThemeData()
              .fromState(s.copyWith(mode: ThemeMode.dark)),
          themeMode: s.mode,
        );
      },
    );

    // —— Splash overlay (opcional) ——
    if (widget.splashOverlayBuilder != null) {
      app = StreamBuilder<OnboardingState>(
        stream: am.onboarding.stateStream,
        initialData: am.onboarding.state,
        builder: (_, __) {
          final OnboardingState os = am.onboarding.state;
          final bool show = os.status == OnboardingStatus.idle ||
              os.status == OnboardingStatus.running;
          if (!show) {
            return app;
          }
          return Stack(
            children: <Widget>[
              app,
              IgnorePointer(child: widget.splashOverlayBuilder!(context, os)),
            ],
          );
        },
      );
    }

    return app;
  }
}
