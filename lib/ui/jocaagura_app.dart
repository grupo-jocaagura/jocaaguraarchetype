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

  final AbstractAppManager appManager;
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
      child: JocaaguraAppShell(
        appManager: appManager,
        registry: registry,
        initialLocation: initialLocation,
        ownsManager: ownsManager,
        seedInitialFromPageManager: seedInitialFromPageManager,
        splashOverlayBuilder: splashOverlayBuilder,
      ),
    );
  }
}
