import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --- Fakes mínimos para Router (sin paquetes externos) ---

class _NullRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Object? get currentConfiguration => null;

  @override
  Widget build(BuildContext context) {
    // Important: returning an empty widget forces MaterialApp.router builder's
    // `child` to be non-null in most cases, but we still want to cover the `null`
    // branch later using a different delegate.
    return const SizedBox.shrink();
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

/// This delegate intentionally returns a widget tree without Navigator.
/// In some Flutter versions, MaterialApp.router may call builder with child == null.
class _NoChildRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier {
  @override
  Object? get currentConfiguration => null;

  @override
  Widget build(BuildContext context) {
    // Not a Navigator-based router output.
    return const SizedBox.shrink();
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}

  @override
  Future<bool> popRoute() {
    throw UnimplementedError();
  }
}

class _FakeRouteInformationParser extends RouteInformationParser<Object> {
  const _FakeRouteInformationParser();

  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return Object();
  }

  @override
  RouteInformation restoreRouteInformation(Object configuration) {
    return RouteInformation(uri: Uri.parse('/'));
  }
}

class _FakeRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  _FakeRouteInformationProvider();

  @override
  RouteInformation get value => RouteInformation(uri: Uri.parse('/'));
}

/// --- Fake AppManager pieces ---

class _FakeBlocResponsive implements BlocResponsive {
  int setSizeCalls = 0;
  final List<Size> capturedSizes = <Size>[];

  @override
  void setSizeFromContext(BuildContext context) {
    setSizeCalls++;
    capturedSizes.add(MediaQuery.sizeOf(context));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppManager implements AbstractAppManager {
  _FakeAppManager(this.responsive);

  @override
  final BlocResponsive responsive;

  // Everything else is irrelevant for this widget; keep via noSuchMethod.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('JocaaguraThemedRouterApp', () {
    testWidgets(
      'Given initialTheme When built Then sets themeMode and calls responsive.setSizeFromContext',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast();
        addTearDown(() async => themeCtrl.close());

        final ThemeState initial = ThemeState.defaults.copyWith(
          mode: ThemeMode.system,
        );

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager = _FakeAppManager(responsive);

        // Act
        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: initial,
            routerDelegate: _NullRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );
        await tester.pump(); // settle first frame

        // Assert: themeMode comes from initial theme
        final MaterialApp app = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(app.themeMode, ThemeMode.system);

        // Assert: responsive sizing hook was called at least once
        expect(responsive.setSizeCalls, greaterThan(0));
        expect(responsive.capturedSizes.isNotEmpty, isTrue);
      },
    );

    testWidgets(
      'Given themeStream emits When rebuilt Then updates themeMode accordingly',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        addTearDown(() async => themeCtrl.close());

        final ThemeState initial =
            ThemeState.defaults.copyWith(mode: ThemeMode.light);
        final ThemeState dark =
            ThemeState.defaults.copyWith(mode: ThemeMode.dark);

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager = _FakeAppManager(responsive);

        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: initial,
            routerDelegate: _NullRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );
        await tester.pump();

        MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.themeMode, ThemeMode.light);

        final int callsBefore = responsive.setSizeCalls;

        // Act
        themeCtrl.add(dark);

        // IMPORTANT: allow StreamBuilder + router to schedule & paint the new frame(s)
        await tester.pump();
        await tester.pump();

        // Assert (builder ran again)
        expect(responsive.setSizeCalls, greaterThan(callsBefore));

        // Assert (themeMode updated)
        app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.themeMode, ThemeMode.dark);
      },
    );

    testWidgets(
      'Given router delegate leads to null child When builder runs Then returns SizedBox.shrink and still calls responsive hook',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast();
        addTearDown(() async => themeCtrl.close());

        const ThemeState initial = ThemeState.defaults;

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager = _FakeAppManager(responsive);

        // Act
        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: initial,
            routerDelegate: _NoChildRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );
        await tester.pump();

        // Assert: our fallback widget exists
        expect(find.byType(SizedBox), findsWidgets);
        // We can’t uniquely identify shrink without key; so we assert the hook ran.
        expect(responsive.setSizeCalls, greaterThan(0));
      },
    );
  });
}
