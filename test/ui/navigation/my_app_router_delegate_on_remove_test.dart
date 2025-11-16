import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

PageRegistry _registry() {
  return PageRegistry.fromDefs(<PageDef>[
    PageDef(
      model: const PageModel(name: 'home'),
      builder: (_, __) => const Scaffold(
        body: Center(child: Text('HOME', key: Key('txt-home'))),
      ),
    ),
    PageDef(
      model: const PageModel(name: 'details'),
      builder: (_, __) => const Scaffold(
        body: Center(child: Text('DETAILS', key: Key('txt-details'))),
      ),
    ),
  ]);
}

class _FakeParser extends RouteInformationParser<NavStackModel> {
  const _FakeParser(this.pm);
  final PageManager pm;

  @override
  Future<NavStackModel> parseRouteInformation(RouteInformation _) async =>
      pm.stack;

  @override
  RouteInformation? restoreRouteInformation(NavStackModel __) =>
      RouteInformation(uri: Uri(path: '/'));
}

void main() {
  group('MyAppRouterDelegate (pages + onDidRemovePage como hook, sin mutar)',
      () {
    late PageManager pm;
    late PageRegistry reg;
    late MyAppRouterDelegate delegate;
    late List<String> removed;
    StreamSubscription<NavStackModel>? sub;

    setUp(() {
      final NavStackModel initial = NavStackModel(
        const <PageModel>[PageModel(name: 'home')],
      );
      pm = PageManager(initial: initial);
      reg = _registry();
      removed = <String>[];

      delegate = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
        // hook opcional: solo notifica; no muta PageManager
        onPageRemoved: (Page<Object?> p) => removed.add(p.name ?? '<no-name>'),
      );

      sub = pm.stackStream.listen((_) {});
    });

    tearDown(() async {
      await sub?.cancel();
      delegate.dispose();
    });

    Future<void> mount(WidgetTester t) async {
      final MaterialApp app = MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: _FakeParser(pm),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(uri: Uri(path: '/home')),
        ),
      );
      await t.pumpWidget(app);
      await t.pumpAndSettle();
    }

    testWidgets(
        'projectorMode=false: push details, back (sistema) vuelve a home',
        (WidgetTester t) async {
      await mount(t);
      expect(find.byKey(const ValueKey<String>('txt-home')), findsOneWidget);

      pm.pushNamed('details');
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('txt-details')), findsOneWidget);

      // Back del sistema → RouterDelegate.popRoute() → PageManager.pop()
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('txt-home')), findsOneWidget);
      // onDidRemovePage debe haberse disparado al remover 'details'
      if (removed.isNotEmpty) {
        expect(removed.contains('details'), isTrue);
      }
    });

    testWidgets(
        'projectorMode=true: solo top materializada; back (sistema) vuelve a home',
        (WidgetTester t) async {
      delegate.update(projectorMode: true);
      await mount(t);

      expect(find.byKey(const ValueKey<String>('txt-home')), findsOneWidget);

      pm.pushNamed('details');
      await t.pumpAndSettle();
      expect(
        reg.contains('details'),
        isTrue,
        reason: 'Falta registrar builder para "details"',
      );

      // solo top
      expect(find.byKey(const ValueKey<String>('txt-details')), findsOneWidget);
      final Finder homeOffstage = find.byWidgetPredicate(
        (Widget w) => w.key == const ValueKey<String>('txt-home'),
        skipOffstage: false,
      );
      expect(homeOffstage, findsNothing);

      // back por sistema
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('txt-home')), findsOneWidget);
      if (removed.isNotEmpty) {
        expect(removed.contains('details'), isTrue);
      }
    });

    testWidgets('update(...) re-suscribe a un nuevo PageManager',
        (WidgetTester t) async {
      await mount(t);

      final PageManager pm2 = PageManager(
        initial: NavStackModel(
          const <PageModel>[PageModel(name: 'home')],
        ),
      );
      delegate.update(pageManager: pm2);
      await t.pump();

      pm2.pushNamed('details');
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('txt-details')), findsOneWidget);

      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('txt-home')), findsOneWidget);
    });
  });
}
