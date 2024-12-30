import 'dart:async';

import 'package:flutter/material.dart';

import '../blocs/app_manager.dart';
import '../providers/app_manager_provider.dart';

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
/// import 'package:jocaaguraarchetype/jocaagura_app.dart';
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
class JocaaguraApp extends StatefulWidget {
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
  State<JocaaguraApp> createState() => _JocaaguraAppState();
}

class _JocaaguraAppState extends State<JocaaguraApp> {
  late StreamSubscription<ThemeData> _themeSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for theme changes and update the UI dynamically.
    _themeSubscription =
        widget.appManager.theme.themeDataStream.listen((ThemeData themeData) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update responsive settings based on the current context.
    widget.appManager.responsive.setSizeFromContext(context);

    return AppManagerProvider(
      appManager: widget.appManager,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: widget.title,
        theme: widget.appManager.theme.themeData,
        routerDelegate: widget.appManager.navigator.routerDelegate,
        routeInformationParser:
            widget.appManager.navigator.routeInformationParser,
      ),
    );
  }
}
