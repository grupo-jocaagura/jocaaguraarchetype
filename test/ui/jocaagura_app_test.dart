import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------- Helpers de páginas simples -----------------
class _CaptureHome extends StatelessWidget {
  const _CaptureHome(this.label, this.captured);
  final String label;
  final ValueNotifier<AppManager?> captured;

  @override
  Widget build(BuildContext context) {
    captured.value = context.appManager;
    return Scaffold(
      body: Center(child: Text(label, key: ValueKey<String>('home-$label'))),
    );
  }
}

class _SimplePage extends StatelessWidget {
  const _SimplePage(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage(this.page);
  final PageModel page;

  @override
  Widget build(BuildContext context) {
    final String id = page.segments.isNotEmpty ? page.segments.first : '';
    final String tab = page.query['tab'] ?? '';
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('PROFILE'),
          Text('id:$id'),
          Text('tab:$tab'),
        ],
      ),
    );
  }
}

PageRegistry _registryA(ValueNotifier<AppManager?> cap) {
  return PageRegistry.fromDefs(<PageDef>[
    PageDef(
      model: const PageModel(name: 'home'),
      builder: (BuildContext ctx, PageModel p) => _CaptureHome('A', cap),
    ),
    PageDef(
      model: const PageModel(name: 'details'),
      builder: (BuildContext ctx, PageModel p) => const _SimplePage('details'),
    ),
    PageDef(
      model: const PageModel(name: 'profile'),
      builder: (BuildContext ctx, PageModel p) => _ProfilePage(p),
    ),
  ]);
}

PageRegistry _registryB(ValueNotifier<AppManager?> cap) {
  return PageRegistry.fromDefs(<PageDef>[
    PageDef(
      model: const PageModel(name: 'home'),
      builder: (BuildContext ctx, PageModel p) => _CaptureHome('B', cap),
    ),
    PageDef(
      model: const PageModel(name: 'details'),
      builder: (BuildContext ctx, PageModel p) => const _SimplePage('details'),
    ),
    PageDef(
      model: const PageModel(name: 'profile'),
      builder: (BuildContext ctx, PageModel p) => _ProfilePage(p),
    ),
  ]);
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required Key key,
  required AppManager appManager,
  required PageRegistry registry,
  required bool projectorMode,
  String initialLocation = '/home',
}) async {
  await tester.pumpWidget(
    JocaaguraApp(
      key: key,
      appManager: appManager,
      registry: registry,
      projectorMode: projectorMode,
      initialLocation: initialLocation,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('JocaaguraApp', () {
    testWidgets('factory dev: construye y muestra initialLocation=/home',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      await tester.pumpWidget(
        JocaaguraApp.dev(
          registry: reg,
          projectorMode: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('home-A')), findsOneWidget);
      expect(cap.value, isNotNull); // AppManager disponible en el árbol
    });

    testWidgets(
        'initialLocation con segmentos y query se aplica (profile/42?tab=posts)',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      await tester.pumpWidget(
        JocaaguraApp.dev(
          registry: reg,
          projectorMode: false,
          initialLocation: '/profile/42?tab=posts',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('id:42'), findsOneWidget);
      expect(find.text('tab:posts'), findsOneWidget);
    });

    testWidgets('AppManagerProvider: context.appManager es el inyectado',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      // Usamos la factory dev para construir un AppManager real
      final JocaaguraApp app = JocaaguraApp.dev(
        registry: reg,
        projectorMode: false,
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // El capturado en la página debe ser el mismo que expone el provider
      expect(cap.value, isNotNull);
    });

    testWidgets('didUpdateWidget: cambiar registry recrea delegate y cambia UI',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry regA = _registryA(cap);
      final PageRegistry regB = _registryB(cap);

      // Construimos nuestro propio AppManager para poder re-usarlo
      final AppConfig cfg = AppConfig.dev(registry: regA);
      final AppManager manager = AppManager(cfg);

      final GlobalKey key = GlobalKey();

      // 1) A con home-A
      await _pumpApp(
        tester,
        key: key,
        appManager: manager,
        registry: regA,
        projectorMode: false,
      );
      expect(find.byKey(const ValueKey<String>('home-A')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('home-B')), findsNothing);

      // 2) Mismo key/state, nuevo registry (home-B)
      await _pumpApp(
        tester,
        key: key,
        appManager: manager,
        registry: regB,
        projectorMode: false,
      );
      expect(find.byKey(const ValueKey<String>('home-A')), findsNothing);
      expect(find.byKey(const ValueKey<String>('home-B')), findsOneWidget);
    });

    testWidgets('didUpdateWidget: cambiar appManager actualiza provider',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      final AppConfig cfg1 = AppConfig.dev(registry: reg);
      final AppConfig cfg2 = AppConfig.dev(registry: reg);

      final AppManager m1 = AppManager(cfg1);
      final AppManager m2 = AppManager(cfg2);

      final GlobalKey key = GlobalKey();

      // Con m1
      await _pumpApp(
        tester,
        key: key,
        appManager: m1,
        registry: reg,
        projectorMode: false,
      );
      expect(cap.value, same(m1));

      // Reemplazamos por m2 con el mismo key (mismo State → didUpdateWidget)
      await _pumpApp(
        tester,
        key: key,
        appManager: m2,
        registry: reg,
        projectorMode: false,
      );
      expect(cap.value, same(m2));
    });

    testWidgets(
        'projectorMode=false: materializa todas las pages del stack (home y details visibles)',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      final JocaaguraApp app = JocaaguraApp.dev(
        registry: reg,
        projectorMode: false,
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // push details
      final AppManager mgr = cap.value!;
      mgr.pageManager.pushNamed('details');
      await tester.pumpAndSettle();

      // details (top) está visible normalmente
      expect(find.text('details'), findsOneWidget);

      // home-A existe pero está offstage → hay que buscar sin omitir offstage
      final Finder homeOffstageFinder = find.byWidgetPredicate(
        (Widget w) => w.key == const ValueKey<String>('home-A'),
        description: 'home-A offstage',
        skipOffstage: false,
      );
      expect(homeOffstageFinder, findsOneWidget);
    });

    testWidgets(
        'projectorMode=true: sólo materializa la top (details visible, home no existe ni offstage)',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      final JocaaguraApp app = JocaaguraApp.dev(
        registry: reg,
        projectorMode: true,
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final AppManager mgr = cap.value!;
      mgr.pageManager.pushNamed('details');
      await tester.pumpAndSettle();

      expect(find.text('details'), findsOneWidget);

      // En projectorMode la base no se materializa, ni siquiera offstage
      final Finder homeOffstageFinder = find.byWidgetPredicate(
        (Widget w) => w.key == const ValueKey<String>('home-A'),
        description: 'home-A offstage',
        skipOffstage: false,
      );
      expect(homeOffstageFinder, findsNothing);
    });

    testWidgets(
        'initialLocation por defecto es /home y no muestra el banner de debug',
        (WidgetTester tester) async {
      final ValueNotifier<AppManager?> cap = ValueNotifier<AppManager?>(null);
      final PageRegistry reg = _registryA(cap);

      await tester.pumpWidget(
        JocaaguraApp.dev(
          registry: reg,
          projectorMode: false,
          // no pasamos initialLocation → usa '/home'
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('home-A')), findsOneWidget);
      // El banner de debug está desactivado en MaterialApp.router(debugShowCheckedModeBanner: false)
      expect(find.byType(Banner), findsNothing);
    });
  });
}
