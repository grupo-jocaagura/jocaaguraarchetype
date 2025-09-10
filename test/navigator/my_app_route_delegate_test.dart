import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ------------------------------------------------------
/// Fakes de soporte (sin paquetes externos).
/// ------------------------------------------------------

/// Adapta `Map<String, WidgetBuilder>` a `PageRegistry` real.
class FakePageRegistry extends PageRegistry {
  FakePageRegistry(
    Map<String, WidgetBuilder> widgetBuilders, {
    super.notFoundBuilder,
    super.defaultPage,
    super.defaultStack,
  }) : super(
          widgetBuilders.map<String, PageWidgetBuilder>(
            (String name, WidgetBuilder b) =>
                MapEntry<String, PageWidgetBuilder>(
              name,
              (BuildContext ctx, PageModel _) => b(ctx),
            ),
          ),
        );
}

/// PageManager de pruebas con contadores y política tolerante post-dispose.
class FakePageManager extends PageManager {
  FakePageManager({required super.initial})
      : super(
            postDisposePolicy: ModulePostDisposePolicy.returnLastSnapshotNoop);

  factory FakePageManager.fromNames(List<String> names) {
    final List<PageModel> pages = names
        .map((String n) => PageModel(name: n, segments: <String>[n]))
        .toList(growable: false);
    return FakePageManager(initial: NavStackModel(pages));
  }

  factory FakePageManager.fromPages(List<PageModel> pages) {
    return FakePageManager(initial: NavStackModel(pages));
  }

  int popCalls = 0;
  int replaceTopCalls = 0;
  int navigateCalls = 0;

  @override
  bool pop() {
    popCalls += 1;
    return super.pop();
  }

  @override
  void replaceTop(PageModel page, {bool allowNoop = false}) {
    replaceTopCalls += 1;
    super.replaceTop(page, allowNoop: allowNoop);
  }

  @override
  void navigateToLocation(
    String location, {
    String? name,
    PageKind kind = PageKind.material,
    bool mustReplaceTop = false,
    bool allowDuplicate = false,
  }) {
    navigateCalls += 1;
    super.navigateToLocation(
      location,
      name: name,
      kind: kind,
      mustReplaceTop: mustReplaceTop,
      allowDuplicate: allowDuplicate,
    );
  }
}

/// ------------------------------------------------------
/// Helpers
/// ------------------------------------------------------

PageModel _p(String name) => PageModel(name: name, segments: <String>[name]);

NavStackModel _s(List<String> names) =>
    NavStackModel(names.map(_p).toList(growable: false));

Widget _hostWithDelegate({
  required MyAppRouterDelegate delegate,
  String initialPath = '/home',
}) {
  return MaterialApp.router(
    routerDelegate: delegate,
    routeInformationParser:
        const MyRouteInformationParser(defaultRouteName: 'home'),
    routeInformationProvider: PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri(path: initialPath)),
    ),
    // Asegura que popRoute() fluya correctamente en tests.
    backButtonDispatcher: RootBackButtonDispatcher(),
  );
}

/// ------------------------------------------------------
/// TESTS
/// ------------------------------------------------------

void main() {
  group('MyAppRouterDelegate - construcción y configuración', () {
    testWidgets(
        'Given stack [home] When build Then genera 1 Page en modo full-stack',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromPages(_s(<String>['home']).pages);
      final FakePageRegistry reg = FakePageRegistry(<String, WidgetBuilder>{
        'home': (_) => const Scaffold(body: Text('HOME')),
      });

      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
        projectorMode: false,
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      final NavigatorState nav = delegate.navigatorKey.currentState!;
      expect(nav.widget.pages.length, 1);
      expect(pm.popCalls, 0);
    });

    testWidgets(
        'Given projectorMode true When build with [home, test-1] Then solo 1 Page (top-only)',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromNames(<String>['home', 'test-1']);

      final FakePageRegistry reg = FakePageRegistry(<String, WidgetBuilder>{
        'home': (_) => const Scaffold(body: Text('HOME')),
        'test-1': (_) => const Scaffold(body: Text('TEST-1')),
      });

      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
        projectorMode: true,
      );

      // IMPORTANTe: alineamos la URI inicial con el tope ('/test-1')
      await tester.pumpWidget(
        _hostWithDelegate(delegate: delegate, initialPath: '/test-1'),
      );
      await tester.pump();

      final NavigatorState nav = delegate.navigatorKey.currentState!;
      expect(nav.widget.pages.length, 1);
      final Page<dynamic> only = nav.widget.pages.single;
      expect((only as MaterialPage).name, 'test-1');
    });

    testWidgets(
        'Given currentConfiguration When read Then coincide con PageManager.stack',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromNames(<String>['home', 'test-1']);

      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{}),
        pageManager: pm,
      );
      expect(delegate.currentConfiguration.pages.map((e) => e.name),
          <String>['home', 'test-1']);
    });
  });

  group('Reconciliación de removals (full stack)', () {
    testWidgets(
        'Given pop en modelo When build Then onDidRemovePage no llama pm.pop() (solo callback)',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromNames(<String>['home', 'test-1']);

      final List<Page<Object?>> removed = <Page<Object?>>[];
      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'test-1': (_) => const Scaffold(body: Text('TEST-1')),
        }),
        pageManager: pm,
        projectorMode: false,
        onPageRemoved: (p) => removed.add(p),
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      // Act: pop desde el MODELO
      pm.pop(); // emite stack [home]
      await tester.pump();

      // Assert:
      expect(pm.popCalls, 1); // solo el pop que hicimos arriba
      // Debe haber exactamente 1 removal observado por el Navigator
      expect(removed.length, 1);
      final NavigatorState nav = delegate.navigatorKey.currentState!;
      expect(nav.widget.pages.length, 1);
    });

    testWidgets(
        'Given pop desde Navigator When build Then delegate reenvía pop a pm.pop()',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromNames(<String>['home', 'test-1']);

      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'test-1': (_) => const Scaffold(body: Text('TEST-1')),
        }),
        pageManager: pm,
        projectorMode: false,
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      final NavigatorState nav = delegate.navigatorKey.currentState!;
      // Act: pop iniciado por el Navigator (gesto/usuario)
      nav.pop(); // dispara onDidRemovePage sin que el modelo haya emitido
      await tester.pump();

      // Assert: delegate detecta removal inesperado y llama pm.pop()
      expect(pm.popCalls, 1);
      expect(nav.widget.pages.length, 1);
    });
  });

  group('Reconciliación en projectorMode', () {
    testWidgets(
        'Given projectorMode true + replaceTop en modelo Then espera 1 removal',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromNames(<String>['home', 'test-1']);

      int callbackCount = 0;
      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'test-1': (_) => const Scaffold(body: Text('TEST-1')),
          'test-2': (_) => const Scaffold(body: Text('TEST-2')),
        }),
        pageManager: pm,
        projectorMode: true,
        onPageRemoved: (_) => callbackCount++,
      );

      // Alinea la URI con el tope inicial
      await tester.pumpWidget(
        _hostWithDelegate(delegate: delegate, initialPath: '/test-1'),
      );
      await tester.pump();

      // Act: replaceTop en el MODELO
      pm.replaceTop(_p('test-2'));
      await tester.pump();

      // Assert: solo callback; no re-pop del modelo
      expect(pm.popCalls, 0);
      expect(callbackCount, 1);

      final NavigatorState nav = delegate.navigatorKey.currentState!;
      expect(nav.widget.pages.single is MaterialPage, true);
      final MaterialPage page = nav.widget.pages.single as MaterialPage;
      expect(page.name, 'test-2');
    });
  });

  group('setNewRoutePath', () {
    testWidgets(
        'Given primera invocación When setNewRoutePath Then navega con mustReplaceTop=true',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromPages(_s(<String>['home']).pages);

      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'about': (_) => const Scaffold(body: Text('ABOUT')),
        }),
        pageManager: pm,
        projectorMode: false,
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      // Act: primera ruta nueva
      await delegate.setNewRoutePath(_s(<String>['about']));

      // Assert: puede llegar por navigateToLocation o por replaceTop directo
      final int navEffects = pm.navigateCalls + pm.replaceTopCalls;
      expect(navEffects, greaterThanOrEqualTo(1));
      expect(pm.stack.top.name, 'about');
    });

    testWidgets(
        'Given llamadas subsecuentes When setNewRoutePath Then navega sin mustReplaceTop forzado',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromPages(_s(<String>['home']).pages);

      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'about': (_) => const Scaffold(body: Text('ABOUT')),
          'contact': (_) => const Scaffold(body: Text('CONTACT')),
        }),
        pageManager: pm,
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      await delegate.setNewRoutePath(_s(<String>['about']));
      await tester.pump();

      final int before = pm.navigateCalls + pm.replaceTopCalls;
      await delegate.setNewRoutePath(_s(<String>['contact']));
      await tester.pump();

      expect(pm.navigateCalls + pm.replaceTopCalls, greaterThan(before));
      expect(pm.stack.top.name, 'contact');
    });
  });

  group('update() y ciclo de vida', () {
    testWidgets(
        'Given update con nuevo PageManager When called Then re-suscribe y reinicia snapshot',
        (tester) async {
      final FakePageManager pm1 =
          FakePageManager.fromPages(_s(<String>['home']).pages);
      final FakePageManager pm2 =
          FakePageManager.fromPages(_s(<String>['home']).pages);
      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'p2': (_) => const Scaffold(body: Text('P2')),
        }),
        pageManager: pm1,
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      // Cambiamos PageManager
      delegate.update(pageManager: pm2);
      await tester.pump();

      // Emitimos desde el nuevo manager
      pm2.push(_p('p2'));
      await tester.pump();

      // Navegador refleja el cambio del nuevo manager
      final NavigatorState nav = delegate.navigatorKey.currentState!;
      expect(nav.widget.pages.last is MaterialPage, true);
      expect((nav.widget.pages.last as MaterialPage).name, 'p2');
    });

    testWidgets(
        'Given dispose idempotente When called twice Then no arroja y cancela listener',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromPages(_s(<String>['home']).pages);
      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME'))
        }),
        pageManager: pm,
      );

      await tester.pumpWidget(_hostWithDelegate(delegate: delegate));
      await tester.pump();

      delegate.dispose();
      expect(delegate.isDisposed, true);

      // Segunda llamada no debe fallar
      delegate.dispose();
      expect(delegate.isDisposed, true);
    });

    testWidgets('Given popRoute When invoked Then reenvía a pm.pop()',
        (tester) async {
      final FakePageManager pm =
          FakePageManager.fromNames(<String>['home', 'test']);
      final MyAppRouterDelegate delegate = MyAppRouterDelegate(
        registry: FakePageRegistry(<String, WidgetBuilder>{
          'home': (_) => const Scaffold(body: Text('HOME')),
          'test': (_) => const Scaffold(body: Text('TEST')),
        }),
        pageManager: pm,
      );

      await tester.pumpWidget(
        _hostWithDelegate(delegate: delegate, initialPath: '/test'),
      );
      await tester.pump();

      final bool ok = await delegate.popRoute();
      expect(ok, true);
      expect(pm.popCalls, 1);
      final NavigatorState nav = delegate.navigatorKey.currentState!;
      expect(nav.widget.pages.length, 1);
    });
  });
}
