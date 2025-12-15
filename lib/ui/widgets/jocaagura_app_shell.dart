part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class JocaaguraAppShell extends StatefulWidget {
  const JocaaguraAppShell({
    required this.appManager,
    required this.registry,
    required this.initialLocation,
    required this.ownsManager,
    required this.seedInitialFromPageManager,
    required this.splashOverlayBuilder,
    this.controller, // ✅ nuevo (para tests)
    super.key,
  });

  final AbstractAppManager appManager;
  final PageRegistry registry;
  final String initialLocation;
  final bool ownsManager;
  final bool seedInitialFromPageManager;
  final Widget Function(BuildContext, OnboardingState)? splashOverlayBuilder;

  /// Cuando se provee, evita usar streams “reales” (ej. RepeatLastValueExtension).
  final JocaaguraAppShellController? controller;

  @override
  State<JocaaguraAppShell> createState() => _JocaaguraAppShellState();
}

class _JocaaguraAppShellState extends State<JocaaguraAppShell>
    with WidgetsBindingObserver {
  late final MyRouteInformationParser _parser;
  late final MyAppRouterDelegate _delegate;
  late final PlatformRouteInformationProvider _routeInfoProvider;

  late JocaaguraAppShellController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = widget.controller ??
        JocaaguraAppShellController.fromManager(widget.appManager);

    _parser = const MyRouteInformationParser();
    _delegate = MyAppRouterDelegate(
      registry: widget.registry,
      pageManager: _controller.appManager.pageManager,
    );

    final String seedPath = _controller.computeSeedPath(
      seedInitialFromPageManager: widget.seedInitialFromPageManager,
      initialLocation: widget.initialLocation,
    );

    _routeInfoProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri.parse(seedPath)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.handleLifecycle(
      state: state,
      ownsManager: widget.ownsManager,
    );
  }

  @override
  void didUpdateWidget(covariant JocaaguraAppShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el test inyecta controller y lo cambia, lo respetamos.
    if (!identical(oldWidget.controller, widget.controller) &&
        widget.controller != null) {
      _controller = widget.controller!;
      return;
    }

    // Si no hay controller inyectado, y cambia el manager: actualizamos streams.
    if (oldWidget.controller == null &&
        !identical(oldWidget.appManager, widget.appManager)) {
      _controller.replaceManager(widget.appManager);
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
    final AbstractAppManager am = _controller.appManager;
    _delegate.update(pageManager: am.pageManager, registry: widget.registry);

    if (widget.splashOverlayBuilder != null) {
      return JocaaguraSplashOverlay(
        onboardingStream: _controller.onboardingStream,
        initialOnboarding: _controller.initialOnboarding,
        overlayBuilder: widget.splashOverlayBuilder!,
      );
    }

    return JocaaguraThemedRouterApp(
      themeStream: _controller.themeStream,
      initialTheme: _controller.initialTheme,
      routerDelegate: _delegate,
      routeInformationParser: _parser,
      routeInformationProvider: _routeInfoProvider,
      appManager: am,
    );
  }
}
