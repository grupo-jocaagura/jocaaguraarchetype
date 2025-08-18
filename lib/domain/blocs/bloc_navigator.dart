part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A BLoC (Business Logic Component) for managing navigation and routing.
///
/// The `BlocNavigator` class acts as a bridge between the UI and the navigation
/// logic. It interacts with a `PageManager` to handle page transitions,
/// dynamic links, and navigation history.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_navigator.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final pageManager = PageManager();
///   final blocNavigator = BlocNavigator(pageManager);
///
///   blocNavigator.setHomePage(Text('Home Page'));
///
///   blocNavigator.pushPage('/about', Text('About Page'));
///   print('Current history: ${blocNavigator.historyPageNames}');
///
///   blocNavigator.back();
/// }
/// ```
class BlocNavigator extends BlocModule {
  /// Creates an instance of `BlocNavigator` with the provided [pageManager].
  ///
  /// Optionally, a [homePage] can be provided to set the initial page.
  /// Initializes the router delegate and route information parser.
  BlocNavigator(this.pageManager, [Widget? homePage]) {
    if (homePage != null) {
      setHomePage(homePage);
    }
    routerDelegate = MyAppRouterDelegate(pageManager);
    routeInformationParser = MyAppRouteInformationParser(pageManager);
  }

  /// The name identifier for the BLoC, used for tracking or debugging.
  static String name = 'blocNavigator';

  /// The `PageManager` instance used for handling navigation logic.
  final PageManager pageManager;

  /// Indicates whether the back button should be shown.
  ///
  /// Returns `true` if there are more than one page in the history.
  bool get showBackButton => historyPageLength > 1;

  /// The router delegate for handling navigation state.
  late final MyAppRouterDelegate routerDelegate;

  /// The route information parser for handling route parsing and restoration.
  late final MyAppRouteInformationParser routeInformationParser;

  /// Navigates back to the previous page in the history.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.back();
  /// ```
  void back() {
    pageManager.back();
  }

  /// The current page title.
  String _title = '';

  /// Gets the current page title.
  String get title => _title;

  /// Gets the length of the navigation history.
  int get historyPageLength => pageManager.historyPagesCount;

  /// Sets the page title and updates the page manager.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.setTitle('New Page Title');
  /// ```
  void setTitle(String title) {
    _title = title;
    pageManager.setPageTitle(title);
  }

  /// Notifies listeners of updates in the navigation state.
  void update() {
    pageManager.update();
  }

  /// Pushes a new page onto the navigation stack.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.pushPage('/profile', Text('Profile Page'));
  /// ```
  void pushPage(String routeName, Widget widget, [Object? arguments]) {
    pageManager.push(routeName, widget, arguments);
  }

  /// Pushes a new page and replaces the current page in the navigation stack.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.pushAndReplacement('/dashboard', Text('Dashboard'));
  /// ```
  void pushAndReplacement(
    String routeName,
    Widget widget, [
    Object? arguments,
  ]) {
    pageManager.pushAndReplacement(routeName, widget, arguments);
  }

  /// Pushes a new page and replaces the current page in the navigation stack.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.pushAndReplacement('/dashboard', Text('Dashboard'));
  /// ```
  void pushNamedAndReplacement(String routeName, [Object? arguments]) {
    pageManager.pushNamedAndReplacement(routeName, arguments);
  }

  /// Pushes a new page with a title and updates the navigation stack.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.pushPageWidthTitle('Settings', '/settings', Text('Settings Page'));
  /// ```
  void pushPageWidthTitle(
    String title,
    String routeName,
    Widget widget, [
    Object? arguments,
  ]) {
    pageManager.setPageTitle(title);
    _title = title;
    pageManager.push(routeName, widget, arguments);
  }

  /// Sets the home page.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.setHomePage(Text('Home Page'));
  /// ```
  void setHomePage(Widget widget, [Object? arguments]) {
    pageManager.setHomePage(widget, arguments);
  }

  void setHomePageAndUpdate(Widget widget, [Object? arguments]) {
    pageManager.setHomePage(widget, arguments);
    update();
  }

  /// Registers a list of pages for dynamic links.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.addPagesForDynamicLinksDirectory({
  ///   '/terms': Text('Terms and Conditions'),
  ///   '/privacy': Text('Privacy Policy'),
  /// });
  /// ```
  void addPagesForDynamicLinksDirectory(Map<String, Widget> mapOfPages) {
    mapOfPages.forEach((String key, Widget value) {
      pageManager.registerPageToDirectory(routeName: key, widget: value);
    });
  }

  /// Removes a page from the history by its route name.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.removePageFromHistory('/profile');
  /// ```
  void removePageFromHistory(String routeName) {
    pageManager.removePageFromDirectory(routeName);
  }

  void pushNamed(String routeName) {
    try {
      if (routeName[0] != '/') {
        routeName = '/$routeName';
      }
      pageManager.pushNamed(routeName);
    } catch (e) {
      // TODO(albert): Revisar el servicio de crashalytics.
    }
  }

  List<String> get directoryOfRoutes => pageManager.directoryOfPages;
  List<MaterialPage<dynamic>> get history => pageManager.history;

  /// Gets the navigation history as a list of page names.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(blocNavigator.historyPageNames);
  /// ```
  List<String> get historyPageNames {
    final List<String> listOfPages = <String>[];
    for (final MaterialPage<dynamic> element in history) {
      listOfPages.add(element.name ?? '');
    }
    return listOfPages;
  }

  /// Clears the navigation history and navigates to the home page.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.clearAndGoHome();
  /// ```
  void clearAndGoHome() {
    pageManager.clearHistory();
  }

  /// Releases resources held by the BLoC.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocNavigator.dispose();
  /// ```
  @override
  FutureOr<void> dispose() {
    pageManager.dispose();
    return null;
  }
}
