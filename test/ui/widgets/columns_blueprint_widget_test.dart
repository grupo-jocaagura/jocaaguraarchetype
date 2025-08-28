import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ---------- helpers ----------

Future<void> _pump(
  WidgetTester tester, {
  required BlocResponsive r,
  required List<ColumnSlot> children,
  MainAxisAlignment main = MainAxisAlignment.start,
  CrossAxisAlignment cross = CrossAxisAlignment.center,
  double? gap,
  Color? bg,
  bool showGuides = false,
  bool safeArea = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: ColumnsBlueprintWidget(
          responsive: r,
          children: children,
          mainAxisAlignment: main,
          crossAxisAlignment: cross,
          gapOverride: gap,
          backgroundColor: bg,
          showGuides: showGuides,
          safeArea: safeArea,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _widthOf(WidgetTester t, Key key) => t.getSize(find.byKey(key)).width;

/// ---------- tests ----------

void main() {
  group('ColumnsBlueprintWidget', () {
    testWidgets('asigna anchos por span y respeta gapOverride',
        (WidgetTester tester) async {
      final BlocResponsive r = BlocResponsive();

      const Key kA = Key('slotA');
      const Key kB = Key('slotB');

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 2, child: SizedBox(key: kA)),
          ColumnSlot(span: 3, child: SizedBox(key: kB)),
        ],
        gap: 20,
      );

      final int total = r.columnsNumber;
      final int grantA = 2.clamp(1, total);
      final int remain = total - grantA;
      final int grantB = 3.clamp(1, remain);

      expect(_widthOf(tester, kA), closeTo(r.widthByColumns(grantA), 0.001));
      expect(_widthOf(tester, kB), closeTo(r.widthByColumns(grantB), 0.001));

      final int gaps = find
          .byWidgetPredicate(
            (Widget w) => w is SizedBox && (w.width ?? -1) == 20,
          )
          .evaluate()
          .length;
      expect(gaps, 1);
    });

    testWidgets('si los spans exceden las columnas, los extra se recortan a 0',
        (WidgetTester tester) async {
      final BlocResponsive r = BlocResponsive();

      const Key kA = Key('wide');
      const Key kB = Key('trimmed');

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          // primer slot pide todas las columnas disponibles
          ColumnSlot(span: 9999, child: SizedBox(key: kA)),
          // este ya no debería recibir ancho → 0 px
          ColumnSlot(span: 2, child: SizedBox(key: kB)),
        ],
      );

      // Validamos el comportamiento esencial: el 2º queda en 0
      expect(_widthOf(tester, kB), 0.0);

      // Y que el 1º tiene ancho positivo (no nos casamos con un número exacto)
      expect(_widthOf(tester, kA), greaterThan(0.0));
    });

    testWidgets('showGuides=true dibuja 2*cols-1 franjas',
        (WidgetTester tester) async {
      final BlocResponsive r = BlocResponsive();

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 1, child: SizedBox.shrink()),
        ],
        showGuides: true,
      );

      final int cols = r.columnsNumber;

      final Finder overlay = find.byWidgetPredicate(
        (Widget w) => w is IgnorePointer && w.child is Row,
      );

      final int stripes = find
          .descendant(of: overlay, matching: find.byType(SizedBox))
          .evaluate()
          .length;

      expect(stripes, cols * 2 - 1);
    });

    testWidgets('safeArea:true envuelve en SafeArea; false no lo hace',
        (WidgetTester tester) async {
      final BlocResponsive r = BlocResponsive();

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 1, child: SizedBox()),
        ],
      );
      expect(find.byType(SafeArea), findsOneWidget);

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 1, child: SizedBox()),
        ],
        safeArea: false,
      );
      expect(find.byType(SafeArea), findsNothing);
    });

    testWidgets('aplica backgroundColor en el contenedor externo',
        (WidgetTester tester) async {
      final BlocResponsive r = BlocResponsive();
      const Color bg = Colors.orange;

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 1, child: SizedBox()),
        ],
        bg: bg,
      );

      // Container(color) puede materializarse como ColoredBox o DecoratedBox
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
    });

    testWidgets('mainAxisAlignment.center desplaza contenido respecto a start',
        (WidgetTester tester) async {
      final BlocResponsive r = BlocResponsive();

      const Key k = Key('first');

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 1, child: SizedBox(key: k)),
          ColumnSlot(span: 1, child: SizedBox()),
        ],
      );
      final double dxStart = tester.getTopLeft(find.byKey(k)).dx;

      await _pump(
        tester,
        r: r,
        children: const <ColumnSlot>[
          ColumnSlot(span: 1, child: SizedBox(key: k)),
          ColumnSlot(span: 1, child: SizedBox()),
        ],
        main: MainAxisAlignment.center,
      );
      final double dxCenter = tester.getTopLeft(find.byKey(k)).dx;

      expect(dxCenter, greaterThan(dxStart));
    });
  });
}
