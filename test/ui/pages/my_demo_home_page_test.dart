import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------------
/// Helpers de montaje
/// ----------------------

PageRegistry _dummyRegistry() {
  // No usamos Router en estos tests; un registry mínimo basta.
  final List<PageDef> defs = <PageDef>[
    PageDef(
      model: MyDemoHomePage.pageModel,
      builder: (_, __) => const MyDemoHomePage(title: 'Demo'),
    ),
  ];
  return PageRegistry.fromDefs(defs, defaultPage: MyDemoHomePage.pageModel);
}

AppManager _managerWithDefaults() {
  final PageRegistry registry = _dummyRegistry();
  final AppConfig cfg = AppConfig.dev(registry: registry);
  return AppManager(cfg);
}

Future<void> _pumpDemo(
  WidgetTester tester, {
  AppManager? manager,
}) async {
  final AppManager m = manager ?? _managerWithDefaults();

  await tester.pumpWidget(
    AppManagerProvider(
      appManager: m,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const MyDemoHomePage(title: 'Demo'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Abre el Drawer estándar expuesto por Scaffold/AppBar.
Future<void> _openDrawer(WidgetTester tester) async {
  final ScaffoldState sc = tester.state<ScaffoldState>(find.byType(Scaffold));
  sc.openDrawer();
  await tester.pumpAndSettle();
}

// Helper: busca la opción del menú por etiqueta
ModelMainMenuModel _menuOption(AppManager m, String label) {
  return m.mainMenu.items
      .firstWhere((ModelMainMenuModel e) => e.label == label);
}

/// ----------------------
/// TESTS
/// ----------------------

void main() {
  group('MyDemoHomePage + PageBuilder', () {
    testWidgets('contador inicia en 0 y aumenta a 1 al pulsar',
        (WidgetTester tester) async {
      await _pumpDemo(tester);

      expect(find.text('0'), findsOneWidget);

      await tester
          .tap(find.text('You have pushed the button this many times:'));
      await tester.pump(); // rebuild del StreamBuilder<int>

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('incremento inyecta opciones y el Drawer aparece',
        (WidgetTester tester) async {
      final AppManager m = _managerWithDefaults();
      await _pumpDemo(tester, manager: m);

      // Antes: no hay Drawer (sin items de menú)
      expect(find.byType(Drawer), findsNothing);

      // Incrementa → inyecta opciones
      await tester
          .tap(find.text('You have pushed the button this many times:'));
      await tester.pump();

      // Abre Drawer del shell (PageBuilder)
      await _openDrawer(tester);
      expect(find.byType(Drawer), findsOneWidget);

      // Las opciones inyectadas deben estar
      expect(find.text('Eliminame'), findsOneWidget);
      expect(find.text('Loading (auto)'), findsOneWidget);
      expect(find.text('Cambiar tema'), findsOneWidget);
      expect(find.text('Toast demo'), findsOneWidget);
    });

    testWidgets('tocar "Loading (auto)" muestra LoadingPage y luego desaparece',
        (WidgetTester tester) async {
      await _pumpDemo(tester);

      // Inyecta menú
      await tester
          .tap(find.text('You have pushed the button this many times:'));
      await tester.pump();

      await _openDrawer(tester);

      await tester.tap(find.text('Loading (auto)'));
      await tester.pump(); // muestra el loading

      expect(find.byType(LoadingPage), findsOneWidget);
      expect(find.textContaining('Cargando'), findsWidgets);

      // Termina la tarea falsa (2s) y se limpia
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(LoadingPage), findsNothing);
    });

    testWidgets('tocar "Toast demo" muestra/oculta el texto del toast',
        (WidgetTester tester) async {
      final AppManager m = _managerWithDefaults();
      await _pumpDemo(tester, manager: m);

      // 1) Inyecta las opciones (la demo las añade al pulsar el contador)
      await tester
          .tap(find.text('You have pushed the button this many times:'));
      await tester.pump(); // deja que se emitan las opciones al stream

      // 2) En vez de tap en el texto del Drawer, ejecutamos el callback del item
      _menuOption(m, 'Toast demo').onPressed(); // ➜ showToast('…')
      await tester.pump(); // procesa el frame

      // ✅ Estado actualizado inmediatamente (antes de que venza el debouncer)
      expect(
        m.notifications.msg.contains('mensaje de prueba para el toast'),
        isTrue,
      );

      // 3) Toggle a vacío (segunda pulsación)
      _menuOption(m, 'Toast demo').onPressed(); // ➜ showToast('')
      await tester.pump();

      expect(m.notifications.msg.isEmpty, isTrue);

      // (Opcional) si quieres además verificar auto-clear por debounce:
      _menuOption(m, 'Toast demo').onPressed(); // vuelve a poner el mensaje
      await tester.pump();
      expect(m.notifications.msg.isNotEmpty, isTrue);

      // deja vencer el timer (7s por defecto del Debouncer)
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();
      expect(m.notifications.msg.isEmpty, isTrue);
    });

    testWidgets('tocar "Eliminame" agrega opción secundaria (estado BLoC)',
        (WidgetTester tester) async {
      final AppManager m = _managerWithDefaults();
      await _pumpDemo(tester, manager: m);

      await tester
          .tap(find.text('You have pushed the button this many times:'));
      await tester.pump();

      await _openDrawer(tester);
      await tester.tap(find.text('Eliminame'));
      await tester.pump();

      // Aunque el secondary menu no se renderiza en PageBuilder,
      // validamos el efecto de negocio directamente en el BLoC:
      final bool addedSecondary = m.secondaryMenu.items
          .any((ModelMainMenuModel e) => e.label == 'Eliminame');

      expect(addedSecondary, isTrue);
    });

    testWidgets('tocar "Cambiar tema" elimina esa opción del menú',
        (WidgetTester tester) async {
      await _pumpDemo(tester);

      await tester
          .tap(find.text('You have pushed the button this many times:'));
      await tester.pump();

      await _openDrawer(tester);
      expect(find.text('Cambiar tema'), findsOneWidget);

      await tester.tap(find.text('Cambiar tema'));
      await tester.pump();

      // Reabrimos para refrescar la lista y verificar que se quitó
      await _openDrawer(tester);
      expect(find.text('Cambiar tema'), findsNothing);
    });
  });
}
