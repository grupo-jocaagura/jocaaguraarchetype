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
  /// Creates a Jocaagura app shell.
  const JocaaguraApp({
    required this.appManager,
    required this.registry,
    this.ownsManager = false,
    this.projectorMode = false,
    this.initialLocation = '/home',
    super.key,
  });

  /// DEV factory using archetype defaults with in-memory theme gateway and a
  /// minimal initial stack pointing to `/home`.
  ///
  /// The returned app **owns** the created [AppManager] and will dispose it.
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
      initialLocation: initialLocation,
      ownsManager: true,
    );
  }

  /// The domain-level app manager (theme, navigation, loading, etc.).
  final AppManager appManager;

  /// Page registry to materialize widgets from [PageModel]s.
  final PageRegistry registry;

  /// When `true`, only the top page is rendered (projector mode).
  final bool projectorMode;

  /// Initial location used to seed the platform route information.
  final String initialLocation;

  /// Whether this widget is responsible for disposing [appManager].
  final bool ownsManager;

  @override
  Widget build(BuildContext context) {
    // Share AppManager down the tree without rebuild churn.
    return AppManagerProvider(
      appManager: appManager,
      child: _JocaaguraAppShell(
        appManager: appManager,
        registry: registry,
        initialLocation: initialLocation,
        ownsManager: ownsManager,
      ),
    );
  }
}

/// Internal stateful shell that holds stable router instances and observes
/// application lifecycle, disposing resources when needed.
///
/// This keeps the public API stateless while guaranteeing:
/// - Single instances of delegate/parser/provider.
/// - Proper `dispose()` calls.
class _JocaaguraAppShell extends StatefulWidget {
  const _JocaaguraAppShell({
    required this.appManager,
    required this.registry,
    required this.initialLocation,
    required this.ownsManager,
  });

  final AppManager appManager;
  final PageRegistry registry;
  final String initialLocation;
  final bool ownsManager;

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
    _routeInfoProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        uri: Uri.parse(widget.initialLocation),
      ),
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

    _delegate.update(
      pageManager: am.pageManager,
      registry: widget.registry,
    );

    return StreamBuilder<ThemeState>(
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
  }
}
