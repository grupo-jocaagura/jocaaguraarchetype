import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

PageModel page(String name, {PageKind kind = PageKind.material}) =>
    PageModel(name: name, segments: <String>[name], kind: kind);

class Harness {
  Harness({
    UserBackNavigationPolicy? policy,
    PageKind kind = PageKind.material,
  }) {
    manager = PageManager(
      initial: NavStackModel(<PageModel>[
        page('home'),
        page('a'),
        page('b', kind: kind),
      ]),
    );
    registry = PageRegistry(<String, PageWidgetBuilder>{
      for (final String name in <String>['home', 'a', 'b', 'login'])
        name: (_, __) => Scaffold(
              body: Center(
                child: Text(name, key: ValueKey<String>('view-$name')),
              ),
            ),
    });
    delegate = MyAppRouterDelegate(
      registry: registry,
      pageManager: manager,
      userBackNavigationPolicy: policy,
    );
    provider = UserBackRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri.parse('/b')),
      enabled: policy != null,
    );
  }

  late final PageManager manager;
  late final PageRegistry registry;
  late final MyAppRouterDelegate delegate;
  late final UserBackRouteInformationProvider provider;

  Future<void> mount(
    WidgetTester tester, {
    TargetPlatform platform = TargetPlatform.android,
  }) async {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(platform: platform),
        routerDelegate: delegate,
        routeInformationParser: const MyRouteInformationParser(),
        routeInformationProvider: provider,
      ),
    );
    await tester.pumpAndSettle();
  }

  void dispose() {
    delegate.dispose();
    provider.dispose();
    manager.dispose();
  }
}

void main() {
  group('MyAppRouterDelegate user back navigation', () {
    testWidgets(
        'Given a rejecting policy at root When back occurs Then consume it and retain structural canPop',
        (WidgetTester tester) async {
      final Harness h = Harness(policy: (_) => false);
      addTearDown(h.dispose);
      await h.mount(tester);
      h.manager.resetTo(page('home'));
      await tester.pumpAndSettle();
      expect(await h.delegate.popRoute(), isTrue);
      expect(h.manager.canPop, isFalse);
      expect(h.manager.historyNames, <String>['home']);
    });

    testWidgets(
        'Given projector mode When user back is rejected Then application push replace and reset remain available',
        (WidgetTester tester) async {
      int calls = 0;
      final Harness h = Harness(
        policy: (_) {
          calls++;
          return false;
        },
      );
      addTearDown(h.dispose);
      h.delegate.update(projectorMode: true);
      await h.mount(tester);
      h.manager.push(page('login'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('view-login')), findsOneWidget);
      h.delegate.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home', 'a', 'b', 'login']);
      expect(calls, 1);
      h.manager.replaceTop(page('a'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('view-a')), findsOneWidget);
      h.manager.resetTo(page('home'));
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home']);
      expect(calls, 1);
    });

    testWidgets(
        'Given a pending iOS decision When security replaces the page Then discard its approval',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      final Harness h =
          Harness(kind: PageKind.cupertino, policy: (_) => decision.future);
      addTearDown(h.dispose);
      await h.mount(tester, platform: TargetPlatform.iOS);
      final TestGesture gesture =
          await tester.startGesture(const Offset(1, 300));
      await gesture.moveBy(const Offset(650, 0));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(h.manager.stack.top.name, 'b');
      h.manager.replaceTop(page('login'));
      await tester.pumpAndSettle();
      decision.complete(true);
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home', 'a', 'login']);
      expect(find.byKey(const ValueKey<String>('view-login')), findsOneWidget);
    });

    testWidgets(
        'Given pending browser approval When security resets Then discard approval and report the reset URL',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      final Harness h = Harness(policy: (_) => decision.future);
      addTearDown(h.dispose);
      await h.mount(tester);
      await h.provider
          .didPushRouteInformation(RouteInformation(uri: Uri.parse('/a')));
      await tester.pump();
      expect(h.manager.stack.top.name, 'b');
      h.manager.resetTo(page('login'));
      await tester.pumpAndSettle();
      decision.complete(true);
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['login']);
      expect(h.provider.value.uri.path, '/login');
    });

    testWidgets(
        'Given pending browser approval When another request arrives Then discard both without replay',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      int calls = 0;
      final Harness h = Harness(
        policy: (_) {
          calls++;
          return decision.future;
        },
      );
      addTearDown(h.dispose);
      await h.mount(tester);
      await h.provider
          .didPushRouteInformation(RouteInformation(uri: Uri.parse('/a')));
      await tester.pump();
      await h.provider
          .didPushRouteInformation(RouteInformation(uri: Uri.parse('/home')));
      await tester.pumpAndSettle();
      decision.complete(true);
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      expect(h.provider.value.uri.path, '/b');
    });

    testWidgets(
        'Given a detailed URI When browser history returns Then retain segments query fragment and metadata',
        (WidgetTester tester) async {
      final Harness h = Harness(policy: (_) => true);
      addTearDown(h.dispose);
      await h.mount(tester);
      final PageModel detail = PageModel.fromUri(
        Uri.parse('/a/42?tab=notes#section'),
        name: 'a',
        kind: PageKind.cupertino,
      ).copyWith(
        requiresAuth: true,
        state: <String, dynamic>{'selection': 42},
      );
      h.manager.push(detail);
      await tester.pumpAndSettle();
      final RouteInformation detailEntry = h.provider.value;
      h.manager.push(page('b'));
      await tester.pumpAndSettle();
      await h.provider.didPushRouteInformation(detailEntry);
      await tester.pumpAndSettle();
      expect(identical(h.manager.stack.top, detail), isTrue);
      expect(h.provider.value.uri, Uri.parse('/a/42?tab=notes#section'));
    });

    testWidgets(
        'Given no adapter When popRoute runs Then preserve synchronous pop behavior',
        (WidgetTester tester) async {
      final Harness h = Harness();
      addTearDown(h.dispose);
      await h.mount(tester);
      final Future<bool> pop = h.delegate.popRoute();
      expect(h.manager.historyNames, <String>['home', 'a']);
      expect(await pop, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Given a rejecting policy When system back occurs Then consume it without stack emissions or app exit',
        (WidgetTester tester) async {
      bool allow = false;
      final List<UserBackNavigationRequest> requests =
          <UserBackNavigationRequest>[];
      final Harness h = Harness(
        policy: (UserBackNavigationRequest request) {
          requests.add(request);
          return allow;
        },
      );
      addTearDown(h.dispose);
      await h.mount(tester);
      final NavStackModel before = h.manager.stack;
      final List<NavStackModel> emissions = <NavStackModel>[];
      final StreamSubscription<NavStackModel> sub =
          h.manager.stackStream.listen(emissions.add);
      addTearDown(sub.cancel);
      await tester.pump();
      emissions.clear();
      final List<MethodCall> calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall call) async {
        calls.add(call);
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(identical(h.manager.stack, before), isTrue);
      expect(h.manager.canPop, isTrue);
      expect(emissions, isEmpty);
      expect(requests.single.source, UserBackNavigationSource.system);
      expect(
        calls.where((MethodCall call) => call.method == 'SystemNavigator.pop'),
        isEmpty,
      );
      allow = true;
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home', 'a']);
      expect(emissions, hasLength(1));
      expect(requests, hasLength(2));
    });

    for (final PageKind kind in PageKind.values) {
      testWidgets(
          'Given $kind and a policy When Navigator pops Then check before removal',
          (WidgetTester tester) async {
        bool allow = false;
        int calls = 0;
        final Harness h = Harness(
          kind: kind,
          policy: (_) {
            calls++;
            return allow;
          },
        );
        addTearDown(h.dispose);
        await h.mount(tester);
        final BuildContext context =
            tester.element(find.byKey(const ValueKey<String>('view-b')));
        final ModalRoute<dynamic> route = ModalRoute.of(context)!;
        if (kind == PageKind.cupertino) {
          expect(route, isA<CupertinoPageRoute<dynamic>>());
        }
        if (kind == PageKind.dialog) {
          expect(route, isA<DialogRoute<dynamic>>());
        }
        h.delegate.navigatorKey.currentState!.pop();
        expect(route.isCurrent, isTrue);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
        expect(route.isCurrent, isTrue);
        expect(find.byKey(const ValueKey<String>('view-b')), findsOneWidget);
        expect(calls, 1);
        allow = true;
        h.delegate.navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a']);
        expect(calls, 2);
      });
    }

    for (final PageKind kind in <PageKind>[
      PageKind.cupertino,
      PageKind.material,
    ]) {
      testWidgets(
          'Given $kind and a rejecting policy When an iOS swipe commits Then restore the page and permit a later allowed swipe',
          (WidgetTester tester) async {
        bool allow = false;
        int calls = 0;
        final Harness h = Harness(
          kind: kind,
          policy: (_) {
            calls++;
            return allow;
          },
        );
        addTearDown(h.dispose);
        await h.mount(tester, platform: TargetPlatform.iOS);
        final Offset initialPosition =
            tester.getTopLeft(find.byKey(const ValueKey<String>('view-b')));
        Future<void> swipe() async {
          final TestGesture gesture =
              await tester.startGesture(const Offset(1, 300));
          await gesture.moveBy(const Offset(650, 0));
          await tester.pump(const Duration(milliseconds: 50));
          await gesture.up();
          await tester.pumpAndSettle();
        }

        await swipe();
        expect(
          calls,
          1,
          reason: 'The native page gesture must reach the policy',
        );
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey<String>('view-b'))).dx,
          closeTo(initialPosition.dx, 0.1),
        );
        allow = true;
        await swipe();
        expect(calls, 2);
        expect(h.manager.historyNames, <String>['home', 'a']);
      });
    }

    testWidgets(
        'Given pending or rejected requests When back is requested again Then discard old intentions without replay',
        (WidgetTester tester) async {
      Completer<bool> decision = Completer<bool>();
      int calls = 0;
      final Harness h = Harness(
        policy: (_) {
          calls++;
          return decision.future;
        },
      );
      addTearDown(h.dispose);
      await h.mount(tester);
      final Future<bool> first = h.delegate.popRoute();
      expect(await h.delegate.popRoute(), isTrue);
      h.delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect(calls, 1);
      decision.complete(false);
      expect(await first, isTrue);
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      decision = Completer<bool>()..complete(true);
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(await h.delegate.popRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home', 'a']);
      expect(calls, 2);
    });

    testWidgets(
        'Given pending approval When security resets Then invalidate approval and bypass policy',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      int calls = 0;
      final Harness h = Harness(
        policy: (_) {
          calls++;
          return decision.future;
        },
      );
      addTearDown(h.dispose);
      await h.mount(tester);
      final Future<bool> pending = h.delegate.popRoute();
      h.manager.resetTo(page('login'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('view-login')), findsOneWidget);
      decision.complete(true);
      await pending;
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['login']);
      expect(calls, 1);
      expect(h.manager.canPop, isFalse);
    });

    testWidgets(
        'Given pending approval When dependencies change Then invalidate the old approval',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      final Harness h = Harness(policy: (_) => decision.future);
      addTearDown(h.dispose);
      await h.mount(tester);
      final Future<bool> pending = h.delegate.popRoute();
      final PageManager next = PageManager(
        initial: NavStackModel(<PageModel>[page('home'), page('login')]),
      );
      addTearDown(next.dispose);
      h.delegate.update(pageManager: next);
      await tester.pumpAndSettle();
      decision.complete(true);
      await pending;
      expect(next.historyNames, <String>['home', 'login']);
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
    });

    testWidgets(
        'Given pending approval When the adapter is removed Then invalidate it and restore legacy behavior',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      final Harness h = Harness(policy: (_) => decision.future);
      addTearDown(h.dispose);
      await h.mount(tester);
      final Future<bool> pending = h.delegate.popRoute();
      h.delegate.userBackNavigationPolicy = null;
      await tester.pumpAndSettle();
      decision.complete(true);
      await pending;
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      final Future<bool> next = h.delegate.popRoute();
      expect(h.manager.historyNames, <String>['home', 'a']);
      await next;
    });

    testWidgets(
        'Given pending approval When the delegate is disposed Then discard approval',
        (WidgetTester tester) async {
      final Completer<bool> decision = Completer<bool>();
      final Harness h = Harness(policy: (_) => decision.future);
      addTearDown(h.dispose);
      await h.mount(tester);
      final Future<bool> pending = h.delegate.popRoute();
      await tester.pumpWidget(const SizedBox());
      h.delegate.dispose();
      decision.complete(true);
      await pending;
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
    });

    testWidgets(
        'Given a throwing policy When back occurs Then reject without mutation',
        (WidgetTester tester) async {
      final Harness h =
          Harness(policy: (_) => throw StateError('policy failed'));
      addTearDown(h.dispose);
      await h.mount(tester);
      expect(await h.delegate.popRoute(), isTrue);
      expect(tester.takeException(), isA<StateError>());
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
    });

    testWidgets(
        'Given an initialized delegate When a backward route is applied Then consult the policy',
        (WidgetTester tester) async {
      bool allow = false;
      final Harness h = Harness(policy: (_) => allow);
      addTearDown(h.dispose);
      await h.mount(tester);
      await h.delegate.setNewRoutePath(NavStackModel.single(page('a')));
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      allow = true;
      await h.delegate.setNewRoutePath(NavStackModel.single(page('a')));
      expect(h.manager.historyNames, <String>['home', 'a']);
    });

    testWidgets(
        'Given a rejecting policy When browser back occurs Then replace the URL and permit a later allowed back',
        (WidgetTester tester) async {
      bool allow = false;
      int calls = 0;
      final Harness h = Harness(
        policy: (_) {
          calls++;
          return allow;
        },
      );
      addTearDown(h.dispose);
      final List<MethodCall> platformCalls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation, (MethodCall call) async {
        platformCalls.add(call);
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.navigation, null),
      );
      await h.mount(tester);
      h.manager.pop();
      await tester.pumpAndSettle();
      final RouteInformation aEntry = h.provider.value;
      h.manager.push(page('b'));
      await tester.pumpAndSettle();
      platformCalls.clear();
      await h.provider.didPushRouteInformation(aEntry);
      await tester.pumpAndSettle();
      expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      expect(h.provider.value.uri.path, '/b');
      expect(find.byKey(const ValueKey<String>('view-b')), findsOneWidget);
      final MethodCall report = platformCalls
          .lastWhere((MethodCall c) => c.method == 'routeInformationUpdated');
      expect((report.arguments as Map<Object?, Object?>)['replace'], isTrue);
      expect(calls, 1);
      allow = true;
      await tester.pumpAndSettle();
      expect(calls, 1, reason: 'Rejected history must not replay');
      // An older/foreign entry has no marker and is conservatively guarded.
      await h.provider
          .didPushRouteInformation(RouteInformation(uri: Uri.parse('/a')));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(h.manager.historyNames, <String>['home', 'a']);
      expect(h.provider.value.uri.path, '/a');
    });

    testWidgets(
        'Given a rejecting policy When known browser forward or application reset occurs Then bypass policy',
        (WidgetTester tester) async {
      bool allow = true;
      int calls = 0;
      final Harness h = Harness(
        policy: (_) {
          calls++;
          return allow;
        },
      );
      addTearDown(h.dispose);
      await h.mount(tester);
      h.manager.pop();
      await tester.pumpAndSettle();
      final RouteInformation aEntry = h.provider.value;
      h.manager.push(page('b'));
      await tester.pumpAndSettle();
      final RouteInformation bEntry = h.provider.value;
      await h.provider.didPushRouteInformation(aEntry);
      await tester.pumpAndSettle();
      expect(h.manager.stack.top.name, 'a');
      expect(calls, 1);
      allow = false;
      calls = 0;
      await h.provider.didPushRouteInformation(bEntry);
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(h.manager.stack.top.name, 'b');
      h.manager.resetTo(page('home'));
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(h.manager.stack.top.name, 'home');
    });
  });
}
