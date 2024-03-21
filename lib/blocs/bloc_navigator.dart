import 'dart:async';

import 'package:flutter/material.dart';

import '../jocaaguraarchetype.dart';
import '../navigator/my_app_route_delegate.dart';
import '../navigator/route_information_parser.dart';

class BlocNavigator extends BlocModule {
  BlocNavigator(this.pageManager, [Widget? homePage]) {
    if (homePage != null) {
      setHomePage(homePage);
    }
    routerDelegate = MyAppRouterDelegate(pageManager);
    routeInformationParser = MyAppRouteInformationParser(pageManager);
  }
  static String name = 'blocNavigator';
  final PageManager pageManager;
  bool get showBackButton => historyPageLength > 0;

  late final MyAppRouterDelegate routerDelegate;
  late final MyAppRouteInformationParser routeInformationParser;

  void back() {
    pageManager.back();
  }

  String _title = '';
  String get title => _title;
  int get historyPageLength => pageManager.historyPagesCount;

  void setTitle(String title) {
    _title = title;
    pageManager.setPageTitle(title);
  }

  void update() {
    pageManager.update();
  }

  void pushPage(String routeName, Widget widget, [Object? arguments]) {
    pageManager.push(routeName, widget, arguments);
  }

  void pushAndReplacement(
    String routeName,
    Widget widget, [
    Object? arguments,
  ]) {
    pageManager.pushAndReplacement(routeName, widget, arguments);
  }

  void pushNamedAndReplacement(String routeName, [Object? arguments]) {
    pageManager.pushNamedAndReplacement(routeName, arguments);
  }

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

  void setHomePage(Widget widget, [Object? arguments]) {
    pageManager.setHomePage(widget, arguments);
  }

  void setHomePageAndUpdate(Widget widget, [Object? arguments]) {
    pageManager.setHomePage(widget, arguments);
    update();
  }

  void addPagesForDynamicLinksDirectory(Map<String, Widget> mapOfPages) {
    mapOfPages.forEach((String key, Widget value) {
      pageManager.registerPageToDirectory(routeName: key, widget: value);
    });
  }

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
  List<String> get historyPageNames {
    final List<String> listOfPages = <String>[];
    for (final MaterialPage<dynamic> element in history) {
      listOfPages.add(element.name ?? '');
    }
    return listOfPages;
  }

  void clearAndGoHome() {
    pageManager.clearHistory();
  }

  @override
  FutureOr<void> dispose() {
    pageManager.dispose();
    return null;
  }
}
