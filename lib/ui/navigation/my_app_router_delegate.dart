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
  /// - [onPageRemoved]: callback opcional cuando el `Navigator` reporta una página removida.
  MyAppRouterDelegate({
    required PageRegistry registry,
    required PageManager pageManager,
    bool projectorMode = false,
    void Function(Page<Object?> removedPage)? onPageRemoved,
  })  : _registry = registry,
        _pageManager = pageManager,
        _projectorMode = projectorMode,
        _onPageRemoved = onPageRemoved {
    _sub = _pageManager.stackStream.listen((_) => notifyListeners());
  }

  PageRegistry _registry;
  PageManager _pageManager;
  bool _projectorMode;
  final void Function(Page<Object?> removedPage)? _onPageRemoved;

  StreamSubscription<NavStackModel>? _sub;

  /// Clave del `Navigator` interno.
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Devuelve la configuración de navegación actual.
  @override
  NavStackModel get currentConfiguration => _pageManager.stack;

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

  /// Maneja el back del sistema reenviando a `pop()`.
  @override
  Future<bool> popRoute() async {
    _popInitiatedByDelegate = true;
    final bool ok = pop();
    if (!ok) {
      _popInitiatedByDelegate = false;
    }
    return ok;
  }

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
      _sub = _pageManager.stackStream.listen((_) => notifyListeners());
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

    final List<Page<dynamic>> pages = _projectorMode
        ? <Page<dynamic>>[
            _registry.toPage(curr.top, position: curr.pages.length - 1),
          ]
        : List<Page<dynamic>>.generate(
            curr.pages.length,
            (int i) => _registry.toPage(curr.pages[i], position: i),
          );

    if (!_navigatorSyncedOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorSyncedOnce = true;
      });
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (Page<Object?> removed) {
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

  /// Alinea el modelo con una nueva ruta, forzando `mustReplaceTop: true` en la primera invocación.
  @override
  Future<void> setNewRoutePath(NavStackModel configuration) async {
    final PageModel target = configuration.top;
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
    _sub?.cancel();
    super.dispose();
  }
}
