import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/navigator/my_app_route_delegate.dart';
import 'package:jocaaguraarchetype/navigator/page_manager.dart';

import '../mocks/mock_build_context.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('MyAppRouterDelegate', () {
    late MyAppRouterDelegate myAppRouterDelegate;
    late PageManager pageManager;

    setUp(() {
      pageManager = PageManager();
      myAppRouterDelegate = MyAppRouterDelegate(pageManager);
    });

    test('should have a navigator key', () {
      // Check if the navigatorKey is not null
      expect(myAppRouterDelegate.navigatorKey, isNotNull);
    });

    test('should provide currentConfiguration', () {
      // Set the currentConfiguration
      final PageManager currentConfiguration = PageManager();
      myAppRouterDelegate.myPageManager.update();

      // Check if the currentConfiguration is correct
      expect(
        myAppRouterDelegate.currentConfiguration?.pages.length,
        currentConfiguration.pages.length,
      );
    });

    test('should build the navigator', () {
      // Build the widget tree
      final Widget widget = myAppRouterDelegate.build(
        MockBuildContext(
          const Size(1024, 780),
        ),
      );

      // Check if the widget is of type Navigator
      expect(widget, isA<Navigator>());
    });

    test('should set new route path', () {
      // Set the new route path
      final PageManager configuration =
          PageManager(/* provide your configuration */);
      myAppRouterDelegate.setNewRoutePath(configuration);

      // Check if the page manager is updated with the new configuration
      expect(
        myAppRouterDelegate.myPageManager.currentConfiguration.pages.length,
        configuration.pages.length,
      );
    });

    test('should pop route', () async {
      // Push a new page
      myAppRouterDelegate.myPageManager.push(
        'hola',
        const Text('hola'),
      );

      // Pop the route
      final bool result = await myAppRouterDelegate.popRoute();

      // Check if the route is popped successfully
      expect(result, true);
      expect(myAppRouterDelegate.myPageManager.pages.length, 1);
    });
  });
}
