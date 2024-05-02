import 'dart:async';

import 'package:flutter/material.dart';

import '../blocs/app_manager.dart';
import '../providers/app_manager_provider.dart';

class JocaaguraApp extends StatefulWidget {
  const JocaaguraApp({
    required this.appManager,
    this.title = 'My jocaagura app',
    super.key,
  });

  final AppManager appManager;
  final String title;

  @override
  State<JocaaguraApp> createState() => _JocaaguraAppState();
}

class _JocaaguraAppState extends State<JocaaguraApp> {
  late StreamSubscription<ThemeData> _themeSubscription;

  /// sistema de navegación

  @override
  void initState() {
    super.initState();

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
