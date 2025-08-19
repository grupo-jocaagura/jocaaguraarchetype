part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// An `InheritedWidget` that provides access to the `AppManager` instance.
///
/// The `AppManagerProvider` allows widgets to access the `AppManager` instance
/// higher in the widget tree. It integrates seamlessly with Flutter's inherited
/// widget system, making it easy to share the `AppManager` across the application.
///
/// ## Example
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return AppManagerProvider(
///       appManager: AppManager(),
///       child: MaterialApp(
///         home: HomePage(),
///       ),
///     );
///   }
/// }
///
/// class HomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final appManager = context.appManager;
///
///     return Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: Center(
///         child: Text('AppManager is accessible here!'),
///       ),
///     );
///   }
/// }
/// ```
class AppManagerProvider extends InheritedWidget {
  /// Creates an `AppManagerProvider`.
  ///
  /// - [appManager]: The `AppManager` instance to share with descendant widgets.
  /// - [child]: The widget tree that can access the `AppManager`.
  const AppManagerProvider({
    required this.appManager,
    required super.child,
    super.key,
  });

  /// The `AppManager` instance shared with descendant widgets.
  final AppManager appManager;

  /// Retrieves the `AppManager` instance from the widget tree.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final appManager = AppManagerProvider.of(context);
  /// ```
  static AppManager of(BuildContext context) {
    final AppManagerProvider? result =
        context.dependOnInheritedWidgetOfExactType<AppManagerProvider>();
    assert(result != null, 'No AppManager found in context');
    return result!.appManager;
  }

  /// Determines whether the widget should notify dependents when updated.
  ///
  /// This implementation always returns `false` to indicate that
  /// no dependents need to be rebuilt.
  @override
  bool updateShouldNotify(AppManagerProvider oldWidget) => false;
}

/// Extension on `BuildContext` for convenient access to the `AppManager`.
///
/// This extension adds a `appManager` getter to `BuildContext`, making it easier
/// to retrieve the `AppManager` instance.
///
/// ## Example
///
/// ```dart
/// final appManager = context.appManager;
/// ```
extension AppManagerExtension on BuildContext {
  /// Retrieves the `AppManager` instance from the nearest `AppManagerProvider`.
  AppManager get appManager => AppManagerProvider.of(this);
}
