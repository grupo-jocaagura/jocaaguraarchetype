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
      _last = const Unauthenticated();
    }

    Stream<SessionState> stream;
    try {
      stream = sessionBloc.stream;
    } catch (_) {
      stream = Stream<SessionState>.value(_last);
    }

    _sessionSub = stream.listen((SessionState s) {
      _last = s;
      _enforcePolicy(pageManager.stack, _last);
    });

    _stackSub = pageManager.stackStream.listen((NavStackModel stack) {
      _enforcePolicy(stack, _last);
    });

    _enforcePolicy(pageManager.stack, _last);
  }

  final PageManager pageManager;
  final BlocSession sessionBloc;
  final PageModel loginPage;
  final PageModel homePage;
  final bool goHomeWhenAuthenticatedOnLogin;

  /// Estrategia de igualdad para páginas (por defecto: ruta completa).
  final PageEquals pageEquals;

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<NavStackModel>? _stackSub;

  NavStackModel? _pending;
  SessionState _last = const Unauthenticated();
  bool _disposed = false;

  // ---- State helpers ----
  bool _isAuthed(SessionState s) => s is Authenticated || s is Refreshing;
  bool _isProtected(PageModel p) => p.requiresAuth;

  /// Considera login si coincide por "ruta" para mayor robustez (retrocompatible).
  bool _isLogin(PageModel p) => pageEquals(p, loginPage);

  /// Idempotencia básica: evita navegar si el top ya “es” la misma página destino.
  bool _isSameTop(NavStackModel stack, PageModel target) =>
      pageEquals(stack.top, target);

  /// Clona el stack para que `_pending` no comparta referencias mutables.
  NavStackModel _cloneStack(NavStackModel s) => s.copyWith(
        pages: List<PageModel>.from(s.pages),
      );
  void _enforcePolicy(NavStackModel stack, SessionState s) {
    if (_disposed) {
      return;
    }

    final PageModel top = stack.top;

    // (A) No authed en protegida → ir a login (recordando intención)
    if (!_isAuthed(s) && _isProtected(top) && !_isLogin(top)) {
      // Guarda intención solo si aún no existe; clona para evitar efectos colaterales.
      _pending ??= _cloneStack(stack);

      // Idempotencia: evita reset si ya estás en login.
      if (!_isSameTop(stack, loginPage)) {
        pageManager.resetTo(loginPage);
      }
      return;
    }

    // (B) Authed y existe intención → restaurar
    if (_isAuthed(s) && _pending != null) {
      final NavStackModel target = _pending!;
      _pending = null;

      // Idempotencia: evita setStack si el stack ya coincide (== sobre NavStackModel ya compara páginas).
      if (stack != target) {
        pageManager
            .setStack(target); // dedups ya aplican en PageManager.setStack
      }
      return;
    }

    // (C) Authed estando en login → ir a home (UX opcional)
    if (_isAuthed(s) && _isLogin(top) && goHomeWhenAuthenticatedOnLogin) {
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
  }
}
