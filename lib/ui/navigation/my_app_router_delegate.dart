part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Materializa el stack de `PageModel` en una lista de `Page` para el `Navigator`.
///
/// Fuente de verdad: `PageManager.stack`.
///
/// Modo de renderizado:
/// - **Stack completo** (`projectorMode == false`): se construye una `Page` por cada elemento del stack.
/// - **Projector/top-only** (`projectorMode == true`): solo se construye la `Page` del tope.
///
/// Conciliación de removals:
/// - Distingue removals iniciados por el **modelo** (pops/replaceTop) de los iniciados por el **Navigator** (gestos/usuario).
/// - Usa un contador `_expectedRemovals` y la marca `_popInitiatedByDelegate` para evitar reenviar `pop()` cuando ya fue atendido en el modelo.
///
/// Contratos:
/// - El stack no debe estar vacío cuando se construye el `Navigator`.
/// - `PageRegistry` debe materializar cualquier `PageModel` presente en el stack.
/// - `PageManager` emite cambios por `stackStream`; el delegate invoca `notifyListeners()`.
///
/// Ejemplo mínimo:
/// ```dart
/// void main() {
///   final PageRegistry registry = PageRegistry.fromDefs(<PageDef>[
///     PageDef(model: const PageModel(name: 'home'), builder: (_, __) => const Placeholder()),
///   ]);
///   final AppManager app = AppManager(AppConfig.dev(registry: registry));
///   final MyAppRouterDelegate delegate = MyAppRouterDelegate(
///     registry: registry,
///     pageManager: app.pageManager,
///   );
///   runApp(MaterialApp.router(
///     routerDelegate: delegate,
///     routeInformationParser: const MyRouteInformationParser(defaultRouteName: 'home'),
///   ));
/// }
/// ```
class MyAppRouterDelegate extends RouterDelegate<NavStackModel>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavStackModel> {
  /// Crea un delegate de navegación que observa el `PageManager` y construye las `pages`.
  ///
  /// - [registry]: registro capaz de convertir `PageModel` en `Page`.
  /// - [pageManager]: fuente de verdad del stack.
  /// - [projectorMode]: si es `true`, solo se renderiza la página del tope.
  /// - [userBackNavigationPolicy]: optional decision before user back navigation leaves a page.
  /// - [onPageRemoved]: callback opcional cuando el `Navigator` reporta una página removida.
  MyAppRouterDelegate({
    required PageRegistry registry,
    required PageManager pageManager,
    bool projectorMode = false,
    UserBackNavigationPolicy? userBackNavigationPolicy,
    void Function(Page<Object?> removedPage)? onPageRemoved,
  })  : _registry = registry,
        _pageManager = pageManager,
        _projectorMode = projectorMode,
        _userBackNavigationPolicy = userBackNavigationPolicy,
        _onPageRemoved = onPageRemoved {
    _sub = _pageManager.stackStream.listen(_onStackChanged);
  }

  PageRegistry _registry;
  PageManager _pageManager;
  bool _projectorMode;
  final void Function(Page<Object?> removedPage)? _onPageRemoved;

  StreamSubscription<NavStackModel>? _sub;

  UserBackNavigationPolicy? _userBackNavigationPolicy;
  Object? _pendingBack;
  int _routeRequest = 0;
  final _UserBackRouteObserver _routeObserver = _UserBackRouteObserver();

  /// Optional application policy. Changing it invalidates pending decisions.
  /// Equal method tear-offs preserve pending decisions across rebuilds.
  /// Keep the policy installed and return false/true as application state changes.
  /// Switching between null and a policy recreates page routes; local widget
  /// state is not guaranteed to survive that transition.
  UserBackNavigationPolicy? get userBackNavigationPolicy =>
      _userBackNavigationPolicy;
  set userBackNavigationPolicy(UserBackNavigationPolicy? value) {
    if (value == _userBackNavigationPolicy) {
      return;
    }
    _userBackNavigationPolicy = value;
    _pendingBack = null;
    _routeRequest++;
    notifyListeners();
  }

  void _onStackChanged(NavStackModel _) {
    _pendingBack = null;
    _routeRequest++;
    notifyListeners();
  }

  bool _protectsPage(LocalKey? key) {
    if (_isDisposed || _userBackNavigationPolicy == null) {
      return false;
    }
    final List<PageModel> pages = _pageManager.stack.pages;
    for (int i = _projectorMode ? pages.length - 1 : 0; i < pages.length; i++) {
      if (_registry.toPage(pages[i], position: i).key == key) {
        return true;
      }
    }
    return false;
  }

  bool _isTopPage(LocalKey? key) {
    if (_isDisposed) {
      return false;
    }
    final NavStackModel stack = _pageManager.stack;
    return _registry.toPage(stack.top, position: stack.pages.length - 1).key ==
        key;
  }

  Future<bool> _allowsUserBack(
    UserBackNavigationRequest request,
    VoidCallback onAllowed,
  ) async {
    final UserBackNavigationPolicy? policy = _userBackNavigationPolicy;
    if (policy == null) {
      onAllowed();
      return true;
    }
    if (_pendingBack != null || _isDisposed) {
      return false;
    }
    final Object token = Object();
    final PageManager manager = _pageManager;
    final NavStackModel snapshot = manager.stack;
    _pendingBack = token;
    try {
      final bool allowed = await policy(request);
      if (allowed &&
          !_isDisposed &&
          identical(_pendingBack, token) &&
          identical(manager, _pageManager) &&
          identical(snapshot, manager.stack)) {
        onAllowed();
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'jocaaguraarchetype',
          context: ErrorDescription('while deciding user back navigation'),
        ),
      );
      return false;
    } finally {
      if (identical(_pendingBack, token)) {
        _pendingBack = null;
      }
    }
  }

  /// Handles a user request. A rejected request returns true (consumed), so
  /// Android does not interpret it as a request to exit the application.
  /// Application-driven navigation can continue to use [pop] or PageManager.
  /// With a policy installed, Flutter local history and PopScope/Page.canPop
  /// take precedence. They are checked again when an async policy approves.
  Future<bool> requestUserBack({
    UserBackNavigationSource source = UserBackNavigationSource.system,
  }) async {
    if (_isDisposed) {
      return true;
    }
    if (_userBackNavigationPolicy != null) {
      if (_consumeFlutterBack()) {
        return true;
      }
      final NavStackModel stack = _pageManager.stack;
      bool popped = false;
      final bool allowed = await _allowsUserBack(
          UserBackNavigationRequest(
            source: source,
            currentPage: stack.top,
            targetPage:
                stack.isRoot ? null : stack.pages[stack.pages.length - 2],
          ), () {
        popped = _consumeFlutterBack() || _popFromDelegate();
      });
      return !allowed || popped;
    }
    return _popFromDelegate();
  }

  bool _consumeFlutterBack() {
    final Route<dynamic>? route = _routeObserver.top;
    if (route == null || !route.isCurrent) {
      return false;
    }
    if (route.popDisposition == RoutePopDisposition.doNotPop) {
      route.onPopInvokedWithResult(false, null);
      return true;
    }
    if (route.willHandlePopInternally) {
      navigatorKey.currentState!.pop();
      return true;
    }
    return false;
  }

  bool _popFromDelegate() {
    _popInitiatedByDelegate = true;
    final bool ok = pop();
    if (!ok) {
      _popInitiatedByDelegate = false;
    }
    return ok;
  }

  Future<void> _requestNavigatorBack(
    _UserBackRoute route,
    dynamic result,
  ) async {
    final PageManager manager = _pageManager;
    final NavStackModel snapshot = manager.stack;
    await _allowsUserBack(
      UserBackNavigationRequest(
        source: UserBackNavigationSource.navigator,
        currentPage: snapshot.top,
        targetPage:
            snapshot.isRoot ? null : snapshot.pages[snapshot.pages.length - 2],
      ),
      () {
        if (!route.isCurrent || !manager.canPop) {
          return;
        }
        // Complete the original route through Navigator, retaining its result
        // and callbacks. A callback may itself perform a security reset.
        final bool didLeave = route._commitPop(result);
        if (didLeave &&
            !_isDisposed &&
            identical(manager, _pageManager) &&
            identical(snapshot, manager.stack)) {
          _popFromDelegate();
        }
      },
    );
  }

  /// Clave del `Navigator` interno.
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Devuelve la configuración de navegación actual.
  @override
  NavStackModel get currentConfiguration => _userBackNavigationPolicy == null
      ? _pageManager.stack
      : _UserHistoryStack(
          _pageManager.stack,
          null,
          stackIndex: _pageManager.stack.pages.length - 1,
        );

  /// Inserta una página a través del `PageManager`.
  ///
  /// Retorna `true` si la operación se emitió.
  bool push(PageModel page) {
    _pageManager.push(page);
    return true;
  }

  /// Solicita un `pop()` al `PageManager`.
  ///
  /// Retorna `true` si se pudo hacer pop.
  bool pop() => _pageManager.pop();

  NavStackModel? _prevSnapshot;
  int _expectedRemovals = 0;

  bool _popInitiatedByDelegate = false;
  bool _navigatorSyncedOnce = false;

  /// Consulta la política para el back del sistema antes de mutar el stack.
  @override
  Future<bool> popRoute() => requestUserBack();

  /// Actualiza dependencias y re-vincula el listener si cambia el `PageManager`.
  ///
  /// Reinicia el snapshot y el cómputo de removals cuando hay cambios y notifica listeners.
  void update({
    PageRegistry? registry,
    PageManager? pageManager,
    bool? projectorMode,
  }) {
    bool changed = false;
    if (pageManager != null && !identical(pageManager, _pageManager)) {
      _sub?.cancel();
      _pageManager = pageManager;
      _sub = _pageManager.stackStream.listen(_onStackChanged);
      changed = true;
    }
    if (registry != null && !identical(registry, _registry)) {
      _registry = registry;
      changed = true;
    }
    if (projectorMode != null && projectorMode != _projectorMode) {
      _projectorMode = projectorMode;
      changed = true;
    }
    if (changed) {
      _pendingBack = null;
      _routeRequest++;
      _prevSnapshot = _pageManager.stack;
      _expectedRemovals = 0;
      notifyListeners();
    }
  }

  /// Construye el `Navigator` con la lista de `pages` derivada del stack.
  @override
  Widget build(BuildContext context) {
    final NavStackModel curr = _pageManager.stack;

    if (_prevSnapshot == null) {
      _expectedRemovals = 0;
    } else {
      final NavStackModel prev = _prevSnapshot!;
      if (!_projectorMode) {
        _expectedRemovals = prev.pages.length > curr.pages.length
            ? prev.pages.length - curr.pages.length
            : 0;
      } else {
        if (prev.pages.length > curr.pages.length) {
          _expectedRemovals = 1;
        } else if (prev.top != curr.top) {
          _expectedRemovals = 1;
        } else {
          _expectedRemovals = 0;
        }
      }
    }
    _prevSnapshot = curr;

    final List<Page<dynamic>> registryPages = _projectorMode
        ? <Page<dynamic>>[
            _registry.toPage(curr.top, position: curr.pages.length - 1),
          ]
        : List<Page<dynamic>>.generate(
            curr.pages.length,
            (int i) => _registry.toPage(curr.pages[i], position: i),
          );

    final List<Page<dynamic>> pages = _userBackNavigationPolicy == null
        ? registryPages
        : registryPages
            .map((Page<dynamic> page) => _UserBackNavigationPage(page, this))
            .toList(growable: false);

    if (!_navigatorSyncedOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorSyncedOnce = true;
      });
    }

    return Navigator(
      key: navigatorKey,
      observers: <NavigatorObserver>[_routeObserver],
      pages: pages,
      onDidRemovePage: (Page<Object?> removed) {
        if (_userBackNavigationPolicy != null) {
          // Guarded route pops already went through the model. Never translate
          // a completion notification into another mutation.
          _popInitiatedByDelegate = false;
          _onPageRemoved?.call(
            removed is _UserBackNavigationPage ? removed.original : removed,
          );
          return;
        }
        final bool expected = _expectedRemovals > 0 || _popInitiatedByDelegate;
        if (!expected && !_navigatorSyncedOnce) {
          _onPageRemoved?.call(removed);
          return;
        }
        if (expected) {
          if (_expectedRemovals > 0) {
            _expectedRemovals -= 1;
          }
          _popInitiatedByDelegate = false;
          _onPageRemoved?.call(removed);
          return;
        }
        if (_pageManager.canPop) {
          _pageManager.pop();
        }
        _onPageRemoved?.call(removed);
      },
    );
  }

  bool _handledInitialRoute = false;

  @override
  Future<void> setInitialRoutePath(NavStackModel configuration) {
    if (_userBackNavigationPolicy == null) {
      return setNewRoutePath(configuration);
    }
    _applyRoutePath(configuration);
    _handledInitialRoute = true;
    return SynchronousFuture<void>(null);
  }

  @override
  Future<void> setRestoredRoutePath(NavStackModel configuration) {
    if (_userBackNavigationPolicy == null) {
      return setNewRoutePath(configuration);
    }
    _pendingBack = null;
    _routeRequest++;
    _applyRoutePath(configuration);
    _handledInitialRoute = true;
    return SynchronousFuture<void>(null);
  }

  /// Alinea el modelo con una nueva ruta, forzando `mustReplaceTop: true` en la primera invocación.
  @override
  Future<void> setNewRoutePath(NavStackModel configuration) async {
    final int request = ++_routeRequest;
    if (_userBackNavigationPolicy != null && _handledInitialRoute) {
      final bool historyRequest = configuration is! _UserHistoryStack ||
          (configuration.backward ?? true);
      if (historyRequest) {
        await _allowsUserBack(
            UserBackNavigationRequest(
              source: UserBackNavigationSource.browserHistory,
              currentPage: _pageManager.stack.top,
              targetPage: configuration.top,
            ), () {
          if (request == _routeRequest) {
            _applyUserHistoryPath(configuration);
          }
        });
        // Router republishes currentConfiguration when this Future completes.
        // UserBackRouteInformationProvider replaces the rejected browser URL.
        return;
      } else {
        _pendingBack = null;
      }
    }
    _applyRoutePath(configuration);
  }

  void _applyUserHistoryPath(NavStackModel configuration) {
    final List<PageModel> pages = _pageManager.stack.pages;
    final int? historyIndex =
        configuration is _UserHistoryStack ? configuration.stackIndex : null;
    final String uri = configuration.top.toUriString();
    final int index = historyIndex != null &&
            historyIndex >= 0 &&
            historyIndex < pages.length &&
            pages[historyIndex].toUriString() == uri
        ? historyIndex
        : pages.lastIndexWhere((PageModel page) => page.toUriString() == uri);
    if (index >= 0) {
      // Preserve application metadata and the structural stack when going back.
      if (index < pages.length - 1) {
        _pageManager.setStack(
          NavStackModel(pages.take(index + 1).toList()),
          allowDuplicate: true,
        );
      }
    } else {
      _applyRoutePath(configuration);
    }
  }

  void _applyRoutePath(NavStackModel configuration) {
    final PageModel target = configuration.top;
    if (_userBackNavigationPolicy != null &&
        _pageManager.stack.top.toUriString() == target.toUriString()) {
      if (configuration is _UserHistoryStack &&
          configuration.backward == false &&
          configuration.stackIndex == _pageManager.stack.pages.length) {
        _pageManager.push(target, allowDuplicate: true);
      }
      return;
    }
    if (_pageManager.stack.top == target) {
      return;
    }
    if (!_handledInitialRoute) {
      _handledInitialRoute = true;
      _pageManager.navigateToLocation(
        target.toUriString(),
        name: target.name,
        kind: target.kind,
        mustReplaceTop: true,
      );
    } else {
      _pageManager.navigateToLocation(
        target.toUriString(),
        name: target.name,
        kind: target.kind,
      );
    }
  }

  /// Indica si `dispose()` ya fue invocado.
  bool get isDisposed => _isDisposed;
  bool _isDisposed = false;

  /// Cancela el listener y marca el delegate como dispuesto. Es idempotente.
  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _pendingBack = null;
    _routeRequest++;
    _sub?.cancel();
    super.dispose();
  }
}
