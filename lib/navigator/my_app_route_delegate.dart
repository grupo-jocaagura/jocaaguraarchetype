import 'dart:async';

import 'package:flutter/material.dart';

import 'page_manager.dart';

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
      onPopPage: myPageManager.didPop,
    );
    // return const _MyNavigator();
  }

  @override
  Future<void> setNewRoutePath(PageManager configuration) async {
    configuration.update();
  }

  @override
  Future<bool> popRoute() {
    //print('Atras desde el dispositivo');
    myPageManager.back();
    return Future<bool>.value(true);
  }
}
