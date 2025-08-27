import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------- Helpers -----------------

Future<void> _mount(
  WidgetTester tester, {
  required AppManager manager,
  required Widget page,
}) async {
  await tester.pumpWidget(
    AppManagerProvider(
      appManager: manager,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: PageBuilder(page: page),
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
      // Título inicial basado en 'home'
      expect(find.text('Home'), findsOneWidget);

      // Cambiamos la página; PageBuilder debe escuchar el stream y refrescar
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

      // Abre el Drawer desde el AppBar (Material 3 usa este tooltip)
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      // Drawer visible
      expect(find.byType(Drawer), findsOneWidget);

      // Tocar la primera opción (el onTap hace maybePop() → se cierra)
      final Finder option = find.byType(DrawerOptionWidget).first;
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets(
        'emite toast -> aparece el overlay (Semantics Notification) y drenamos timer',
        (WidgetTester tester) async {
      final AppManager m = _managerWithRegistry(size: const Size(360, 640));

      await _mount(tester, manager: m, page: const SizedBox());

      m.notifications.showToast('Hola!');

      // tiempo para que:
      //  - el stream llegue al snack
      //  - la animación (slide+opacity) se aplique
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pump(const Duration(milliseconds: 250));

      // Verificamos el Semantics del toast (el texto puede variar de estilo)
      expect(find.bySemanticsLabel('Notification'), findsOneWidget);

      // Drenamos el Debouncer por defecto (~7s) para que no queden timers pendientes
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'loading.loadingMsg no vacío -> muestra LoadingPage o el texto del mensaje',
      (WidgetTester tester) async {
        final AppManager m = _managerWithRegistry();

        await _mount(tester, manager: m, page: const SizedBox());

        m.loading.loadingMsg = 'Cargando…';
        await tester.pump(); // dispara el rebuild del StreamBuilder
        await tester.pump(const Duration(milliseconds: 1)); // asegura el frame

        final bool sawLoadingWidget =
            find.byType(LoadingPage).evaluate().isNotEmpty;
        final bool sawSpinner =
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        final bool sawLoadingText =
            find.textContaining('Cargando').evaluate().isNotEmpty;

        expect(sawLoadingWidget || sawSpinner || sawLoadingText, isTrue);

        // Limpia y verifica que desaparece
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

      // Asegura que exista Drawer en el manager inicial
      m1.mainMenu.addMainMenuOption(
        onPressed: () {},
        label: 'X',
        iconData: Icons.star,
      );

      await _mount(tester, manager: m1, page: const SizedBox());

      // Abrimos y cerramos para confirmar wiring con m1
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      await tester.tap(find.text('X')); // tap por label es más estable
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);

      // Cambiamos de provider (nuevo AppManager)
      await tester.pumpWidget(
        AppManagerProvider(
          appManager: m2,
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const PageBuilder(page: SizedBox()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Añadimos opción al nuevo manager y verificamos que aparece
      m2.mainMenu.addMainMenuOption(
        onPressed: () {},
        label: 'Y',
        iconData: Icons.alarm,
      );
      await tester.pumpAndSettle(); // deja que el StreamBuilder se reconstruya

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Y'), findsOneWidget);
    });
  });
}
