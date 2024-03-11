import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/blocs/bloc_navigator.dart';

import '../mocks/pagemanager_mock.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocNavigator', () {
    late BlocNavigator blocNavigator;
    late MockPageManager pageManager;

    setUp(() {
      pageManager = MockPageManager();
      blocNavigator = BlocNavigator(pageManager);
    });

    test('back should call pageManager.back()', () {
      blocNavigator.back();
      // Add assertions to validate the expected behavior
      expect(pageManager.goBackCalled, true);
    });

    test('setTitle should update the title and call pageManager.setPageTitle()',
        () {
      const String title = 'Test Title';
      blocNavigator.setTitle(title);
      // Add assertions to validate the expected behavior
      expect(blocNavigator.title, title);
      expect(pageManager.setPageTitleCalled, true);
      expect(pageManager.setPageTitleArg, title);
    });

    test('pushPage should call pageManager.push()', () {
      const String routeName = '/test';
      final Container widget = Container();
      blocNavigator.pushPage(routeName, widget);
      // Add assertions to validate the expected behavior
      expect(pageManager.pushCalled, true);
      expect(pageManager.pushRouteName, routeName);
      expect(pageManager.pushWidget, widget);
    });

    test('constructor should call setHomePage if homePage is provided', () {
      const SizedBox mockHomePage = SizedBox();
      blocNavigator = BlocNavigator(pageManager, mockHomePage);

      // expect(pageManager.setHomePageCalled, true);
      expect(pageManager.pages[0].name, '/');
      blocNavigator.update();
      expect(pageManager.isUpdated, true);
      expect(
        blocNavigator.historyPageLength,
        greaterThanOrEqualTo(1),
      );
      expect(
        pageManager.historyPagesCount,
        greaterThanOrEqualTo(1),
      );
    });
    test(
        'pushAndReplacement should call pageManager.pushAndReplacement with correct arguments',
        () {
      final MockPageManager mockPageManager = MockPageManager();
      final BlocNavigator blocNavigator = BlocNavigator(mockPageManager);
      const String routeName = 'example_route';
      final Container widget = Container();
      final Map<String, String> arguments = <String, String>{'key': 'value'};

      blocNavigator.pushAndReplacement(routeName, widget, arguments);

      expect(mockPageManager.pushAndReplacementRouteName, routeName);
      expect(mockPageManager.pushAndReplacementWidget, widget);
      expect(mockPageManager.pushAndReplacementArguments, arguments);
    });
    test(
        'pushAndReplacementName should call pageManager.pushAndReplacementName with correct arguments',
        () {
      final MockPageManager mockPageManager = MockPageManager();
      final BlocNavigator blocNavigator = BlocNavigator(mockPageManager);
      const String routeName = 'example_route';
      final Map<String, String> arguments = <String, String>{'key': 'value'};

      blocNavigator.pushNamedAndReplacement(routeName, arguments);

      expect(mockPageManager.pushAndReplacementRouteName, routeName);
      expect(mockPageManager.pushAndReplacementArguments, arguments);
    });
    test(
        'pushPageWidthTitle should call pageManager.push and set the correct title',
        () {
      const String title = 'hola';
      const String routeName = '/';
      final Map<String, String> arguments = <String, String>{'key': 'value'};
      const Widget widget = Placeholder();
      blocNavigator.pushPageWidthTitle(title, routeName, widget, arguments);
      expect(blocNavigator.title, title);
      expect(pageManager.pushRouteName, routeName);
      expect(pageManager.pushWidget, widget);
      expect(pageManager.pushAndReplacementArguments, arguments);
    });
    test('setHome should call pageManager.setHome', () {
      const String title = '';
      const String routeName = '/';
      const Widget widget = Placeholder();
      blocNavigator.setHomePageAndUpdate(widget);
      expect(pageManager.isUpdated, true);
      expect(blocNavigator.title, title);
      expect(pageManager.pushRouteName, routeName);
      expect(pageManager.pushWidget, widget);
      expect(pageManager.pushAndReplacementArguments, null);
    });
    test('add pages to directory', () {
      const Widget widget = Placeholder();
      const Map<String, Widget> mapOfPages = <String, Widget>{
        'hola': Placeholder(),
        'hola2': widget,
      };
      blocNavigator.addPagesForDynamicLinksDirectory(mapOfPages);
      expect(pageManager.directoryOfPages.contains('/hola'), true);
      expect(pageManager.directoryOfPages.contains('/hola2'), true);

      blocNavigator.removePageFromHistory('hola');
      expect(pageManager.directoryOfPages.contains('/hola'), true);
      blocNavigator.removePageFromHistory('/hola');
      expect(pageManager.directoryOfPages.contains('/hola'), false);
      blocNavigator.pushNamed('hola2');
      expect(pageManager.pushCalled, true);
      expect(pageManager.pushRouteName, '/hola2');
      expect(pageManager.pushWidget, widget);

      expect(blocNavigator.directoryOfRoutes, <String>['/404', '/hola2']);
      expect(blocNavigator.history[0].name, '/');
      expect(blocNavigator.historyPageNames, <String>['/']);
      blocNavigator.clearAndGoHome();
      expect(blocNavigator.historyPageNames, <String>['/']);
      blocNavigator.dispose();
      expect(pageManager.isDisposed, isTrue);
    });
  });
}
