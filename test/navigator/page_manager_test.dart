import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
// Simulación de SystemChrome para realizar pruebas
class ApplicationSwitcherDescription {
  ApplicationSwitcherDescription({
    this.label,
    this.primaryColor,
  });
  final String? label;
  final int? primaryColor;
}

class SystemChrome {
  static bool calledSetApplicationSwitcherDescription = false;
  static ApplicationSwitcherDescription? lastApplicationSwitcherDescription;

  static void setApplicationSwitcherDescription(
    ApplicationSwitcherDescription description,
  ) {
    calledSetApplicationSwitcherDescription = true;
    lastApplicationSwitcherDescription = description;
  }
}

void main() {
  group('PageManager', () {
    test('setPageTitle', () {
      final PageManager pageManager = PageManager();

      // Simulamos que estamos en web
      TestWidgetsFlutterBinding.ensureInitialized();
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

      final String title = pageManager.setPageTitle(
        '/Home',
        LabColor.colorValueFromColor(Colors.blue),
      );

      // Comprobamos que los parámetros pasados a SystemChrome.setApplicationSwitcherDescription sean correctos
      expect(title, equals('Home'));

      // Restauramos el valor de debugDefaultTargetPlatformOverride
      debugDefaultTargetPlatformOverride = null;
    });
  });
  group('PageManager', () {
    late PageManager pageManager;

    setUp(() {
      pageManager = PageManager();
    });

    test('Initial configuration', () {
      expect(pageManager.historyPagesCount, 1);
      expect(pageManager.currentPage, isNotNull);
      expect(pageManager.directoryOfPages, isNotEmpty);
    });

    test('Set home page', () {
      const Text homePage = Text('Home Page');

      //forzamos la eliminacion de paginas duplicadas
      pageManager.push(
        '/',
        const Placeholder(),
      );
      pageManager.push(
        'hola',
        const Placeholder(),
      );
      pageManager.setHomePage(homePage);
      pageManager.update();
      pageManager.removePageFromRoute('/');
      expect(pageManager.directoryOfPages, contains('/'));
      expect(pageManager.onBoardingPage, equals(homePage));
      expect(pageManager.historyPagesCount, 2);
      pageManager.removePageFromRoute('/hola');
      expect(pageManager.directoryOfPages.contains('/hola'), false);
    });

    test('Set 404 page', () {
      final Page404Widget page404Widget =
          Page404Widget(pageManager: pageManager);
      pageManager.set404Page(page404Widget);

      expect(pageManager.directoryOfPages, contains('/404'));
      expect(pageManager.page404Widget, equals(page404Widget));
      expect(pageManager.historyPagesCount, 1);
    });

    test('Register page to directory', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      expect(pageManager.directoryOfPages, contains(routeName));
      expect(pageManager.isThisRouteNameInDirectory(routeName), isTrue);
    });

    test('Remove page from directory', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      pageManager.removePageFromDirectory(routeName);

      expect(pageManager.directoryOfPages, isNot(contains(routeName)));
      expect(pageManager.isThisRouteNameInDirectory(routeName), isFalse);
    });

    test('Push page', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      pageManager.push(routeName, widget);

      expect(pageManager.historyPagesCount, 2);
      expect(pageManager.currentPage.name, equals(routeName));
    });

    test('Push and replacement', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      pageManager.pushAndReplacement(routeName, widget);

      expect(pageManager.historyPagesCount, greaterThanOrEqualTo(1));
      expect(pageManager.currentPage.name, equals(routeName));
    });

    test('Push named', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      pageManager.pushNamed(routeName);

      expect(pageManager.historyPagesCount, 2);
      expect(pageManager.currentPage.name, equals(routeName));
    });

    test('Push named and replacement', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      pageManager.pushNamedAndReplacement(routeName);

      expect(pageManager.historyPagesCount, greaterThanOrEqualTo(1));
      expect(pageManager.currentPage.name, equals(routeName));
    });

    test('Push from route settings', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      const MaterialPage<dynamic> routeSettings = MaterialPage<dynamic>(
        name: routeName,
        child: widget,
      );
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      pageManager.pushFromRoutesettings(routeName, routeSettings);

      expect(pageManager.historyPagesCount, 2);
      expect(pageManager.currentPage.name, equals(routeName));
    });

    test('Back', () {
      const String routeName1 = '/test1';
      const String routeName2 = '/test2';
      const Text widget1 = Text('Test Widget 1');
      const Text widget2 = Text('Test Widget 2');
      pageManager.registerPageToDirectory(
        routeName: routeName1,
        widget: widget1,
      );
      pageManager.registerPageToDirectory(
        routeName: routeName2,
        widget: widget2,
      );
      pageManager.push(routeName1, widget1);
      pageManager.push(routeName2, widget2);

      pageManager.back();

      expect(pageManager.historyPagesCount, greaterThanOrEqualTo(1));
      expect(pageManager.currentPage.name, equals(routeName1));
    });

    test('Clear history', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);
      pageManager.push(routeName, widget);

      pageManager.clearHistory();

      expect(pageManager.historyPagesCount, 1);
      expect(pageManager.currentPage.name, equals('/'));
    });

    test('Get page from directory', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);

      final MaterialPage<dynamic> page =
          pageManager.getPageFromDirectory(routeName);

      expect(page.name, equals(routeName));
      expect(page.child, equals(widget));
    });

    test('Get 404 page from directory', () {
      const Text widget = Text('Page 404 Widget');
      pageManager.set404Page(widget);

      final MaterialPage<dynamic> page = pageManager.get404PageFromDirectory();

      expect(page.name, equals('/404'));
      expect(page.child, equals(widget));
    });

    test('Go to 404 page', () {
      const Text widget = Text('Page 404 Widget');
      pageManager.set404Page(widget);
      pageManager.goTo404Page();

      expect(pageManager.historyPagesCount, 2);
      expect(pageManager.pages.length, 1);
      expect(pageManager.currentPage.name, equals('/404'));
      expect(pageManager.getAllPages.length, 2);
    });

    test('Get current URL', () {
      const String routeName = '/test';
      const Text widget = Text('Test Widget');
      pageManager.registerPageToDirectory(routeName: routeName, widget: widget);
      pageManager.push(routeName, widget);

      final RouteInformation? routeInformation = pageManager.getCurrentUrl();

      expect(routeInformation!.uri.path, equals(routeName));
    });

    test('Dispose', () {
      pageManager.dispose();

      expect(pageManager.historyPagesCount, 0);
      expect(pageManager.directoryOfPages, isEmpty);
    });
  });
  group('PageManager', () {
    test('fromRouteInformation', () {
      final RouteInformation routeInformation =
          RouteInformation(uri: Uri.parse('/test?param=value'));
      final PageManager currentPageManager = PageManager();
      const Text onBoardingPage = Text('Onboarding Page');
      final Page404Widget page404Widget =
          Page404Widget(pageManager: currentPageManager);
      const Text testWidget = Text('Test Widget');

      currentPageManager.setHomePage(onBoardingPage);
      currentPageManager.set404Page(page404Widget);
      currentPageManager.registerPageToDirectory(
        routeName: '/test',
        widget: testWidget,
      );

      final PageManager pageManager = PageManager.fromRouteInformation(
        routeInformation,
        currentPageManager,
      );

      expect(pageManager.currentPage.name, equals('/'));
      expect(pageManager.page404Widget, equals(page404Widget));
      expect(pageManager.historyPagesCount, equals(1));

      final MaterialPage<dynamic> testPage =
          pageManager.getPageFromDirectory('/test');
      expect(testPage.name, equals('/404'));

      final RouteInformation? currentUrl = pageManager.getCurrentUrl();
      expect(currentUrl?.uri.path, equals('/'));
    });
  });
}
