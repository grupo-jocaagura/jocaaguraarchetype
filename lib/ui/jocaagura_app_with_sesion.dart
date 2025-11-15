part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// High-level app wrapper that wires:
///
/// - [AppManager] + [PageRegistry] into [JocaaguraApp].
/// - [BlocSession] + session-related [PageModel]s into [SessionAppManager].
///
/// This widget is meant to be your default entry point whenever the app
/// needs session-aware navigation (login, logout, errors, etc.).
///
/// The [SessionAppManager] instance is created once per widget instance and
/// attaches to the [AppManager.pageManager] and [BlocSession] streams to
/// enforce the navigation policy defined by [SessionState].
///
/// ### Usage (custom wiring)
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final AppManager manager = buildAppManager();
///   final BlocSession sessionBloc = manager.requireModuleByKey(BlocSession.name);
///
///   runApp(
///     JocaaguraAppWithSession(
///       appManager: manager,
///       registry: registry,
///       sessionBloc: sessionBloc,
///       splashPage: SplashPage.pageModel,
///       homePublicPage: HomePage.pageModel,
///       loginPage: LoginPage.pageModel,
///       homeAuthenticatedPage: HomeAuthenticatedPage.pageModel,
///       sessionClosedPage: SessionClosedPage.pageModel,
///       authenticatingPage: AuthenticatingPage.pageModel,
///       sessionErrorPage: SessionErrorPage.pageModel,
///       seedInitialFromPageManager: true,
///     ),
///   );
/// }
/// ```
///
/// ### Usage (dev helper with FakeServiceSession)
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final AppManager manager = buildAppManager();
///
///   runApp(
///     JocaaguraAppWithSession.dev(
///       appManager: manager,
///       registry: registry,
///       splashPage: SplashPage.pageModel,
///       homePublicPage: HomePage.pageModel,
///       loginPage: LoginPage.pageModel,
///       homeAuthenticatedPage: HomeAuthenticatedPage.pageModel,
///       sessionClosedPage: SessionClosedPage.pageModel,
///       authenticatingPage: AuthenticatingPage.pageModel,
///       sessionErrorPage: SessionErrorPage.pageModel,
///       // Opcional: iniciar con sesión ya autenticada
///       isSessionInitialized: true,
///       initialUserJson: defaultUserModel.toJson(),
///     ),
///   );
/// }
/// ```
class JocaaguraAppWithSession extends StatefulWidget {
  const JocaaguraAppWithSession({
    required this.appManager,
    required this.registry,
    required this.sessionBloc,
    required this.splashPage,
    required this.homePublicPage,
    required this.loginPage,
    required this.homeAuthenticatedPage,
    required this.sessionClosedPage,
    required this.authenticatingPage,
    required this.sessionErrorPage,
    this.projectorMode = false,
    this.initialLocation = '/home',
    this.seedInitialFromPageManager = false,
    this.splashOverlayBuilder,
    this.sessionAppManager,
    this.configureMenusForLoggedIn,
    this.configureMenusForLoggedOut,
    super.key,
  });

  /// Dev factory that optionally wires a [BlocSession] using FakeServiceSession.
  ///
  /// If [sessionBloc] is provided, it is used as-is.
  /// Otherwise, a default dev [BlocSession] is created:
  ///
  /// ```dart
  /// final GatewayAuth gatewayAuth = GatewayAuthImpl(
  ///   FakeServiceSession(initialUserJson: initialUserJsonIfAny),
  /// );
  /// final RepositoryAuth repositoryAuth = RepositoryAuthImpl(
  ///   gateway: gatewayAuth,
  /// );
  /// final BlocSession session =
  ///     BlocSession.fromRepository(repository: repositoryAuth);
  /// ```
  factory JocaaguraAppWithSession.dev({
    // Core wiring
    required AppManager appManager,
    required PageRegistry registry,
    required PageModel splashPage,
    required PageModel homePublicPage,
    required PageModel loginPage,
    required PageModel homeAuthenticatedPage,
    required PageModel sessionClosedPage,
    required PageModel authenticatingPage,
    required PageModel sessionErrorPage,
    required void Function(AppManager app) configureMenusForLoggedIn,
    required void Function(AppManager app)
        configureMenusForLoggedOut, // Session wiring override (optional)
    BlocSession? sessionBloc,

    // Dev helpers for FakeServiceSession
    bool isSessionInitialized = false,
    Map<String, dynamic>? initialUserJson,

    // App options
    bool projectorMode = false,
    String initialLocation = '/home',
    bool seedInitialFromPageManager = true,
    Widget Function(BuildContext, OnboardingState)? splashOverlayBuilder,
    SessionAppManager? sessionAppManager,
    Key? key,
  }) {
    final BlocSession effectiveSessionBloc = sessionBloc ??
        _buildDevSessionBloc(
          isSessionInitialized: isSessionInitialized,
          initialUserJson: initialUserJson,
        );

    return JocaaguraAppWithSession(
      key: key,
      appManager: appManager,
      registry: registry,
      sessionBloc: effectiveSessionBloc,
      splashPage: splashPage,
      homePublicPage: homePublicPage,
      loginPage: loginPage,
      homeAuthenticatedPage: homeAuthenticatedPage,
      sessionClosedPage: sessionClosedPage,
      authenticatingPage: authenticatingPage,
      sessionErrorPage: sessionErrorPage,
      projectorMode: projectorMode,
      initialLocation: initialLocation,
      seedInitialFromPageManager: seedInitialFromPageManager,
      splashOverlayBuilder: splashOverlayBuilder,
      sessionAppManager: sessionAppManager,
      configureMenusForLoggedIn: configureMenusForLoggedIn,
      configureMenusForLoggedOut: configureMenusForLoggedOut,
    );
  }

  /// Hook para configurar menús cuando la sesión está autenticada.
  final void Function(AppManager app)? configureMenusForLoggedIn;

  /// Hook para configurar menús cuando la sesión NO está autenticada.
  final void Function(AppManager app)? configureMenusForLoggedOut;

  /// Core app manager containing navigation, blocs and cross-cutting concerns.
  final AppManager appManager;

  /// Page registry used by [JocaaguraApp] router.
  final PageRegistry registry;

  /// Session BLoC exposing [SessionState] transitions.
  final BlocSession sessionBloc;

  /// Splash screen page model (runs once per app execution).
  final PageModel splashPage;

  /// Public home page shown while [SessionState] is [Unauthenticated].
  final PageModel homePublicPage;

  /// Login page shown when user must authenticate.
  final PageModel loginPage;

  /// Default landing page for [Authenticated] users.
  final PageModel homeAuthenticatedPage;

  /// Page shown when the session has been explicitly closed.
  final PageModel sessionClosedPage;

  /// Page used while a login/refresh operation is in progress.
  final PageModel authenticatingPage;

  /// Page used to display unrecoverable session errors.
  final PageModel sessionErrorPage;

  /// Whether projector mode is enabled (passed to [JocaaguraApp]).
  final bool projectorMode;

  /// Initial URL for the router when not seeding from [PageManager].
  final String initialLocation;

  /// If true, the initial route is taken from [PageManager.stack.top].
  final bool seedInitialFromPageManager;

  /// Optional overlay builder for visual splash/onboarding on top of the app.
  final Widget Function(BuildContext, OnboardingState)? splashOverlayBuilder;

  /// Internal session coordinator. Created once and attached to [appManager].
  ///
  /// If provided, **this widget will NOT take ownership** of its lifecycle
  /// (i.e. it will not dispose it).
  final SessionAppManager? sessionAppManager;

  @override
  State<JocaaguraAppWithSession> createState() =>
      _JocaaguraAppWithSessionState();
}

class _JocaaguraAppWithSessionState extends State<JocaaguraAppWithSession> {
  late final SessionAppManager _sessionAppManager;
  late final bool _ownsSessionAppManager;

  @override
  void initState() {
    super.initState();
    _ownsSessionAppManager = widget.sessionAppManager == null;

    _sessionAppManager = widget.sessionAppManager ??
        SessionAppManager(
          appManager: widget.appManager,
          sessionBloc: widget.sessionBloc,
          splashPage: widget.splashPage,
          homePublicPage: widget.homePublicPage,
          loginPage: widget.loginPage,
          homeAuthenticatedPage: widget.homeAuthenticatedPage,
          sessionClosedPage: widget.sessionClosedPage,
          authenticatingPage: widget.authenticatingPage,
          sessionErrorPage: widget.sessionErrorPage,
          configureMenusForLoggedIn: widget.configureMenusForLoggedIn,
          configureMenusForLoggedOut: widget.configureMenusForLoggedOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    return JocaaguraApp(
      appManager: widget.appManager,
      registry: widget.registry,
      projectorMode: widget.projectorMode,
      initialLocation: widget.initialLocation,
      seedInitialFromPageManager: widget.seedInitialFromPageManager,
      splashOverlayBuilder: widget.splashOverlayBuilder,
    );
  }

  @override
  void dispose() {
    // Este wrapper es el dueño del AppManager.
    if (!widget.appManager.isDisposed) {
      widget.appManager.dispose();
    }

    // Solo destruimos SessionAppManager si lo creamos aquí.
    if (_ownsSessionAppManager) {
      _sessionAppManager.dispose();
    }

    super.dispose();
  }
}

/// Dev helper for building a [BlocSession] wired to FakeServiceSession.
///
/// This encapsulates the typical flow:
///   GatewayAuthImpl -> RepositoryAuthImpl -> BlocSession.fromRepository
BlocSession _buildDevSessionBloc({
  required bool isSessionInitialized,
  Map<String, dynamic>? initialUserJson,
}) {
  final GatewayAuth gatewayAuth = GatewayAuthImpl(
    FakeServiceSession(
      initialUserJson: isSessionInitialized ? initialUserJson : null,
    ),
  );

  final RepositoryAuth repositoryAuth =
      RepositoryAuthImpl(gateway: gatewayAuth);

  return BlocSession.fromRepository(repository: repositoryAuth);
}
