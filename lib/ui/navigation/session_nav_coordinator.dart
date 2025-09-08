part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Coordinates session-aware navigation over PageManager + BlocSession.
///
/// Policy:
/// - If top page requires auth and user is NOT authenticated → redirect to `loginPage`
///   and remember the full intended stack (`_pending`).
/// - When session becomes authenticated → restore `_pending` if present; otherwise
///   optionally go to `homePage`.
/// - On logout/expiration (or SessionError treated as unauth) while on a protected page →
///   reset to `loginPage`.
/// - Treat `Refreshing(prev)` as authenticated (do NOT kick to login while refreshing).
///
/// Works with projectorMode = true/false.
/// Pure/controller-only (no Widgets).
/// Coordinates session-aware navigation over PageManager + BlocSession.
///
/// See policy in class docs of previous version (unchanged).
class SessionNavCoordinator {
  SessionNavCoordinator({
    required this.pageManager,
    required this.sessionBloc,
    required this.loginPage,
    required this.homePage,
    this.goHomeWhenAuthenticatedOnLogin = true,
    this.pageEquals = _routeEquals,
  }) {
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

    Stream<SessionState> stream;
    try {
      stream = sessionBloc.stream;
    } catch (_) {
      try {
        stream = sessionBloc.sessionStream;
      } catch (_) {
        stream = Stream<SessionState>.value(_last);
      }
    }

    _lastTop = pageManager.stack.top;

    _sessionSub = stream.listen((SessionState s) {
      _last = s;
      // Opcional: _prevTopForGoHome = null;  // si buscas “olvidar” rebotes tras evento de sesión
      _enforcePolicy(pageManager.stack, _last);
    });

    _stackSub = pageManager.stackStream.listen((NavStackModel stack) {
      final PageModel prevTop = _lastTop ?? stack.top;
      _lastTop = stack.top;

      if (!_isAuthed(_last) && _isLogin(prevTop) && !_isLogin(stack.top)) {
        _pending = null;
      }

      _prevTopForGoHome = prevTop;

      _enforcePolicy(stack, _last);

      // NO lo limpies aquí.
    });

    _enforcePolicy(pageManager.stack, _last);
  }

  final PageManager pageManager;
  final BlocSession sessionBloc;
  final PageModel loginPage;
  final PageModel homePage;
  final bool goHomeWhenAuthenticatedOnLogin;
  final PageEquals pageEquals;

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<NavStackModel>? _stackSub;

  NavStackModel? _pending;
  SessionState _last = const Unauthenticated();

  PageModel? _lastTop;
  PageModel? _prevTopForGoHome;

  bool _disposed = false;

  bool _isAuthed(SessionState s) => s is Authenticated || s is Refreshing;
  bool _isProtected(PageModel p) => p.requiresAuth;
  bool _isLogin(PageModel p) => pageEquals(p, loginPage);
  bool _isSameTop(NavStackModel stack, PageModel target) =>
      pageEquals(stack.top, target);

  NavStackModel _cloneStack(NavStackModel s) =>
      s.copyWith(pages: List<PageModel>.from(s.pages));

  bool canApplyGoHome(NavStackModel stack) {
    if (!goHomeWhenAuthenticatedOnLogin) {
      return false;
    }
    if (!_isAuthed(_last)) {
      return false;
    }
    if (!_isLogin(stack.top)) {
      return false;
    }
    if (_pending != null) {
      return false;
    }

    // Si este enforce viene de un evento de stack y el top previo NO era login,
    // es un rebote; no aplicar (C).
    final PageModel? prev = _prevTopForGoHome;
    if (prev != null && !_isLogin(prev)) {
      return false;
    }

    return true;
  }

  void _enforcePolicy(NavStackModel stack, SessionState s) {
    if (_disposed) {
      return;
    }

    final PageModel top = stack.top;

    // (A) No authed en protegida → ir a login (recordando intención)
    final bool needRedirectToLogin =
        !_isAuthed(s) && _isProtected(top) && !_isLogin(top);

    if (needRedirectToLogin) {
      _pending ??= _cloneStack(stack);
      if (!_isSameTop(stack, loginPage)) {
        pageManager.resetTo(loginPage);
      }
      return;
    }

    // (B) Authed y existe intención → restaurar
    if (_isAuthed(s) && _pending != null) {
      NavStackModel target = _pending!;
      _pending = null;

      // Si el pending termina en login, evitamos quedarnos en login.
      if (_isLogin(target.top)) {
        if (target.pages.length > 1) {
          final List<PageModel> pruned = List<PageModel>.from(target.pages);
          pruned.removeLast(); // quita login final
          target = target.copyWith(pages: pruned);
        } else {
          // Solo login: caer a home
          if (!_isSameTop(stack, homePage)) {
            pageManager.resetTo(homePage);
          }
          return;
        }
      }

      if (stack != target) {
        pageManager.setStack(target);
      }
      return;
    }

    // (C) Authed en login → ir a home (solo cuando aplica)
    if (canApplyGoHome(stack)) {
      if (!_isSameTop(stack, homePage)) {
        pageManager.resetTo(homePage);
      }
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
    _lastTop = null;
  }
}
