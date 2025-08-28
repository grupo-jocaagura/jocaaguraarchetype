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
    required this.page,
    required this.sessionBloc,
    required this.loginPage,
    required this.homePage,
    this.goHomeWhenAuthenticatedOnLogin = true,
  }) {
    _last = sessionBloc.stateOrDefault; // snapshot inicial (extensión shim)
    _sessionSub = sessionBloc.stream.listen((SessionState s) {
      _last = s;
      _enforcePolicy(page.stack, _last);
    });
    _stackSub = page.stackStream.listen((NavStackModel stack) {
      _enforcePolicy(stack, _last);
    });
    _enforcePolicy(page.stack, _last);
  }

  final PageManager page;
  final BlocSession sessionBloc;
  final PageModel loginPage;
  final PageModel homePage;
  final bool goHomeWhenAuthenticatedOnLogin;

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<NavStackModel>? _stackSub;

  NavStackModel? _pending;
  SessionState _last = const Unauthenticated();
  bool _disposed = false;

  // ---- State helpers ----
  bool _isAuthed(SessionState s) => s is Authenticated || s is Refreshing;
  bool _isProtected(PageModel p) => p.requiresAuth;
  bool _isLogin(PageModel p) => p.name == loginPage.name;

  void _enforcePolicy(NavStackModel stack, SessionState s) {
    if (_disposed) {
      return;
    }
    final PageModel top = stack.top;

    // Not authed on protected → go login (remember intent)
    if (!_isAuthed(s) && _isProtected(top) && !_isLogin(top)) {
      _pending = stack;
      page.resetTo(loginPage);
      return;
    }

    // Authed and have pending → restore
    if (_isAuthed(s) && _pending != null) {
      final NavStackModel target = _pending!;
      _pending = null;
      page.setStack(target);
      return;
    }

    // Unauthed while on protected → enforce login
    if (!_isAuthed(s) && _isProtected(top) && !_isLogin(top)) {
      page.resetTo(loginPage);
      return;
    }

    // Optional UX: authed on login → go home
    if (_isAuthed(s) && _isLogin(top) && goHomeWhenAuthenticatedOnLogin) {
      page.resetTo(homePage);
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

// --- Drop-in shim until jocaagura_domain adds official getters ---

/// Temporary snapshot & alias helpers for [BlocSession].
///
/// - `stream` mirrors `sessionStream` to keep a uniform API
///   (e.g., other blocs expose `.stream`).
/// - `stateOrDefault` gives a *best-effort* synchronous snapshot:
///   * `Authenticated(currentUser)` if `isAuthenticated`
///   * `Unauthenticated()` otherwise
///
/// ⚠️ Caveat:
/// This cannot reflect transitional states like `Authenticating`,
/// `Refreshing`, or `SessionError` because the internal subject
/// is not publicly exposed. Use it only to *seed* coordinators;
/// they will then rely on `stream` for precise state updates.
extension BlocSessionSnapshotX on BlocSession {
  /// Canonical alias so consumers can use `session.stream`.
  Stream<SessionState> get stream => sessionStream;

  /// Synchronous best-effort snapshot.
  ///
  /// Until the core exposes a true snapshot getter, we map the
  /// public read-only helpers to a reasonable default.
  SessionState get stateOrDefault {
    if (isAuthenticated) {
      return Authenticated(currentUser);
    }
    return const Unauthenticated();
  }
}
