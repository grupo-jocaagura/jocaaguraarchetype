import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------------
/// Helpers de montaje
/// ----------------------

PageRegistry _registryForTest() {
  // Registramos la propia TestPageBuilderPage para que el PageManager
  // pueda “resolver” PageModels si algún test lo necesita.
  final List<PageDef> defs = <PageDef>[
    PageDef(
      model: TestPageBuilderPage.pageModel,
      builder: (_, PageModel p) => TestPageBuilderPage.fromPageModel(p),
    ),
  ];
  return PageRegistry.fromDefs(
    defs,
    defaultPage: TestPageBuilderPage.pageModel,
  );
}

AppManager _manager() {
  final AppConfig cfg = AppConfig.dev(registry: _registryForTest());
  return AppManager(cfg);
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget home,
  AppManager? manager,
}) async {
  final AppManager m = manager ?? _manager();
  await tester.pumpWidget(
    AppManagerProvider(
      appManager: m,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Obtiene un BuildContext “confiable” desde el widget bajo prueba.
BuildContext _ctxOf(WidgetTester tester) {
  final bool hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
  final Finder f =
      hasScaffold ? find.byType(Scaffold) : find.byType(MaterialApp);
  return tester.element(f);
}

/// ----------------------
/// TESTS
/// ----------------------

void main() {
  group('TestPageBuilderPage – helpers', () {
    test('make() compone state/query; fromPageModel reconstruye los datos', () {
      final PageModel p = TestPageBuilderPage.make(
        title: 'T1',
        content: 'hello',
      );

      expect(p.name, TestPageBuilderPage.name);
      expect(p.state['title'], 'T1');
      expect(p.query['content'], 'hello');

      final TestPageBuilderPage w = TestPageBuilderPage.fromPageModel(p);
      expect(w.title, 'T1');
      expect(w.contentKey, 'hello');
    });

    testWidgets('builder() devuelve un PageWidgetBuilder funcional',
        (WidgetTester tester) async {
      final PageWidgetBuilder b = TestPageBuilderPage.builder();
      final PageModel p =
          TestPageBuilderPage.make(title: 'Built', content: 'pushed');
      await _pump(
        tester,
        home: MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) => b(ctx, p),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TestPageBuilderPage), findsOneWidget);
      expect(find.text('Built'), findsOneWidget);
    });
  });

  group('TestPageBuilderPage – UI & navegación', () {
    testWidgets('renderiza título y contenido por contentKey "hello"',
        (WidgetTester tester) async {
      final AppManager m = _manager();

      final PageModel p = TestPageBuilderPage.make(
        title: 'Test A',
        content: 'hello',
      );

      await _pump(
        tester,
        manager: m,
        home: TestPageBuilderPage.fromPageModel(p),
      );

      expect(find.text('Test A'), findsOneWidget);
      expect(find.text('Hello, PageModel!'), findsOneWidget);
      // Construye dentro de PageBuilder (smoke)
      expect(find.byType(PageBuilder), findsOneWidget);
    });

    testWidgets('contentKey "pushed" y default fallback',
        (WidgetTester tester) async {
      final AppManager m = _manager();

      // "pushed"
      await _pump(
        tester,
        manager: m,
        home: const TestPageBuilderPage(title: 'T', contentKey: 'pushed'),
      );
      expect(
        find.text('You pushed from TestPageBuilderPage.'),
        findsOneWidget,
      );

      // default (null/otro)
      await _pump(
        tester,
        manager: m,
        home: const TestPageBuilderPage(title: 'T'),
      );
      expect(
        find.text('This is TestPageBuilderPage content.'),
        findsOneWidget,
      );
    });

    testWidgets('botón "Push again" invoca pushOnce → PageManager.canPop=true',
        (WidgetTester tester) async {
      final AppManager m = _manager();

      await _pump(
        tester,
        manager: m,
        home: const TestPageBuilderPage(title: 'Start'),
      );

      // Antes no debería poder “pop” (stack de 1)
      expect(m.pageManager.canPop, isFalse);

      await tester.tap(find.widgetWithText(FilledButton, 'Push again'));
      await tester.pump(); // deja correr onPressed

      expect(m.pageManager.canPop, isTrue);
    });

    testWidgets('open(context, ...) navega (canPop=true) sin lanzar excepción',
        (WidgetTester tester) async {
      final AppManager m = _manager();

      await _pump(
        tester,
        manager: m,
        home: const TestPageBuilderPage(title: 'X'),
      );

      final BuildContext ctx = _ctxOf(tester);
      expect(m.pageManager.canPop, isFalse);

      // Llamada directa al helper estático
      TestPageBuilderPage.open(ctx, title: 'Repushed', content: 'pushed');
      await tester.pump();

      expect(m.pageManager.canPop, isTrue);
    });
  });
}
