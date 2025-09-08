part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// RouterDelegate that materializes pages from [PageManager] + [PageRegistry].
///
/// Listens to [PageManager.stackStream] and rebuilds Navigator accordingly.
class MyAppRouterDelegate extends RouterDelegate<NavStackModel>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavStackModel> {
  MyAppRouterDelegate({
    required PageRegistry registry,
    required PageManager pageManager,
    bool projectorMode = false,
  })  : _registry = registry,
        _pageManager = pageManager,
        _projectorMode = projectorMode {
    _sub = _pageManager.stackStream.listen((_) => notifyListeners());
  }

  // --- Mutable backing fields (se actualizan vía update(...)) ---
  PageRegistry _registry;
  PageManager _pageManager;
  bool _projectorMode;

  StreamSubscription<NavStackModel>? _sub;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  NavStackModel get currentConfiguration => _pageManager.stack;

  // ------------------- PUBLIC API -------------------

  /// Push a [PageModel] on top of the current stack.
  bool push(PageModel page) {
    _pageManager.push(page);
    return true;
  }

  /// Pop current page (no-op if root). Returns whether a pop occurred.
  bool pop() => _pageManager.pop();

  @override
  Future<bool> popRoute() async => pop();

  /// Update delegate dependencies without recreating the instance.
  ///
  /// - Re-subscribes to the new [pageManager] if it changed.
  /// - Updates [registry] and [projectorMode].
  /// - Calls [notifyListeners] only when something actually changed.
  ///
  /// ### Example
  /// ```dart
  /// _delegate.update(
  ///   registry: newRegistry,
  ///   pageManager: newPageManager,
  ///   projectorMode: true,
  /// );
  /// ```
  void update({
    PageRegistry? registry,
    PageManager? pageManager,
    bool? projectorMode,
  }) {
    bool changed = false;

    // 1) pageManager: manejar resuscripción segura
    if (pageManager != null && !identical(pageManager, _pageManager)) {
      // cancelar la suscripción anterior
      _sub?.cancel();
      _pageManager = pageManager;
      // nueva suscripción
      _sub = _pageManager.stackStream.listen((_) => notifyListeners());
      changed = true;
    }

    // 2) registry
    if (registry != null && !identical(registry, _registry)) {
      _registry = registry;
      changed = true;
    }

    // 3) projectorMode
    if (projectorMode != null && projectorMode != _projectorMode) {
      _projectorMode = projectorMode;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // ------------------- BUILD -------------------

  @override
  Widget build(BuildContext context) {
    final NavStackModel stackNav = _pageManager.stack;
    if (_projectorMode) {
      final int topIndex = stackNav.pages.length - 1;
      return Navigator(
        key: navigatorKey,
        pages: <Page<dynamic>>[
          _registry.toPage(stackNav.top, position: topIndex),
        ],
        onDidRemovePage: (Page<Object?> page) {},
      );
    }
    final List<Page<dynamic>> pages = _projectorMode
        ? <Page<dynamic>>[_registry.toPage(stackNav.top, position: 0)]
        : List<Page<dynamic>>.generate(
            stackNav.pages.length,
            (int i) => _registry.toPage(stackNav.pages[i], position: i),
          );

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (Page<Object?> page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(NavStackModel configuration) async {
    _pageManager.setStack(configuration);
  }

  bool get isDisposed => _isDisposed;
  bool _isDisposed = false;

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
