import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class _TestAppConfig extends AppConfig {
  _TestAppConfig({
    required super.pageManager,
    required super.blocTheme,
    required super.blocUserNotifications,
    required super.blocLoading,
    required super.blocMainMenuDrawer,
    required super.blocSecondaryMenuDrawer,
    required super.blocResponsive,
    required super.blocOnboarding,
  });

  @override
  void dispose() {/* no-op en test */}

  @override
  T requireModuleByKey<T extends BlocModule>(String key) =>
      throw UnimplementedError();
  @override
  T requireModuleOfType<T extends BlocModule>() => throw UnimplementedError();
}

// --- Provider real que usa AppManagerProvider del paquete ---
class TestAppManagerProvider extends StatelessWidget {
  const TestAppManagerProvider({
    required this.pm,
    required this.child,
    super.key,
  });

  final PageManager pm;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppConfig appConfigDev =
        AppConfig.dev(registry: PageRegistry.fromDefs(<PageDef>[]));

    final AppConfig testConfig = _TestAppConfig(
      pageManager: pm,
      blocTheme: appConfigDev.blocTheme,
      blocUserNotifications: appConfigDev.blocUserNotifications,
      blocLoading: appConfigDev.blocLoading,
      blocMainMenuDrawer: appConfigDev.blocMainMenuDrawer,
      blocSecondaryMenuDrawer: appConfigDev.blocSecondaryMenuDrawer,
      blocResponsive: appConfigDev.blocResponsive,
      blocOnboarding: appConfigDev.blocOnboarding,
    );

    final AppManager appManager = AppManager(testConfig);
    return AppManagerProvider(appManager: appManager, child: child);
  }
}

class FakePageManager extends PageManager {
  FakePageManager({required super.initial});

  int setStackCalls = 0;
  int replaceTopCalls = 0;
  @override
  void setStack(NavStackModel next, {bool allowDuplicate = false}) =>
      setStackCalls++;
  @override
  void replaceTop(PageModel page, {bool allowNoop = false}) =>
      replaceTopCalls++;
}

class FakeAppManager extends InheritedWidget {
  const FakeAppManager({required this.pm, required super.child, super.key});
  final FakePageManager pm;

  // expón algo que la extensión `context.appManager` pueda resolver
  // Si tu proyecto usa un tipo AppManager real, crea un wrapper que cumpla.
  static FakeAppManager of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FakeAppManager>()!;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

// Extensión ad-hoc para test (si en tu proyecto `context.appManager` ya existe, NO definas esto)
extension _AppManagerCtx on BuildContext {}

class _Host extends StatelessWidget {
  const _Host({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MaterialApp(home: child);
}

class _Probe extends StatelessWidget {
  const _Probe({
    required this.child,
    required this.registry,
    required this.page,
  });
  final Widget child;
  final PageRegistry registry;
  final PageModel page;

  @override
  Widget build(BuildContext context) {
    // Inserta en el árbol algo que use registry.build para renderizar.
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => registry.build(context, page),
      ),
    );
  }
}

void main() {
  group('PageRegistry / build()', () {
    testWidgets(
        'Given name conocido When build Then renderiza builder asociado',
        (WidgetTester tester) async {
      final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
        'home': (BuildContext ctx, PageModel p) => const Text('HOME'),
      });

      await tester.pumpWidget(
        _Probe(
          registry: registry,
          page: const PageModel(name: 'home'),
          child: const SizedBox.shrink(),
        ),
      );

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets(
        'Given name desconocido + notFoundBuilder When build Then muestra 404 custom',
        (WidgetTester tester) async {
      final PageRegistry registry = PageRegistry(
        <String, PageWidgetBuilder>{},
        notFoundBuilder: (BuildContext ctx, PageModel req) =>
            const Text('C404'),
      );

      await tester.pumpWidget(
        _Probe(
          registry: registry,
          page: const PageModel(name: 'missing'),
          child: const SizedBox.shrink(),
        ),
      );

      expect(find.text('C404'), findsOneWidget);
    });

    testWidgets(
        'Given name desconocido + sin notFound + sin redirects When build Then muestra 404 interno',
        (WidgetTester tester) async {
      final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{});

      await tester.pumpWidget(
        _Probe(
          registry: registry,
          page: const PageModel(name: 'missing', segments: <String>['x']),
          child: const SizedBox.shrink(),
        ),
      );

      // `_DefaultNotFoundPage` imprime "404 — <uri>"
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.textContaining('404 —'), findsOneWidget);
    });
  });
  group('Inmutabilidad interna de _builders (riesgo crítico cubierto)', () {
    test(
        'Given ctor principal When muta el mapa externo Then registro no cambia (inmutable)',
        () {
      final Map<String, PageWidgetBuilder> ext = <String, PageWidgetBuilder>{
        'a': (BuildContext ctx, PageModel p) => const SizedBox.shrink(),
      };
      final PageRegistry reg = PageRegistry(ext);
      ext['b'] = (BuildContext ctx, PageModel p) =>
          const Text('B'); // mutación externa

      expect(reg.contains('a'), isTrue);
      expect(
        reg.contains('b'),
        isFalse,
        reason: 'Debe ser copia inmutable interna',
      );
    });
  });

  group('Testing widgets', () {
    testWidgets(
        'Given defaultStack y defaultPage When name desconocido Then usa setStack (tiene mayor precedencia)',
        (WidgetTester tester) async {
      final FakePageManager pm = FakePageManager(initial: defaultNavStackModel);

      final PageRegistry registry = PageRegistry(
        <String, PageWidgetBuilder>{},
        defaultPage: const PageModel(name: 'fallback'),
        defaultStack: NavStackModel(const <PageModel>[PageModel(name: 'home')]),
      );

      await tester.pumpWidget(
        TestAppManagerProvider(
          pm: pm,
          child: _Host(
            child: Builder(
              builder: (BuildContext ctx) =>
                  registry.build(ctx, const PageModel(name: 'missing')),
            ),
          ),
        ),
      );

      // Ejecuta post-frame callbacks
      await tester.pump();

      expect(pm.setStackCalls, 1);
      expect(pm.replaceTopCalls, 0);
    });

    testWidgets(
        'Given solo defaultPage When name desconocido Then usa replaceTop',
        (WidgetTester tester) async {
      final FakePageManager pm = FakePageManager(initial: defaultNavStackModel);
      final PageRegistry registry = PageRegistry(
        <String, PageWidgetBuilder>{},
        defaultPage: const PageModel(name: 'fallback'),
      );

      await tester.pumpWidget(
        TestAppManagerProvider(
          pm: pm,
          child: _Host(
            child: Builder(
              builder: (BuildContext ctx) =>
                  registry.build(ctx, const PageModel(name: 'missing')),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(pm.setStackCalls, 0);
      expect(pm.replaceTopCalls, 1);
    });
  });
  group('Complementary tests', () {
    test(
        'Given queries con distinto orden When toPage Then key es estable (orden canónico por clave)',
        () {
      const PageModel a = PageModel(
        name: 'details',
        query: <String, String>{'b': '2', 'a': '1'},
      );
      const PageModel b = PageModel(
        name: 'details',
        query: <String, String>{'a': '1', 'b': '2'},
      );

      final Page<dynamic> pa =
          PageRegistry(<String, PageWidgetBuilder>{}).toPage(a);
      final Page<dynamic> pb =
          PageRegistry(<String, PageWidgetBuilder>{}).toPage(b);

      expect(
        (pa.key as ValueKey<String>?)?.value,
        (pb.key as ValueKey<String>?)?.value,
      );
    });
  });
}
