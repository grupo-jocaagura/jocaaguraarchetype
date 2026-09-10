import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'user_back_navigation_test.dart' show Harness;

class FlutterContractRegistry extends PageRegistry {
  FlutterContractRegistry({
    this.pageCanPop = true,
    ValueNotifier<bool>? scopeCanPop,
    List<bool>? scopeEvents,
  }) : super(<String, PageWidgetBuilder>{
          for (final String name in <String>['home', 'a', 'b'])
            name: (_, __) => scopeCanPop == null
                ? Text(name, key: ValueKey<String>('view-$name'))
                : ValueListenableBuilder<bool>(
                    valueListenable: scopeCanPop,
                    builder: (_, bool canPop, __) => PopScope<dynamic>(
                      canPop: canPop,
                      onPopInvokedWithResult: (bool didPop, dynamic result) {
                        scopeEvents?.add(didPop);
                      },
                      child: Text(name, key: ValueKey<String>('view-$name')),
                    ),
                  ),
        });

  final bool pageCanPop;

  @override
  Page<dynamic> toPage(PageModel page, {int? position}) {
    final Page<dynamic> original = super.toPage(page, position: position);
    if (original is CupertinoPage<dynamic>) {
      return CupertinoPage<dynamic>(
        key: original.key,
        name: original.name,
        canPop: pageCanPop,
        allowSnapshotting: false,
        child: original.child,
      );
    }
    return MaterialPage<dynamic>(
      key: original.key,
      name: original.name,
      canPop: pageCanPop,
      child: (original as MaterialPage<dynamic>).child,
    );
  }
}

void main() {
  group('User back Flutter precedence', () {
    testWidgets(
      'Given CupertinoPage allowSnapshotting false When policy is installed Then preserve the route option',
      (WidgetTester tester) async {
        final Harness h =
            Harness(kind: PageKind.cupertino, policy: (_) => true);
        addTearDown(h.dispose);
        h.delegate.update(registry: FlutterContractRegistry());
        await h.mount(tester, platform: TargetPlatform.iOS);
        final CupertinoPageRoute<dynamic> route = ModalRoute.of(
          tester.element(find.byKey(const ValueKey<String>('view-b'))),
        )! as CupertinoPageRoute<dynamic>;
        expect(route.allowSnapshotting, isFalse);
      },
    );

    for (final UserBackNavigationSource source in <UserBackNavigationSource>[
      UserBackNavigationSource.system,
      UserBackNavigationSource.appBar,
    ]) {
      testWidgets(
        'Given PopScope veto and local history When $source requests back Then retain local history before consulting policy',
        (WidgetTester tester) async {
          final ValueNotifier<bool> canPop = ValueNotifier<bool>(false);
          addTearDown(canPop.dispose);
          final List<bool> events = <bool>[];
          int calls = 0;
          final Harness h = Harness(
            policy: (_) {
              calls++;
              return true;
            },
          );
          addTearDown(h.dispose);
          h.delegate.update(
            registry: FlutterContractRegistry(
              scopeCanPop: canPop,
              scopeEvents: events,
            ),
          );
          await h.mount(tester);
          final ModalRoute<dynamic> route = ModalRoute.of(
            tester.element(find.byKey(const ValueKey<String>('view-b'))),
          )!;
          bool removed = false;
          route.addLocalHistoryEntry(
            LocalHistoryEntry(onRemove: () => removed = true),
          );
          await tester.pumpAndSettle();
          expect(route.popDisposition, RoutePopDisposition.doNotPop);
          expect(await h.delegate.requestUserBack(source: source), isTrue);
          await tester.pumpAndSettle();
          expect(removed, isFalse);
          expect(route.willHandlePopInternally, isTrue);
          expect(events, <bool>[false]);
          expect(calls, 0);
          expect(h.manager.historyNames, <String>['home', 'a', 'b']);
          canPop.value = true;
          await tester.pumpAndSettle();
          expect(
            removed,
            isFalse,
            reason: 'Lifting the veto must not replay back',
          );
          await h.delegate.requestUserBack(source: source);
          await tester.pumpAndSettle();
          expect(removed, isTrue);
          expect(calls, 0);
          expect(h.manager.historyNames, <String>['home', 'a', 'b']);
          await h.delegate.requestUserBack(source: source);
          await tester.pumpAndSettle();
          expect(calls, 1);
          expect(h.manager.historyNames, <String>['home', 'a']);
        },
      );

      testWidgets(
        'Given Page.canPop false and local history When $source requests back Then consume local history as Flutter allows',
        (WidgetTester tester) async {
          int calls = 0;
          final Harness h = Harness(
            policy: (_) {
              calls++;
              return true;
            },
          );
          addTearDown(h.dispose);
          h.delegate
              .update(registry: FlutterContractRegistry(pageCanPop: false));
          await h.mount(tester);
          final ModalRoute<dynamic> route = ModalRoute.of(
            tester.element(find.byKey(const ValueKey<String>('view-b'))),
          )!;
          bool removed = false;
          route.addLocalHistoryEntry(
            LocalHistoryEntry(onRemove: () => removed = true),
          );
          await tester.pumpAndSettle();
          expect(route.popDisposition, RoutePopDisposition.pop);
          await h.delegate.requestUserBack(source: source);
          await tester.pumpAndSettle();
          expect(removed, isTrue);
          expect(calls, 0);
          expect(h.manager.historyNames, <String>['home', 'a', 'b']);
          expect(route.popDisposition, RoutePopDisposition.doNotPop);
          await h.delegate.requestUserBack(source: source);
          await tester.pumpAndSettle();
          expect(calls, 0);
          expect(h.manager.historyNames, <String>['home', 'a', 'b']);
        },
      );

      testWidgets(
        'Given Page.canPop false When $source requests back Then honor Flutter before policy',
        (WidgetTester tester) async {
          int calls = 0;
          final Harness h = Harness(
            policy: (_) {
              calls++;
              return true;
            },
          );
          addTearDown(h.dispose);
          h.delegate
              .update(registry: FlutterContractRegistry(pageCanPop: false));
          await h.mount(tester);
          expect(await h.delegate.requestUserBack(source: source), isTrue);
          await tester.pumpAndSettle();
          expect(calls, 0);
          expect(h.manager.historyNames, <String>['home', 'a', 'b']);
          h.delegate.update(registry: FlutterContractRegistry());
          await tester.pumpAndSettle();
          await h.delegate.requestUserBack(source: source);
          await tester.pumpAndSettle();
          expect(calls, 1);
          expect(h.manager.historyNames, <String>['home', 'a']);
        },
      );

      testWidgets(
        'Given PopScope canPop false When $source requests back Then notify Flutter veto without consulting policy',
        (WidgetTester tester) async {
          final ValueNotifier<bool> canPop = ValueNotifier<bool>(false);
          addTearDown(canPop.dispose);
          final List<bool> events = <bool>[];
          int calls = 0;
          final Harness h = Harness(
            policy: (_) {
              calls++;
              return true;
            },
          );
          addTearDown(h.dispose);
          h.delegate.update(
            registry: FlutterContractRegistry(
              scopeCanPop: canPop,
              scopeEvents: events,
            ),
          );
          await h.mount(tester);
          expect(await h.delegate.requestUserBack(source: source), isTrue);
          await tester.pumpAndSettle();
          expect(events, <bool>[false]);
          expect(calls, 0);
          expect(h.manager.historyNames, <String>['home', 'a', 'b']);
          canPop.value = true;
          await tester.pumpAndSettle();
          expect(
            calls,
            0,
            reason: 'Removing a veto must not replay the request',
          );
          await h.delegate.requestUserBack(source: source);
          await tester.pumpAndSettle();
          expect(calls, 1);
          expect(h.manager.historyNames, <String>['home', 'a']);
        },
      );
    }

    testWidgets(
      'Given pending approval When PopScope vetoes Then recheck Flutter before mutating',
      (WidgetTester tester) async {
        final Completer<bool> approval = Completer<bool>();
        final ValueNotifier<bool> canPop = ValueNotifier<bool>(true);
        addTearDown(canPop.dispose);
        final Harness h = Harness(policy: (_) => approval.future);
        addTearDown(h.dispose);
        h.delegate
            .update(registry: FlutterContractRegistry(scopeCanPop: canPop));
        await h.mount(tester);
        final Future<bool> pending = h.delegate.popRoute();
        canPop.value = false;
        await tester.pumpAndSettle();
        approval.complete(true);
        expect(await pending, isTrue);
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
        canPop.value = true;
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a', 'b']);
        await h.delegate.popRoute();
        await tester.pumpAndSettle();
        expect(h.manager.historyNames, <String>['home', 'a']);
      },
    );

    testWidgets(
      'Given no policy and PopScope veto When system back occurs Then preserve legacy synchronous behavior',
      (WidgetTester tester) async {
        final ValueNotifier<bool> canPop = ValueNotifier<bool>(false);
        addTearDown(canPop.dispose);
        final Harness h = Harness();
        addTearDown(h.dispose);
        h.delegate
            .update(registry: FlutterContractRegistry(scopeCanPop: canPop));
        await h.mount(tester);
        final Future<bool> pending = h.delegate.popRoute();
        expect(h.manager.historyNames, <String>['home', 'a']);
        expect(await pending, isTrue);
        await tester.pumpAndSettle();
      },
    );
  });
}
