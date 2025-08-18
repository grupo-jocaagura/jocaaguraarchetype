part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MyAppRouterDelegate extends RouterDelegate<PageManager>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageManager> {
  MyAppRouterDelegate(this.myPageManager) {
    myPageManager.addListener(notifyListeners);
  }
  final PageManager myPageManager;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  PageManager? get currentConfiguration => myPageManager.currentConfiguration;

  PageManager get pageManagerForTesting => myPageManager;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: myPageManager.pages,
    );
    // return const _MyNavigator();
  }

  @override
  Future<void> setNewRoutePath(PageManager configuration) async {
    configuration.update();
  }

  @override
  Future<bool> popRoute() {
    myPageManager.back();
    return Future<bool>.value(true);
  }
}
