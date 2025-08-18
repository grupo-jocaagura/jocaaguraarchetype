part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

const String _k404Name = '/404';

/// A class for managing application pages and navigation.
///
/// The `PageManager` class handles navigation state, page history, and routing.
/// It supports deep linking, dynamic page management, and route validation.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/page_manager.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final pageManager = PageManager();
///
///   // Set the home page
///   pageManager.setHomePage(Text('Welcome Home'));
///
///   // Add a new page
///   pageManager.push('/about', Text('About Page'));
///
///   // Remove a page from the history
///   pageManager.removePageFromRoute('/about');
///
///   // Navigate to a 404 page
///   pageManager.goTo404Page();
/// }
/// ```
class PageManager extends ChangeNotifier {
  /// Creates an instance of `PageManager` with optional [routeInformation].
  ///
  /// Initializes the home page and 404 page with default widgets.
  PageManager([this.routeInformation]) {
    setHomePage(
      const Text('Home no definido'),
    );
    set404Page(
      Page404Widget(pageManager: this),
    );
  }

  PageManager.fromRouteInformation(
    this.routeInformation,
    PageManager currentPageManager,
  ) {
    setHomePage(currentPageManager._onBoardingPage);
    set404Page(currentPageManager._page404Widget);
    _pages.clear();
    _pages.addAll(currentPageManager.getAllPages);
    if (routeInformation != null) {
      final Uri uri = routeInformation?.uri ?? Uri.parse('');
      final MaterialPage<dynamic> page = currentPageManager
          .getPageFromDirectory(uri.path, arguments: uri.queryParametersAll);
      currentPageManager.push('/', _onBoardingPage);
      currentPageManager.pushFromRoutesettings(uri.path, page);
    }
  }

  /// The 404 error page widget.
  late Widget _page404Widget;

  /// The onboarding page widget.
  late Widget _onBoardingPage;

  /// Gets the current 404 page widget.
  Widget get page404Widget => _page404Widget;

  /// Gets the onboarding page widget.
  Widget get onBoardingPage => _onBoardingPage;

  /// Notifies listeners of state updates.
  void update() {
    notifyListeners();
  }

  /// Removes a page from the route history by [route].
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.removePageFromRoute('/about');
  /// ```
  void removePageFromRoute(String route) {
    _removePageFromRoute(route);
    notifyListeners();
  }

  void _removePageFromRoute(String route) {
    if (route == '/') {
      return;
    }
    _directoryPagesMap.remove(route);
    final List<MaterialPage<dynamic>> tmpPages = <MaterialPage<dynamic>>[];
    for (final MaterialPage<dynamic> tmp in _pages) {
      if (tmp.name != route) {
        tmpPages.add(tmp);
      }
    }
    _pages.clear();
    _pages.addAll(tmpPages);
  }

  /// Sets the home page with the provided [widget] and optional [arguments].
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.setHomePage(Text('Welcome Home'));
  /// ```
  String setPageTitle(String title, [int? color]) {
    title = title.replaceAll('/', ' ').trim();
    if (kIsWeb) {
      try {
        SystemChrome.setApplicationSwitcherDescription(
          ApplicationSwitcherDescription(
            label: title,
            primaryColor: color, // This line is required
          ),
        );
      } catch (e) {
        debugPrint('$e');
      }
    }
    return title;
  }

  final BlocGeneral<int> _pageController = BlocGeneral<int>(1);

  Stream<int> get pagesStream => _pageController.stream;

  final Map<String, MaterialPage<dynamic>> _directoryPagesMap =
      <String, MaterialPage<dynamic>>{};

  List<String> get directoryOfPages => _directoryPagesMap.keys.toList();

  void registerPageToDirectory({
    required String routeName,
    required Widget widget,
    Object? arguments,
  }) {
    routeName = validateRouteName(routeName);
    _directoryPagesMap[routeName] = MaterialPage<dynamic>(
      name: routeName,
      child: widget,
      arguments: arguments,
    );
  }

  void removePageFromDirectory(String routeName) {
    _directoryPagesMap.remove(routeName);
    notifyListeners();
  }

  void _cleanDuplicateHomePages() {
    if (_pages.length > 1) {
      final List<MaterialPage<dynamic>> tmpPages = <MaterialPage<dynamic>>[
        _pages[0],
      ];
      for (int i = 1; i < _pages.length; i++) {
        final MaterialPage<dynamic> value = _pages[i];
        if (value.name != '/') {
          tmpPages.add(value);
        }
      }
      _pages.clear();
      _pages.addAll(tmpPages);
    }
  }

  void setHomePage(Widget widget, [Object? arguments]) {
    /// This acts like the base of the navigator the main idea is first set the starting functions,
    _directoryPagesMap['/'] = MaterialPage<dynamic>(
      name: '/',
      key: UniqueKey(),
      child: widget,
      arguments: arguments,
    );
    _pages[0] = _directoryPagesMap['/']!;
    _cleanDuplicateHomePages();
    _onBoardingPage = widget;
  }

  /// Sets the 404 page with the provided [widget] and optional [arguments].
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.set404Page(Text('Page Not Found'));
  /// ```
  void set404Page(Widget widget, [Object? arguments]) {
    _directoryPagesMap[_k404Name] = MaterialPage<dynamic>(
      name: _k404Name,
      key: UniqueKey(),
      child: widget,
      arguments: arguments,
    );
    _page404Widget = widget;
  }

  final List<MaterialPage<dynamic>> _pages = <MaterialPage<dynamic>>[
    MaterialPage<dynamic>(
      name: '/',
      key: UniqueKey(),
      child: const Center(
        child: Text(':)'),
      ),
    ),
  ];
  List<MaterialPage<dynamic>> get history => _pages;

  PageManager get currentConfiguration => this;

  bool isThisRouteNameInDirectory(String routeName) {
    return _directoryPagesMap.containsKey(validateRouteName(routeName));
  }

  String validateRouteName(String routeName) {
    if (routeName.isEmpty || routeName[0] != '/') {
      routeName = '/$routeName';
    }
    return routeName;
  }

  /// Pushes a new page onto the navigation stack.
  ///
  /// The [routeName], [widget], and optional [arguments] define the page to add.
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.push('/profile', Text('Profile Page'));
  /// ```
  void push(String routeName, Widget widget, [Object? arguments]) {
    routeName = validateRouteName(routeName);
    final MaterialPage<dynamic> page = MaterialPage<dynamic>(
      name: routeName,
      key: ValueKey<String>(routeName),
      child: widget,
      arguments: arguments,
    );
    _directoryPagesMap[routeName] = page;
    _pages.remove(page);
    _pages.add(page);
    _pageController.value = _pages.length;
    notifyListeners();
  }

  /// Pushes a new page and replaces the current page.
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.pushAndReplacement('/dashboard', Text('Dashboard'));
  /// ```
  void pushAndReplacement(
    String routeName,
    Widget widget, [
    Object? arguments,
  ]) {
    back();
    push(routeName, widget, arguments);
  }

  void pushNamed(String routeName, [Object? arguments]) {
    final Widget widget = getPageFromDirectory(routeName).child;
    push(routeName, widget, arguments);
  }

  void pushNamedAndReplacement(String routeName, [Object? arguments]) {
    back();
    final Widget widget = getPageFromDirectory(routeName).child;
    push(routeName, widget, arguments);
  }

  void pushFromRoutesettings(
    String routeName,
    MaterialPage<dynamic> routeSettings,
  ) {
    if (validateRouteName(routeName).length > 1) {
      _pages.remove(routeSettings);
      _pages.add(routeSettings);
      _pageController.value = _pages.length;
      notifyListeners();
    }
  }

  int get historyPagesCount => _pages.length;

  RouteSettings get currentPage => _pages.last;

  List<Page<dynamic>> get pages =>
      <Page<dynamic>>[List<Page<dynamic>>.unmodifiable(_pages).last];
  final RouteInformation? routeInformation;

  List<MaterialPage<dynamic>> get getAllPages =>
      List<MaterialPage<dynamic>>.unmodifiable(_pages);
  void pop() {
    back();
  }

  /// Navigates back to the previous page in the stack.
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.back();
  /// ```
  void back() {
    if (_pages.length > 1) {
      _pages.removeLast();
      notifyListeners();
    }
  }

  bool didPop(Route<dynamic> route, dynamic result) {
    back();
    return true;
  }

  @override
  void dispose() {
    _pages.clear();
    _pageController.close();
    _directoryPagesMap.clear();
    super.dispose();
  }

  MaterialPage<dynamic> getPageFromDirectory(
    String routeName, {
    Object? arguments,
  }) {
    MaterialPage<dynamic> page = get404PageFromDirectory(arguments);
    if (isThisRouteNameInDirectory(routeName)) {
      page = _directoryPagesMap[routeName]!;
      page = MaterialPage<dynamic>(
        name: routeName,
        key: page.key,
        arguments: arguments,
        child: page.child,
      );
    }
    return page;
  }

  MaterialPage<dynamic> get404PageFromDirectory([Object? arguments]) {
    if (!_directoryPagesMap.containsKey(_k404Name)) {
      set404Page(_page404Widget, arguments);
    }
    MaterialPage<dynamic> page = _directoryPagesMap[_k404Name]!;
    page = MaterialPage<dynamic>(
      child: page.child,
      arguments: arguments,
      key: page.key,
      name: page.name,
    );
    return page;
  }

  /// Navigates to the 404 error page.
  ///
  /// ## Example
  ///
  /// ```dart
  /// pageManager.goTo404Page();
  /// ```
  void goTo404Page([Object? arguments]) {
    pushFromRoutesettings(_k404Name, get404PageFromDirectory(arguments));
  }

  /// Retrieves the current route information as `RouteInformation`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final routeInfo = pageManager.getCurrentUrl();
  /// print(routeInfo?.location);
  /// ```
  RouteInformation? getCurrentUrl() {
    final Uri uri = Uri(
      path: currentPage.name,
      queryParameters: currentPage.arguments as Map<String, dynamic>?,
    );
    String location = uri.path;
    if (uri.query.isNotEmpty) {
      location = '$location?${uri.query}';
    }
    return RouteInformation(
      uri: Uri.parse(location),
    );
  }

  void clearHistory() {
    final MaterialPage<dynamic> tmp = _pages[0];
    _pages.clear();
    _pages.add(tmp);
    notifyListeners();
  }
}
