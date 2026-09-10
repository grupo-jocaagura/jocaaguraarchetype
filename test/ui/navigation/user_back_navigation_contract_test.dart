import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'user_back_navigation_test.dart' show Harness, page;

ModalRoute<dynamic> activeRoute(WidgetTester tester, [String name = 'b']) =>
    ModalRoute.of(
      tester.element(find.byKey(ValueKey<String>('view-$name'))),
    )!;

class ResultRegistry extends PageRegistry {
  ResultRegistry(this.onResult)
      : super(<String, PageWidgetBuilder>{
          for (final String name in <String>['home', 'a', 'b', 'login'])
            name: (_, __) => Text(name, key: ValueKey<String>('view-$name')),
        });

  final void Function(bool, dynamic) onResult;

  @override
  Page<dynamic> toPage(PageModel page, {int? position}) {
    final MaterialPage<dynamic> original =
        super.toPage(page, position: position) as MaterialPage<dynamic>;
    return MaterialPage<dynamic>(
      key: original.key,
      name: original.name,
      onPopInvoked: onResult,
      child: original.child,
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => CounterPageState();
}

class PendingPolicy {
  final Completer<bool> decision = Completer<bool>();

  Future<bool> handle(UserBackNavigationRequest request) => decision.future;
}

class CounterPageState extends State<CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => count++),
        child: Text('Count $count'),
      );
}

void main() {
  group('User back Flutter route contracts', () {
    for (final PageKind kind in PageKind.values) {
      for (final bool allow in <bool>[false, true]) {
        testWidgets(
          'Given $kind local history and policy $allow When Navigator pops '
          'Then consume only local history without consulting policy',
          (WidgetTester tester) async {
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
            final ModalRoute<dynamic> route = activeRoute(tester);
            bool removed = false;
            route.addLocalHistoryEntry(
              LocalHistoryEntry(
                onRemove: () => removed = true,
              ),
            );
            await tester.pumpAndSettle();
            h.delegate.navigatorKey.currentState!.pop();
            await tester.pumpAndSettle();
            expect(removed, isTrue);
            expect(calls, 0);
            expect(route.isCurrent, isTrue);
            expect(h.manager.historyNames, <String>['home', 'a', 'b']);
          },
        );
      }

      testWidgets(
        'Given $kind and async approval When Navigator pops a result '
        'Then complete the route with that result and mutate once',
        (WidgetTester tester) async {
          final Completer<bool> approval = Completer<bool>();
          final Harness h = Harness(kind: kind, policy: (_) => approval.future);
          addTearDown(h.dispose);
          await h.mount(tester);
          final ModalRoute<dynamic> route = activeRoute(tester);
          final Object result = Object();
          Object? received = 'pending';
          route.popped.then((dynamic value) => received = value);
          final List<NavStackModel> emissions = <NavStackModel>[];
          final StreamSubscription<NavStackModel> sub =
              h.manager.stackStream.listen(emissions.add);
          addTearDown(sub.cancel);
          await tester.pump();
          emissions.clear();
          h.delegate.navigatorKey.currentState!.pop(result);
          await tester.pumpAndSettle();
          expect(received, 'pending');
          expect(emissions, isEmpty);
          approval.complete(true);
          await tester.pumpAndSettle();
          expect(received, same(result));
          expect(emissions, hasLength(1));
          expect(h.manager.historyNames, <String>['home', 'a']);
        },
      );
    }

    testWidgets(
      'Given local history When system back occurs Then consume local history only',
      (WidgetTester tester) async {
        int calls = 0;
        final Harness h = Harness(
          policy: (_) {
            calls++;
            return false;
          },
        );
        addTearDown(h.dispose);
        await h.mount(tester);
        bool removed = false;
        activeRoute(tester).addLocalHistoryEntry(
          LocalHistoryEntry(
            onRemove: () => removed = true,
          ),
        );
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(removed, isTrue);
        expect(calls, 0);
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      },
    );

    testWidgets(
      'Given a rejected result When a later pop is allowed Then deliver only the new result',
      (WidgetTester tester) async {
        bool allow = false;
        final Harness h = Harness(policy: (_) => allow);
        addTearDown(h.dispose);
        await h.mount(tester);
        Object? received = 'pending';
        activeRoute(tester).popped.then((dynamic value) => received = value);
        h.delegate.navigatorKey.currentState!.pop('rejected');
        await tester.pumpAndSettle();
        expect(received, 'pending');
        allow = true;
        await tester.pumpAndSettle();
        expect(received, 'pending');
        h.delegate.navigatorKey.currentState!.pop('allowed');
        await tester.pumpAndSettle();
        expect(received, 'allowed');
        expect(h.manager.historyNames, <String>['home', 'a']);
      },
    );

    testWidgets(
      'Given a pending result When security resets Then discard the old result and approval',
      (WidgetTester tester) async {
        final Completer<bool> approval = Completer<bool>();
        final Harness h = Harness(policy: (_) => approval.future);
        addTearDown(h.dispose);
        await h.mount(tester);
        Object? received = 'pending';
        activeRoute(tester).popped.then((dynamic value) => received = value);
        h.delegate.navigatorKey.currentState!.pop('obsolete');
        await tester.pumpAndSettle();
        h.manager.resetTo(page('login'));
        await tester.pumpAndSettle();
        approval.complete(true);
        await tester.pumpAndSettle();
        expect(received, isNull);
        expect(h.manager.historyNames, <String>['login']);
      },
    );

    testWidgets(
      'Given pending approval When local history is added Then approval consumes local history only',
      (WidgetTester tester) async {
        final Completer<bool> approval = Completer<bool>();
        final Harness h = Harness(policy: (_) => approval.future);
        addTearDown(h.dispose);
        await h.mount(tester);
        final ModalRoute<dynamic> route = activeRoute(tester);
        h.delegate.navigatorKey.currentState!.pop('result');
        await tester.pumpAndSettle();
        bool removed = false;
        route.addLocalHistoryEntry(
          LocalHistoryEntry(onRemove: () => removed = true),
        );
        approval.complete(true);
        await tester.pumpAndSettle();
        expect(removed, isTrue);
        expect(route.isCurrent, isTrue);
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      },
    );

    testWidgets(
      'Given an approved result When the pop callback resets Then preserve the reset and result',
      (WidgetTester tester) async {
        final Harness h = Harness(policy: (_) => true);
        addTearDown(h.dispose);
        final List<dynamic> results = <dynamic>[];
        h.delegate.update(
          registry: ResultRegistry((bool didPop, dynamic result) {
            if (didPop && result == 'accepted') {
              results.add(result);
              h.manager.resetTo(page('login'));
            }
          }),
        );
        await h.mount(tester);
        Object? received;
        activeRoute(tester).popped.then((dynamic value) => received = value);
        h.delegate.navigatorKey.currentState!.pop('accepted');
        await tester.pumpAndSettle();
        expect(received, 'accepted');
        expect(results, <dynamic>['accepted']);
        expect(h.manager.historyNames, <String>['login']);
      },
    );
  });

  group('User back browser entry identity', () {
    testWidgets(
      'Given a multi-entry forward jump When intermediate pages were discarded Then navigate only to its destination',
      (WidgetTester tester) async {
        int calls = 0;
        bool allow = true;
        final Harness h = Harness(
          policy: (_) {
            calls++;
            return allow;
          },
        );
        addTearDown(h.dispose);
        await h.mount(tester);
        h.manager.resetTo(page('home'));
        await tester.pumpAndSettle();
        h.manager.push(page('a'));
        await tester.pumpAndSettle();
        final RouteInformation aEntry = h.provider.value;
        h.manager.push(page('b'));
        await tester.pumpAndSettle();
        h.manager.push(page('login'));
        await tester.pumpAndSettle();
        final RouteInformation lastEntry = h.provider.value;
        await h.provider.didPushRouteInformation(aEntry);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a']);
        expect(calls, 1);
        allow = false;
        await h.provider.didPushRouteInformation(lastEntry);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'login']);
        expect(h.provider.value.uri.path, '/login');
        expect(
          find.byKey(const ValueKey<String>('view-login')),
          findsOneWidget,
        );
        expect(
          calls,
          1,
          reason: 'Known forward navigation bypasses the policy',
        );
      },
    );

    testWidgets(
      'Given consecutive equal URIs When going back and forward Then preserve the intended occurrences',
      (WidgetTester tester) async {
        final Harness h = Harness(policy: (_) => true);
        addTearDown(h.dispose);
        await h.mount(tester);
        h.manager.resetTo(page('home'));
        await tester.pumpAndSettle();
        h.manager.push(page('a'));
        await tester.pumpAndSettle();
        final RouteInformation firstA = h.provider.value;
        Router.navigate(activeRoute(tester, 'a').subtreeContext!, () {
          h.manager.push(page('a'), allowDuplicate: true);
        });
        await tester.pumpAndSettle();
        final RouteInformation secondA = h.provider.value;
        h.manager.push(page('login'), allowDuplicate: true);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'a', 'login']);
        await h.provider.didPushRouteInformation(secondA);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'a']);
        await h.provider.didPushRouteInformation(firstA);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a']);
        await h.provider.didPushRouteInformation(secondA);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'a']);
      },
    );

    for (final bool consecutive in <bool>[false, true]) {
      testWidgets(
        'Given repeated URIs consecutive=$consecutive When history targets the earlier entry '
        'Then truncate to its original stack position',
        (WidgetTester tester) async {
          final Harness h = Harness(policy: (_) => true);
          addTearDown(h.dispose);
          await h.mount(tester);
          h.manager.resetTo(page('home'));
          await tester.pumpAndSettle();
          h.manager.push(page('a'));
          await tester.pumpAndSettle();
          final RouteInformation firstA = h.provider.value;
          if (!consecutive) {
            h.manager.push(page('b'));
            await tester.pumpAndSettle();
          }
          Router.navigate(
              activeRoute(tester, consecutive ? 'a' : 'b').subtreeContext!, () {
            h.manager.push(page('a'), allowDuplicate: true);
          });
          await tester.pumpAndSettle();
          if (!consecutive) {
            h.manager.push(page('login'));
            await tester.pumpAndSettle();
          }
          await h.provider.didPushRouteInformation(firstA);
          await tester.pumpAndSettle();
          expect(h.manager.historyNames, <String>['home', 'a']);
          expect(h.provider.value.uri.path, '/a');
        },
      );
    }
  });

  group('User back policy lifecycle', () {
    testWidgets(
      'Given pending approval When the same instance method tear-off is supplied again Then retain the decision',
      (WidgetTester tester) async {
        final PendingPolicy owner = PendingPolicy();
        final UserBackNavigationPolicy first = owner.handle;
        final Harness h = Harness(policy: first);
        addTearDown(h.dispose);
        await h.mount(tester);
        final Future<bool> pending = h.delegate.popRoute();
        int notifications = 0;
        h.delegate.addListener(() => notifications++);
        final UserBackNavigationPolicy second = owner.handle;
        expect(second, equals(first));
        h.delegate.userBackNavigationPolicy = second;
        expect(notifications, 0);
        await tester.pumpAndSettle();
        owner.decision.complete(true);
        expect(await pending, isTrue);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a']);
      },
    );

    testWidgets(
      'Given pending approval When a different instance supplies the same method Then invalidate only the old decision',
      (WidgetTester tester) async {
        final PendingPolicy first = PendingPolicy();
        final PendingPolicy second = PendingPolicy();
        final Harness h = Harness(policy: first.handle);
        addTearDown(h.dispose);
        await h.mount(tester);
        final Future<bool> pending = h.delegate.popRoute();
        h.delegate.userBackNavigationPolicy = second.handle;
        first.decision.complete(true);
        expect(await pending, isTrue);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
        second.decision.complete(true);
        await h.delegate.popRoute();
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a']);
      },
    );

    testWidgets(
      'Given no policy When installing and removing it Then retain stack while recreating routes',
      (WidgetTester tester) async {
        final Harness h = Harness();
        addTearDown(h.dispose);
        await h.mount(tester);
        final ModalRoute<dynamic> initial = activeRoute(tester);
        final NavStackModel stack = h.manager.stack;
        h.delegate.userBackNavigationPolicy = (_) => false;
        await tester.pumpAndSettle();
        final ModalRoute<dynamic> guarded = activeRoute(tester);
        expect(guarded, isNot(same(initial)));
        expect(h.manager.stack, same(stack));
        h.delegate.userBackNavigationPolicy = null;
        await tester.pumpAndSettle();
        expect(activeRoute(tester), isNot(same(guarded)));
        expect(h.manager.stack, same(stack));
      },
    );

    testWidgets(
      'Given a stateful page and installed policy When its decision changes Then retain route and widget state',
      (WidgetTester tester) async {
        bool allow = false;
        final Harness h = Harness(policy: (_) => allow);
        addTearDown(h.dispose);
        h.delegate.update(
          registry: PageRegistry(<String, PageWidgetBuilder>{
            for (final String name in <String>['home', 'a', 'b'])
              name: (_, __) => const CounterPage(),
          }),
        );
        await h.mount(tester);
        await tester.tap(find.text('Count 0'));
        await tester.pumpAndSettle();
        final Element element = tester.element(find.byType(CounterPage));
        final ModalRoute<dynamic> route = ModalRoute.of(element)!;
        await h.delegate.popRoute();
        await tester.pumpAndSettle();
        allow = true;
        h.delegate.userBackNavigationPolicy = (_) => allow;
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(CounterPage)), same(element));
        expect(ModalRoute.of(element), same(route));
        expect(find.text('Count 1'), findsOneWidget);
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
      },
    );
  });
}
