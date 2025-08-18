part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A custom implementation of `MaterialPage` for managing page-specific
/// properties and callbacks.
///
/// The `CustomPage` class extends `MaterialPage` to include additional properties
/// such as `title`, `routeName`, and callback functions for handling page-specific
/// events. It allows greater flexibility when managing pages in a Flutter application.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Navigator(
///         pages: [
///           CustomPage(
///             title: 'Home',
///             routeName: '/',
///             child: HomePage(),
///             onPageCallback: (arguments) => print('Page arguments: $arguments'),
///             onPagePathSegmentsCallback: (segments) => print('Path segments: $segments'),
///           ),
///         ],
///         onPopPage: (route, result) => route.didPop(result),
///       ),
///     );
///   }
/// }
///
/// class HomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: Center(child: Text('Welcome to the Home Page!')),
///     );
///   }
/// }
/// ```
class CustomPage extends MaterialPage<CustomPage> {
  /// Creates a `CustomPage` instance.
  ///
  /// - [child]: The widget that represents the page's content.
  /// - [title]: The title of the page, used for display or navigation purposes.
  /// - [routeName]: The route name of the page, used to identify the page in navigation.
  /// - [onPageCallback]: A callback function triggered with the page's arguments.
  /// - [onPagePathSegmentsCallback]: A callback function triggered with the page's path segments.
  /// - [arguments]: Optional arguments passed to the page.
  /// - [key]: An optional key for the page.
  const CustomPage({
    required super.child,
    required this.title,
    required this.routeName,
    this.onPageCallback,
    this.onPagePathSegmentsCallback,
    Map<String, dynamic>? super.arguments,
    super.key,
  }) : super(
          name: routeName,
        );

  /// The title of the page.
  final String title;

  /// The route name of the page.
  final String routeName;

  /// A callback function triggered with the page's arguments.
  final Function(Map<String, dynamic>? arguments)? onPageCallback;

  /// A callback function triggered with the page's path segments.
  final Function(List<String>? pathSegments)? onPagePathSegmentsCallback;

  /// Creates a route for the page.
  ///
  /// This method returns a `MaterialPageRoute` for the `CustomPage`, ensuring
  /// proper integration with Flutter's navigation system.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final route = customPage.createRoute(context);
  /// ```
  @override
  Route<CustomPage> createRoute(BuildContext context) {
    return MaterialPageRoute<CustomPage>(
      settings: this,
      builder: (BuildContext context) => child,
    );
  }
}
