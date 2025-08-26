part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// RouterDelegate that materializes pages from [PageManager] + [PageRegistry].
///
/// Listens to [PageManager.stackStream] and rebuilds Navigator accordingly.
class MyAppRouterDelegate extends RouterDelegate<NavStackModel>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavStackModel> {
  MyAppRouterDelegate({
    required this.registry,
    required this.pageManager,
    this.projectorMode = false,
  }) {
    _sub = pageManager.stackStream.listen((_) => notifyListeners());
  }

  final PageRegistry registry;
  final PageManager pageManager;
  final bool projectorMode;

  StreamSubscription<NavStackModel>? _sub;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  NavStackModel get currentConfiguration => pageManager.stack;

  bool push(PageModel page) {
    pageManager.push(page);
    return true;
  }

  bool pop() {
    return pageManager.pop();
  }

  @override
  Future<bool> popRoute() async => pop();

  @override
  Widget build(BuildContext context) {
    final NavStackModel stackNav = pageManager.stack;
    final List<Page<dynamic>> pages = projectorMode
        ? <Page<dynamic>>[registry.toPage(stackNav.top, position: 0)]
        : List<Page<dynamic>>.generate(
            stackNav.pages.length,
            (int i) => registry.toPage(stackNav.pages[i], position: i),
          );

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: (Page<Object?> page) => pageManager.pop,
    );
  }

  @override
  Future<void> setNewRoutePath(NavStackModel configuration) async {
    pageManager.setStack(configuration);
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
