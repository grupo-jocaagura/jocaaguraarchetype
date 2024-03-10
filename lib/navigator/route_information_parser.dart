import 'package:flutter/material.dart';

import 'page_manager.dart';

class MyAppRouteInformationParser extends RouteInformationParser<PageManager> {
  MyAppRouteInformationParser(this.myPageManager);

  PageManager myPageManager;

  @override
  Future<PageManager> parseRouteInformation(RouteInformation routeInformation) {
    return Future<PageManager>.value(
      PageManager.fromRouteInformation(routeInformation, myPageManager),
    );
  }

  @override
  RouteInformation? restoreRouteInformation(PageManager configuration) {
    return configuration.getCurrentUrl();
  }
}
