import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
  const FakeAppManager({super.key, required this.pm, required super.child});
  final FakePageManager pm;

  // expón algo que la extensión `context.appManager` pueda resolver
  // Si tu proyecto usa un tipo AppManager real, crea un wrapper que cumpla.
  static FakeAppManager of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FakeAppManager>()!;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

// Extensión ad-hoc para test (si en tu proyecto `context.appManager` ya existe, NO definas esto)
extension _AppManagerCtx on BuildContext {
  FakeAppManager get appManager => FakeAppManager.of(this);
}

class _Host extends StatelessWidget {
  const _Host({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MaterialApp(home: child);
}

class _Probe extends StatelessWidget {
  const _Probe(
      {required this.child, required this.registry, required this.page});
  final Widget child;
  final PageRegistry registry;
  final PageModel page;

  @override
  Widget build(BuildContext context) {
    // Inserta en el árbol algo que use registry.build para renderizar.
    return MaterialApp(
      home: Builder(
        builder: (context) => registry.build(context, page),
      ),
    );
  }
}

void main() {
  group('PageRegistry / build()', () {
    testWidgets(
        'Given name conocido When build Then renderiza builder asociado',
        (tester) async {
      final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
        'home': (ctx, p) => const Text('HOME'),
      });

      await tester.pumpWidget(_Probe(
        child: const SizedBox.shrink(),
        registry: registry,
        page: const PageModel(name: 'home'),
      ));

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets(
        'Given name desconocido + notFoundBuilder When build Then muestra 404 custom',
        (tester) async {
      final PageRegistry registry = PageRegistry(
        <String, PageWidgetBuilder>{},
        notFoundBuilder: (ctx, req) => const Text('C404'),
      );

      await tester.pumpWidget(_Probe(
        child: const SizedBox.shrink(),
        registry: registry,
        page: const PageModel(name: 'missing'),
      ));

      expect(find.text('C404'), findsOneWidget);
    });

    testWidgets(
        'Given name desconocido + sin notFound + sin redirects When build Then muestra 404 interno',
        (tester) async {
      final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{});

      await tester.pumpWidget(_Probe(
        child: const SizedBox.shrink(),
        registry: registry,
        page: const PageModel(name: 'missing', segments: <String>['x']),
      ));

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
        'a': (ctx, p) => const SizedBox.shrink(),
      };
      final PageRegistry reg = PageRegistry(ext);
      ext['b'] = (ctx, p) => const Text('B'); // mutación externa

      expect(reg.contains('a'), isTrue);
      expect(reg.contains('b'), isFalse,
          reason: 'Debe ser copia inmutable interna');
    });
  });

  group('Testing widgets', () {
    testWidgets(
        'Given defaultStack y defaultPage When name desconocido Then usa setStack (tiene mayor precedencia)',
        (tester) async {
      final FakePageManager pm = FakePageManager(initial: defaultNavStackModel);

      final PageRegistry registry = PageRegistry(
        <String, PageWidgetBuilder>{},
        defaultPage: const PageModel(name: 'fallback'),
        defaultStack: NavStackModel(const <PageModel>[PageModel(name: 'home')]),
      );

      await tester.pumpWidget(
        FakeAppManager(
          pm: pm,
          child: _Host(
            child: Builder(
              builder: (ctx) =>
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
        (tester) async {
      final FakePageManager pm = FakePageManager(initial: defaultNavStackModel);
      final PageRegistry registry = PageRegistry(
        <String, PageWidgetBuilder>{},
        defaultPage: const PageModel(name: 'fallback'),
      );

      await tester.pumpWidget(
        FakeAppManager(
          pm: pm,
          child: _Host(
            child: Builder(
              builder: (ctx) =>
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
          name: 'details', query: <String, String>{'b': '2', 'a': '1'});
      const PageModel b = PageModel(
          name: 'details', query: <String, String>{'a': '1', 'b': '2'});

      final Page pa = PageRegistry(<String, PageWidgetBuilder>{}).toPage(a);
      final Page pb = PageRegistry(<String, PageWidgetBuilder>{}).toPage(b);

      expect((pa.key as ValueKey).value, (pb.key as ValueKey).value);
    });
  });
}
