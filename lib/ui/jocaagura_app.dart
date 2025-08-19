part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// The entry point for a Jocaagura-based application.
///
/// The `JocaaguraApp` is a customizable `StatefulWidget` that sets up the
/// application's theme, navigation system, and responsive design using the
/// provided [AppManager].
///
/// ## Features
/// - Manages the application's theme dynamically.
/// - Configures navigation using `MaterialApp.router`.
/// - Integrates responsive design through the `AppManager`.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final AppManager appManager = AppManager();
///   runApp(JocaaguraApp(appManager: appManager));
/// }
/// ```
///
/// ## Parameters
/// - [appManager]: The core manager for the application's state and navigation.
/// - [title]: The title of the application. Defaults to `'My jocaagura app'`.
class JocaaguraApp extends StatelessWidget {
  /// Creates a `JocaaguraApp`.
  ///
  /// - [appManager]: The core manager for the application's state and navigation.
  /// - [title]: The title of the application. Defaults to `'My jocaagura app'`.
  const JocaaguraApp({
    required this.appManager,
    this.title = 'My jocaagura app',
    super.key,
  });

  /// The core manager for the application's state and navigation.
  final AppManager appManager;

  /// The title of the application.
  final String title;

  @override
  Widget build(BuildContext context) {
    // Update responsive settings based on the current context.
    appManager.responsive.setSizeFromContext(context);
    return AppManagerProvider(
      appManager: appManager,
      child: StreamBuilder<ThemeState>(
        stream: appManager.theme.stream,
        builder: (_, __) {
          final ThemeState s = appManager.appConfig.blocTheme.stateOrDefault;

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: title,
            themeMode: s.mode,
            theme: ThemeDataUtils.light(s),
            darkTheme: ThemeDataUtils.dark(s),
            routerDelegate: appManager.navigator.routerDelegate,
            routeInformationParser: appManager.navigator.routeInformationParser,
          );
        },
      ),
    );
  }
}
