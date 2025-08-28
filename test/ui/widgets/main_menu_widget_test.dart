import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

BlocResponsive _desktopResp() {
  final BlocResponsive r = BlocResponsive();
  r.setSizeForTesting(const Size(1200, 800)); // fuerza desktop
  return r;
}

BlocResponsive _mobileResp() {
  final BlocResponsive r = BlocResponsive();
  r.setSizeForTesting(const Size(360, 720)); // fuerza mobile
  return r;
}

List<MainMenuItem> _items() => const <MainMenuItem>[
      MainMenuItem(id: 'home', label: 'Home', icon: Icons.home),
      MainMenuItem(id: 'dash', label: 'Dashboard', icon: Icons.dashboard),
      MainMenuItem(id: 'settings', label: 'Settings', icon: Icons.settings),
    ];

Future<void> _pumpMenu(
  WidgetTester tester, {
  required BlocResponsive r,
  Axis axis = Axis.vertical,
  String? selectedId,
  bool? collapsed,
  bool autoCollapse = true,
  int? maxWidthColumns,
  bool safeArea = true,
  String? semanticsLabel,
  Color? background,
  EdgeInsets? padding,
  ValueChanged<String>? onSelect,
  List<MainMenuItem>? items,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: MediaQuery(
        data: MediaQueryData(
          size: r.size,
        ), // << clave: coincide con r.setSizeForTesting
        child: Scaffold(
          body: MainMenuWidget(
            responsive: r,
            items: items ?? _items(),
            selectedId: selectedId,
            onSelect: onSelect,
            axis: axis,
            collapsed: collapsed,
            autoCollapse: autoCollapse,
            maxWidthColumns: maxWidthColumns,
            safeArea: safeArea,
            semanticLabel: semanticsLabel,
            backgroundColor: background,
            padding: padding,
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('MainMenuWidget', () {
    testWidgets('vertical full: muestra labels y dispara onSelect',
        (WidgetTester tester) async {
      String? tapped;
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        collapsed: false,
        onSelect: (String id) => tapped = id,
      );

      // Labels visibles en modo "full"
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(tapped, 'dash');
    });

    testWidgets('vertical: item disabled NO dispara onSelect',
        (WidgetTester tester) async {
      String? tapped;
      final List<MainMenuItem> items = <MainMenuItem>[
        const MainMenuItem(id: 'home', label: 'Home', icon: Icons.home),
        const MainMenuItem(
          id: 'blocked',
          label: 'Blocked',
          icon: Icons.block,
          enabled: false,
        ),
      ];
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        items: items,
        collapsed: false,
        onSelect: (String id) => tapped = id,
      );

      await tester.tap(find.text('Blocked'));
      await tester.pumpAndSettle();
      expect(tapped, isNull, reason: 'item deshabilitado no debería tapearse');
    });

    testWidgets(
        'vertical colapsado (forzado): oculta labels y muestra tooltips',
        (WidgetTester tester) async {
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        collapsed: true, // fuerza rail icon-only
      );

      // En colapsado no deben renderizarse los textos de las opciones
      expect(find.text('Home'), findsNothing);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Settings'), findsNothing);

      // Pero sí iconos con Tooltips (al menos uno)
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets(
        'vertical: autoCollapse cuando maxWidthColumns<=1 (manteniendo desktop)',
        (WidgetTester tester) async {
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        maxWidthColumns: 1, // → colapsa automáticamente
        // autoCollapse = true por defecto
      );
      expect(find.text('Home'), findsNothing);
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('vertical: autoCollapse por isMobile aunque maxWidthColumns>1',
        (WidgetTester tester) async {
      await _pumpMenu(
        tester,
        r: _mobileResp(), // móvil → responsive.isMobile = true
        maxWidthColumns: 3,
      );
      expect(find.text('Home'), findsNothing);
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('horizontal (top bar): usa scroll horizontal y muestra labels',
        (WidgetTester tester) async {
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        axis: Axis.horizontal,
      );

      final Finder scroller = find.byWidgetPredicate(
        (Widget w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      );
      expect(scroller, findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('semanticsLabel se aplica al contenedor',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await _pumpMenu(
        tester,
        r: _desktopResp(),
        semanticsLabel: 'Main navigation',
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Main navigation'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('safeArea: true envuelve, false no',
        (WidgetTester tester) async {
      await _pumpMenu(tester, r: _desktopResp());
      expect(find.byType(SafeArea), findsOneWidget);

      await _pumpMenu(tester, r: _desktopResp(), safeArea: false);
      expect(find.byType(SafeArea), findsNothing);
    });

    testWidgets('backgroundColor y padding se aplican al contenedor',
        (WidgetTester tester) async {
      const Color bg = Colors.teal;
      const EdgeInsets pad = EdgeInsets.all(24);
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        background: bg,
        padding: pad,
      );

      final bool hasBg = find
          .byWidgetPredicate(
            (Widget w) =>
                (w is ColoredBox && w.color == bg) ||
                (w is DecoratedBox &&
                    w.decoration is BoxDecoration &&
                    (w.decoration as BoxDecoration).color == bg),
          )
          .evaluate()
          .isNotEmpty;
      expect(hasBg, isTrue);

      // Hay un Padding con esos insets
      final bool hasPadding = find
          .byWidgetPredicate((Widget w) => w is Padding && w.padding == pad)
          .evaluate()
          .isNotEmpty;
      expect(hasPadding, isTrue);
    });

    testWidgets(
        'vertical: respeta maxWidthColumns con ConstrainedBox(maxWidth)',
        (WidgetTester tester) async {
      final BlocResponsive r = _desktopResp();
      const int maxCols = 3;

      await _pumpMenu(
        tester,
        r: r,
        maxWidthColumns: maxCols,
        collapsed: false,
      );

      final double expected =
          r.widthByColumns(maxCols.clamp(1, r.columnsNumber));

      // Cada opción en vertical se encapsula en ConstrainedBox(maxWidth: maxW)
      final Iterable<Element> cb =
          find.byType(ConstrainedBox).evaluate().where((Element e) {
        final ConstrainedBox w = e.widget as ConstrainedBox;
        return (w.constraints.maxWidth - expected).abs() < 0.01;
      });

      expect(
        cb.isNotEmpty,
        isTrue,
        reason: 'Debe existir un ConstrainedBox con maxWidth=$expected',
      );
    });

    testWidgets('onSelect se propaga con item seleccionado inicial',
        (WidgetTester tester) async {
      String? tapped;
      await _pumpMenu(
        tester,
        r: _desktopResp(),
        selectedId: 'dash',
        onSelect: (String id) => tapped = id,
        collapsed: false,
      );

      // Tocar el ya seleccionado vuelve a enviar el id (contrato simple)
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(tapped, 'dash');
    });
  });
}
