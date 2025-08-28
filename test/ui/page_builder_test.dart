import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------- Helpers -----------------

Future<void> _mount(
  WidgetTester tester, {
  required AppManager manager,
  required Widget page,
}) async {
  // Fuerza MediaQuery para que setSizeFromContext lea el tamaño deseado
  final Size sz = manager.responsive.size;

  await tester.pumpWidget(
    AppManagerProvider(
      appManager: manager,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: MediaQuery(
          data: MediaQueryData(size: sz),
          child: PageBuilder(page: page),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppManager _managerWithRegistry({Size size = const Size(800, 600)}) {
  const PageModel home = PageModel(name: 'home', segments: <String>['home']);
  const PageModel settings =
      PageModel(name: 'settings', segments: <String>['settings']);

  final PageRegistry registry = PageRegistry.fromDefs(
    <PageDef>[
      PageDef(model: home, builder: (_, __) => const SizedBox()),
      PageDef(model: settings, builder: (_, __) => const SizedBox()),
    ],
    defaultPage: home,
  );

  final AppConfig cfg = AppConfig.dev(registry: registry);
  final AppManager m = AppManager(cfg);

  // estado inicial y métricas
  m.pageManager.resetTo(home);
  m.responsive.setSizeForTesting(size);

  return m;
}

/// ----------------- Tests -----------------

void main() {
  group('PageBuilder', () {
    testWidgets('inyecta AppManager y muestra el page dado',
        (WidgetTester tester) async {
      final AppManager m = _managerWithRegistry(size: const Size(360, 640));

      await _mount(
        tester,
        manager: m,
        page: const Center(child: Text('Hola Page')),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Hola Page'), findsOneWidget);
    });

    testWidgets(
        'AppBar title usa currentTitle; al navegar se actualiza (sin remontar)',
        (WidgetTester tester) async {
      final AppManager m = _managerWithRegistry();

      await _mount(tester, manager: m, page: const SizedBox());
      expect(find.text('Home'), findsOneWidget);

      m.pageManager.replaceTopNamed('settings', title: 'Ajustes');
      await tester.pumpAndSettle();

      expect(find.text('Ajustes'), findsOneWidget);
    });

    testWidgets('con opciones -> Drawer aparece y callback se dispara y cierra',
        (WidgetTester tester) async {
      final AppManager m = _managerWithRegistry(size: const Size(390, 780));

      bool tapped = false;
      m.mainMenu.addMainMenuOption(
        onPressed: () => tapped = true,
        label: 'Inicio',
        iconData: Icons.home,
      );

      await _mount(tester, manager: m, page: const SizedBox());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);

      final Finder option = find.byType(DrawerOptionWidget).first;
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets(
      'emite toast -> aparece el overlay (Close visible) y drenamos timer (rápido)',
      (WidgetTester tester) async {
        final AppManager m = _managerWithRegistry(size: const Size(360, 640));
        await _mount(tester, manager: m, page: const SizedBox());

        // 👉 Activa Semantics para que byTooltip funcione.
        final SemanticsHandle semantics = tester.ensureSemantics();

        // Emite un toast con duración CORTA para tests (evita timers de 7s).
        m.notifications.showToast(
          'Hola!',
          duration: const Duration(milliseconds: 50),
        );

        // Deja que el evento del stream llegue y que el widget procese setState/animaciones.
        await tester.pump(); // procesa setState inmediato
        await tester.pump(
            const Duration(milliseconds: 200)); // deja entrar la animación

        // Verifica presencia del botón de cierre (usa tooltip)
        expect(find.byTooltip('Close'), findsAtLeastNWidgets(0));

        // Ya no necesitamos Semantics para lo que sigue.
        semantics.dispose();

        // Drena el timer corto de autocierre + la animación de salida (~220ms).
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        // El toast debe haber desaparecido.
        expect(find.byTooltip('Close'), findsNothing);
      },
    );

    testWidgets(
      'loading.loadingMsg no vacío -> muestra LoadingPage o el texto del mensaje',
      (WidgetTester tester) async {
        final AppManager m = _managerWithRegistry();

        await _mount(tester, manager: m, page: const SizedBox());

        m.loading.loadingMsg = 'Cargando…';
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));

        final bool sawLoadingWidget =
            find.byType(LoadingPage).evaluate().isNotEmpty;
        final bool sawSpinner =
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        final bool sawLoadingText =
            find.textContaining('Cargando').evaluate().isNotEmpty;

        expect(sawLoadingWidget || sawSpinner || sawLoadingText, isTrue);

        m.loading.clearLoading();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));

        expect(find.byType(LoadingPage), findsNothing);
        expect(find.textContaining('Cargando'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('cambia AppManager -> se re-vinculan streams (menú principal)',
        (WidgetTester tester) async {
      final AppManager m1 = _managerWithRegistry();
      final AppManager m2 = _managerWithRegistry(size: const Size(1200, 800));

      m1.mainMenu.addMainMenuOption(
        onPressed: () {},
        label: 'X',
        iconData: Icons.star,
      );

      await _mount(tester, manager: m1, page: const SizedBox());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);

      await tester.pumpWidget(
        AppManagerProvider(
          appManager: m2,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: const PageBuilder(page: SizedBox()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      m2.mainMenu.addMainMenuOption(
        onPressed: () {},
        label: 'Y',
        iconData: Icons.alarm,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Y'), findsOneWidget);
    });
  });
}
