part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Implementa un `RouterDelegate<NavStackModel>` que traduce el stack de páginas
/// del `PageManager` a una lista de `Page` para el `Navigator`.
///
/// - **Fuente de verdad:** `PageManager.stack`.
/// - **Modos de renderizado:**
///   - *Stack completo* (`projectorMode == false`): todas las páginas.
///   - *Projector/top-only* (`projectorMode == true`): solo la página del tope.
/// - **Conciliación de removals:** usa `_expectedRemovals` para distinguir entre
///   pops/replacements originados en el modelo vs. removals iniciados por el
///   `Navigator` (gestos del usuario, interacciones del sistema).
///
/// Contratos:
/// - El stack **no** debe estar vacío cuando se construye el `Navigator`.
/// - `PageRegistry` debe poder materializar cualquier `PageModel` presente en el stack.
/// - `PageManager` emite cambios por `stackStream`; el delegate llama `notifyListeners()`.
///
/// Ejemplo funcional (3 rutas):
/// ```dart
/// void main() {
///   runApp(const NavThreePagesDemo()); // ver ejemplo completo más abajo
/// }
/// ```
///
/// Notas:
/// - En la primera invocación de `setNewRoutePath`, se forzará `mustReplaceTop: true`
///   para alinear el estado inicial del modelo con la URI entrante.
/// - `onDidRemovePage` invocará `pop()` en `PageManager` solo cuando el removal
///   haya sido iniciado por el `Navigator` (no por el modelo).
class MyAppRouterDelegate extends RouterDelegate<NavStackModel>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavStackModel> {
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

  /// Devuelve la configuración de navegación actual (stack).
  @override
  NavStackModel get currentConfiguration => _pageManager.stack;

  /// Inserta una página al stack por medio del `PageManager`.
  /// Devuelve `true` si la operación fue emitida.
  bool push(PageModel page) {
    _pageManager.push(page);
    return true;
  }

  /// Solicita un `pop()` al `PageManager`.
  /// Devuelve `true` si pudo hacer pop.
  bool pop() => _pageManager.pop();

  // --- Estado para reconciliar removals -------------------------------------
  NavStackModel? _prevSnapshot;
  int _expectedRemovals = 0;

  bool _popInitiatedByDelegate = false;
  bool _navigatorSyncedOnce = false;
  @override
  Future<bool> popRoute() async {
    _popInitiatedByDelegate = true;
    final bool ok = pop();
    if (!ok) {
      // Si no hubo pop (ya en root), revertimos el flag.
      _popInitiatedByDelegate = false;
    }
    return ok;
  }

  /// Actualiza dependencias opcionales; re-vincula el listener cuando cambia `PageManager`.
  /// Si hubo cambios, reinicia el snapshot para el cómputo de removals.
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

  @override
  Widget build(BuildContext context) {
    final NavStackModel curr = _pageManager.stack;

    // ----- calcular cuántas removals esperamos del Navigator ----------------
    if (_prevSnapshot == null) {
      _expectedRemovals = 0;
    } else {
      final NavStackModel prev = _prevSnapshot!;
      if (!_projectorMode) {
        // pasamos todas las páginas → la diferencia de lengths indica pops hechos en el modelo
        _expectedRemovals = prev.pages.length > curr.pages.length
            ? prev.pages.length - curr.pages.length
            : 0;
      } else {
        // projector: siempre pasamos 1 page → inferimos del MODELO
        if (prev.pages.length > curr.pages.length) {
          // hubo pop en el modelo
          _expectedRemovals = 1;
        } else if (prev.pages.length == curr.pages.length &&
            prev.top != curr.top) {
          // replaceTop en el modelo
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
        // Consideramos "esperado" si lo calculamos o si lo inició popRoute().
        final bool expected = _expectedRemovals > 0 || _popInitiatedByDelegate;
        if (!expected && !_navigatorSyncedOnce) {
          _onPageRemoved?.call(removed);
          return;
        }
        if (expected) {
          if (_expectedRemovals > 0) {
            _expectedRemovals -= 1;
          }
          _popInitiatedByDelegate = false; // consumimos el flag
          _onPageRemoved?.call(removed);
          return; // no reenvíes a pm.pop()
        }

        // Removal iniciado por el Navigator (gesto/usuario) -> reenviar a modelo
        if (_pageManager.canPop) {
          _pageManager.pop();
        }
        _onPageRemoved?.call(removed);
      },
    );
  }

  bool _handledInitialRoute = false;

  /// Alinea el modelo con una nueva ruta (URI → `PageModel`), tratando
  /// la primera ruta como reemplazo estricto del tope.
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

  /// Cancela el listener y marca el delegate como dispuesto. Idempotente.
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

/// Ejemplo funcional (3 rutas):
/// import 'package:flutter/material.dart';
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// /// Demo mínima y autocontenida de navegación con:
/// ///  - PageRegistry (home, test-1, test-2)
/// ///  - PageManager (fuente de verdad)
/// ///  - MyAppRouterDelegate (materializa pages del stack)
/// ///  - MyRouteInformationParser (top-only, URI <-> PageModel)
/// ///
/// /// Cómo probar:
/// ///  - Desde home, pulsa "Ir a test-1".
/// ///  - En test-1, pulsa "Ir a test-2" o "Volver".
/// ///  - En test-2, prueba "Volver", "Ir a home" o "Ruta inexistente (/no-such)".
/// ///  - También escribe en la barra del navegador: /home, /test-1, /test-2, /no-such
/// void main() {
///   runApp(const NavThreePagesDemo());
/// }
///
/// /// Shell mínimo (sin usar JocaaguraApp) para aislar el router.
/// /// Aquí montamos nosotros: Provider -> MaterialApp.router
/// class NavThreePagesDemo extends StatefulWidget {
///   const NavThreePagesDemo({super.key});
///
///   @override
///   State<NavThreePagesDemo> createState() => _NavThreePagesDemoState();
/// }
///
/// class _NavThreePagesDemoState extends State<NavThreePagesDemo> {
///   late final PageRegistry _registry;
///   late final AppManager _appManager;
///   late final MyAppRouterDelegate _delegate;
///   late final MyRouteInformationParser _parser;
///   late final PlatformRouteInformationProvider _routeInfoProvider;
///
///   @override
///   void initState() {
///     super.initState();
///
///     // 1) Registry con 3 páginas y un notFound visual simple (sin redirecciones).
///     _registry = PageRegistry.fromDefs(
///       <PageDef>[
///         PageDef(
///           model: const PageModel(name: 'home', segments: <String>[]),
///           builder: (ctx, p) => const _HomePage(),
///         ),
///         PageDef(
///           model: const PageModel(name: 'test-1', segments: <String>[]),
///           builder: (ctx, p) => const _Test1Page(),
///         ),
///         PageDef(
///           model: const PageModel(name: 'test-2', segments: <String>[]),
///           builder: (ctx, p) => const _Test2Page(),
///         ),
///       ],
///       // 404 visual (sin cambiar el stack). Tap en botón => goHome()
///       notFoundBuilder: (BuildContext ctx, PageModel req) {
///         return Scaffold(
///           appBar: AppBar(title: const Text('404')),
///           body: Center(
///             child: Column(
///               mainAxisSize: MainAxisSize.min,
///               children: <Widget>[
///                 Text('Ruta no encontrada: ${req.toUriString()}'),
///                 const SizedBox(height: 16),
///                 FilledButton(
///                   onPressed: () => ctx.appManager.pageManager.goHome(),
///                   child: const Text('Ir a home'),
///                 ),
///               ],
///             ),
///           ),
///         );
///       },
///     );
///
///     // 2) AppManager real (usa PageManager interno).
///     final AppConfig cfg = AppConfig.dev(registry: _registry);
///     _appManager = AppManager(cfg);
///
///     // 3) Delegate y parser (top-only). Desactiva projectorMode para ver el stack completo.
///     _delegate = MyAppRouterDelegate(
///       registry: _registry,
///       pageManager: _appManager.pageManager,
///       projectorMode: false,
///     );
///     _parser = const MyRouteInformationParser(defaultRouteName: 'home');
///
///     // 4) Proveedor único para persistir la ubicación (URI) entre hot-reloads.
///     _routeInfoProvider = PlatformRouteInformationProvider(
///       initialRouteInformation: RouteInformation(uri: Uri(path: '/home')),
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return AppManagerProvider(
///       appManager: _appManager,
///       child: MaterialApp.router(
///         debugShowCheckedModeBanner: false,
///         routerDelegate: _delegate,
///         routeInformationParser: _parser,
///         routeInformationProvider: _routeInfoProvider,
///         theme: ThemeData(
///           colorSchemeSeed: Colors.indigo,
///           useMaterial3: true,
///           brightness: Brightness.light,
///         ),
///         darkTheme: ThemeData(
///           colorSchemeSeed: Colors.indigo,
///           useMaterial3: true,
///           brightness: Brightness.dark,
///         ),
///       ),
///     );
///   }
/// }
///
/// /// Página: HOME
/// class _HomePage extends StatelessWidget {
///   const _HomePage();
///
///   @override
///   Widget build(BuildContext context) {
///     final PageManager pm = context.appManager.pageManager;
///     return Scaffold(
///       appBar: AppBar(title: const Text('HOME')),
///       body: Center(
///         child: Wrap(
///           alignment: WrapAlignment.center,
///           spacing: 12,
///           runSpacing: 12,
///           children: <Widget>[
///             FilledButton(
///               onPressed: () => pm.pushNamed('test-1'),
///               child: const Text('Ir a test-1 (push)'),
///             ),
///             OutlinedButton(
///               onPressed: () => pm.replaceTopNamed('test-1'),
///               child: const Text('Ir a test-1 (replaceTop)'),
///             ),
///             TextButton(
///               onPressed: () => pm.navigateToLocation('/test-1'),
///               child: const Text('Ir a /test-1 (URI)'),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
///
/// /// Página: TEST-1
/// class _Test1Page extends StatelessWidget {
///   const _Test1Page();
///
///   @override
///   Widget build(BuildContext context) {
///     final PageManager pm = context.appManager.pageManager;
///     return Scaffold(
///       appBar: AppBar(title: const Text('TEST-1')),
///       body: Center(
///         child: Wrap(
///           alignment: WrapAlignment.center,
///           spacing: 12,
///           runSpacing: 12,
///           children: <Widget>[
///             FilledButton(
///               onPressed: () => pm.pushNamed('test-2'),
///               child: const Text('Ir a test-2 (push)'),
///             ),
///             OutlinedButton(
///               onPressed: () => pm.pop(),
///               child: const Text('Volver (pop)'),
///             ),
///             TextButton(
///               onPressed: () => pm.navigateToLocation('/test-2'),
///               child: const Text('Ir a /test-2 (URI)'),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
///
/// /// Página: TEST-2
/// class _Test2Page extends StatelessWidget {
///   const _Test2Page();
///
///   @override
///   Widget build(BuildContext context) {
///     final PageManager pm = context.appManager.pageManager;
///     return Scaffold(
///       appBar: AppBar(title: const Text('TEST-2')),
///       body: Center(
///         child: Wrap(
///           alignment: WrapAlignment.center,
///           spacing: 12,
///           runSpacing: 12,
///           children: <Widget>[
///             FilledButton(
///               onPressed: () => pm.pop(),
///               child: const Text('Volver (pop)'),
///             ),
///             OutlinedButton(
///               onPressed: () => pm.goNamed('home'),
///               child: const Text('Ir a home (resetTo)'),
///             ),
///             TextButton(
///               onPressed: () => pm.navigateToLocation('/no-such'),
///               child: const Text('Ruta inexistente (/no-such)'),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
