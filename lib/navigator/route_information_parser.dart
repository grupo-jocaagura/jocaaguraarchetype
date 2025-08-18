part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A custom `RouteInformationParser` for handling route information in a Navigator.
///
/// The `MyAppRouteInformationParser` class is responsible for converting
/// route information into a `PageManager` configuration and restoring
/// route information from a `PageManager`. This enables deep linking and
/// seamless navigation handling.
///
/// ## Example
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:jocaaguraarchetype/my_app_route_information_parser.dart';
///
/// void main() {
///   final pageManager = PageManager(); // Assume PageManager is implemented
///   final routeInformationParser = MyAppRouteInformationParser(pageManager);
///
///   runApp(
///     MaterialApp.router(
///       routeInformationParser: routeInformationParser,
///       routerDelegate: MyRouterDelegate(pageManager), // Assume this is implemented
///     ),
///   );
/// }
/// ```
class MyAppRouteInformationParser extends RouteInformationParser<PageManager> {
  /// Creates an instance of `MyAppRouteInformationParser` with the provided [myPageManager].
  ///
  /// The [myPageManager] is used to manage navigation and routing configuration.
  MyAppRouteInformationParser(this.myPageManager);

  /// The `PageManager` used for handling navigation state.
  PageManager myPageManager;

  /// Parses the provided [routeInformation] into a `PageManager` configuration.
  ///
  /// Converts the incoming route information into a `PageManager` instance
  /// using the `PageManager.fromRouteInformation` factory method.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final routeInformation = RouteInformation(location: '/home');
  /// final pageManager = await routeInformationParser.parseRouteInformation(routeInformation);
  /// print('PageManager configuration: ${pageManager}');
  /// ```
  @override
  Future<PageManager> parseRouteInformation(RouteInformation routeInformation) {
    return Future<PageManager>.value(
      PageManager.fromRouteInformation(routeInformation, myPageManager),
    );
  }

  /// Restores the route information from the given [configuration].
  ///
  /// Converts the current state of the `PageManager` into a `RouteInformation`
  /// object that can be used for deep linking or browser navigation.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final routeInformation = routeInformationParser.restoreRouteInformation(pageManager);
  /// print('Restored route: ${routeInformation?.location}');
  /// ```
  @override
  RouteInformation? restoreRouteInformation(PageManager configuration) {
    return configuration.getCurrentUrl();
  }
}
