part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  NavStackModel get currentConfiguration => _pageManager.stack;

  bool push(PageModel page) {
    _pageManager.push(page);
    return true;
  }

  bool pop() => _pageManager.pop();

  // --- Estado para reconciliar removals -------------------------------------
  NavStackModel? _prevSnapshot;
  int _expectedRemovals = 0;

  @override
  Future<bool> popRoute() async => pop();

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

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (Page<Object?> removed) {
        if (_expectedRemovals > 0) {
          _expectedRemovals -= 1;
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
