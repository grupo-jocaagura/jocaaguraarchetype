part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class SessionAppManager {
  SessionAppManager({
    required this.appManager,
    required this.sessionBloc,
    required this.splashPage,
    required this.homePublicPage,
    required this.loginPage,
    required this.homeAuthenticatedPage,
    required this.sessionClosedPage,
    required this.authenticatingPage,
    required this.sessionErrorPage,
    this.goHomeWhenAuthenticatedOnLogin = true,
    this.pageEquals = routeEquals,
    this.configureMenusForLoggedIn,
    this.configureMenusForLoggedOut,
  }) {
    _init();
  }

  final AbstractAppManager appManager;
  final BlocSession sessionBloc;

  // PageModels canónicos
  final PageModel splashPage;
  final PageModel homePublicPage;
  final PageModel loginPage;
  final PageModel homeAuthenticatedPage;
  final PageModel sessionClosedPage;
  final PageModel authenticatingPage;
  final PageModel sessionErrorPage;

  /// Configuración de menús cuando la sesión está autenticada.
  final void Function(AbstractAppManager app)? configureMenusForLoggedIn;

  /// Configuración de menús cuando la sesión NO está autenticada.
  final void Function(AbstractAppManager app)? configureMenusForLoggedOut;

  final bool goHomeWhenAuthenticatedOnLogin;
  final PageEquals pageEquals;

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<NavStackModel>? _stackSub;

  SessionState _last = const Unauthenticated();
  NavStackModel? _pending;
  bool _disposed = false;

  PageManager get _pageManager => appManager.pageManager;

  void _init() {
    // 1) Inicializar estado base de sesión (_last)
    try {
      _last = sessionBloc.stateOrDefault;
    } catch (_) {
      try {
        _last = sessionBloc.isAuthenticated
            ? Authenticated(sessionBloc.currentUser)
            : const Unauthenticated();
      } catch (_) {
        _last = const Unauthenticated();
      }
    }

    // 2) Menús iniciales según el estado actual
    _applyMenusForState(_last);

    // 3) Top inicial del stack

    // 4) Stream de sesión con fallbacks
    Stream<SessionState> sessionStream;
    try {
      sessionStream = sessionBloc.stream;
    } catch (_) {
      try {
        sessionStream = sessionBloc.sessionStream;
      } catch (_) {
        sessionStream = Stream<SessionState>.value(_last);
      }
    }

    // 5) Suscripción a cambios de sesión
    _sessionSub = sessionStream.listen((SessionState s) {
      if (_disposed) {
        return;
      }
      _last = s;
      _applyMenusForState(s);
      _enforcePolicy(_pageManager.stack, s);
    });

    // 6) Suscripción a cambios de stack
    _stackSub = _pageManager.stackStream.listen((NavStackModel stack) {
      if (_disposed) {
        return;
      }
      _enforcePolicy(stack, _last);
    });

    // 7) Aplicar política inicial con el estado actual
    _enforcePolicy(_pageManager.stack, _last);
  }

  // Helpers de estado
  bool _isAuthed(SessionState s) => s is Authenticated || s is Refreshing;

  bool _isSplash(PageModel p) => pageEquals(p, splashPage);
  bool _isLogin(PageModel p) => pageEquals(p, loginPage);
  bool _isHomeAuthed(PageModel p) => pageEquals(p, homeAuthenticatedPage);
  bool _isSessionClosed(PageModel p) => pageEquals(p, sessionClosedPage);
  bool _isAuthenticatingPage(PageModel p) => pageEquals(p, authenticatingPage);
  bool _isSessionErrorPage(PageModel p) => pageEquals(p, sessionErrorPage);

  bool _isProtected(PageModel p) => p.requiresAuth;

  bool _isSameTop(NavStackModel s, PageModel target) =>
      pageEquals(s.top, target);

  NavStackModel _cloneStack(NavStackModel s) =>
      s.copyWith(pages: List<PageModel>.from(s.pages));

  void _enforcePolicy(NavStackModel stack, SessionState state) {
    if (_disposed) {
      return;
    }

    final PageModel top = stack.top;

    // 0) Mientras estoy en Splash → no fuerzo nada (el Splash manda)
    if (_isSplash(top)) {
      return;
    }

    // 1) Estados por sesión
    if (state is Unauthenticated) {
      _handleUnauthenticated(stack, top);
      return;
    }

    if (state is Authenticating) {
      _handleAuthenticating(stack, top);
      return;
    }

    if (state is SessionError) {
      _handleSessionError(stack, top, state);
      return;
    }

    if (_isAuthed(state)) {
      _handleAuthenticatedOrRefreshing(stack, top, state);
      return;
    }
  }

  void _handleUnauthenticated(NavStackModel stack, PageModel top) {
    final bool needRedirectToLogin =
        _isProtected(top) && !_isLogin(top) && !_isSessionClosed(top);

    if (needRedirectToLogin) {
      _pending ??= _cloneStack(stack);
      if (!_isSameTop(stack, loginPage)) {
        _pageManager.resetTo(loginPage);
      }
      return;
    }

    if (_isHomeAuthed(top) || _isSessionErrorPage(top)) {
      if (!_isSameTop(stack, homePublicPage)) {
        _pageManager.resetTo(homePublicPage);
      }
    }
  }

  void _handleAuthenticating(NavStackModel stack, PageModel top) {
    if (!_isAuthenticatingPage(top) || stack.pages.length > 1) {
      _pageManager.resetTo(authenticatingPage);
    }
  }

  void _handleSessionError(
    NavStackModel stack,
    PageModel top,
    SessionError state,
  ) {
    if (_isSessionErrorPage(top)) {
      return;
    }

    if (_isProtected(top) && !_isLogin(top)) {
      _pending ??= _cloneStack(stack);
    }

    _pageManager.resetTo(sessionErrorPage);
  }

  void _handleAuthenticatedOrRefreshing(
    NavStackModel stack,
    PageModel top,
    SessionState state,
  ) {
    // 1) Si hay intención previa (_pending) → restaurar
    if (_pending != null) {
      NavStackModel target = _pending!;
      _pending = null;

      if (_isLogin(target.top) || _isSessionClosed(target.top)) {
        if (target.pages.length > 1) {
          final List<PageModel> pruned = List<PageModel>.from(target.pages)
            ..removeLast();
          target = target.copyWith(pages: pruned);
        } else {
          if (!_isSameTop(stack, homeAuthenticatedPage)) {
            _pageManager.resetTo(homeAuthenticatedPage);
          }
          return;
        }
      }

      if (stack != target) {
        _pageManager.setStack(target);
      }
      return;
    }

    // 2) Si estoy en login / sessionClosed → ir a homeAuthenticated (política default)
    if ((_isLogin(top) || _isSessionClosed(top)) &&
        !_isHomeAuthed(top) &&
        goHomeWhenAuthenticatedOnLogin) {
      if (!_isSameTop(stack, homeAuthenticatedPage)) {
        _pageManager.resetTo(homeAuthenticatedPage);
      }
    }

    // 3) Si estoy en authenticatingPage y ya estoy authed → limpiar a home
    if (_isAuthenticatingPage(top) && !_isHomeAuthed(top)) {
      _pageManager.resetTo(homeAuthenticatedPage);
    }
  }

  void _applyMenusForState(SessionState state) {
    if (_isAuthed(state)) {
      configureMenusForLoggedIn?.call(appManager);
    } else {
      configureMenusForLoggedOut?.call(appManager);
    }
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _sessionSub?.cancel();
    _stackSub?.cancel();
    _sessionSub = null;
    _stackSub = null;
    _pending = null;
  }
}
