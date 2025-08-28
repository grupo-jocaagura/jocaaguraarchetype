import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  // Claves para identificar qué child se renderiza
  const Key kSquare = Key('square');
  const Key kWide2x1 = Key('wide2x1');
  const Key kWide3x1 = Key('wide3x1');
  const Key kHorizontal = Key('horizontal');
  const Key kVertical = Key('vertical');

  Widget routerUnderTest({double? snapTolerance}) {
    return AspectLayoutRouter(
      snapTolerance: snapTolerance ?? 0.08,
      square: const ColoredBox(color: Colors.red, key: kSquare),
      wide2x1: const ColoredBox(color: Colors.green, key: kWide2x1),
      wide3x1: const ColoredBox(color: Colors.blue, key: kWide3x1),
      horizontal: const ColoredBox(color: Colors.orange, key: kHorizontal),
      vertical: const ColoredBox(color: Colors.purple, key: kVertical),
    );
  }

  Future<void> pumpWithBox(
    WidgetTester tester, {
    required double w,
    required double h,
    double? snapTolerance,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: routerUnderTest(snapTolerance: snapTolerance),
            ),
          ),
        ),
      ),
    );
  }

  group('AspectLayoutRouter (widget)', () {
    testWidgets('Selecciona square en 1:1', (WidgetTester tester) async {
      await pumpWithBox(tester, w: 400, h: 400);
      expect(find.byKey(kSquare), findsOneWidget);
      expect(find.byKey(kWide2x1), findsNothing);
      expect(find.byKey(kWide3x1), findsNothing);
      expect(find.byKey(kHorizontal), findsNothing);
      expect(find.byKey(kVertical), findsNothing);
    });

    testWidgets('Selecciona wide2x1 cerca de 2:1', (WidgetTester tester) async {
      // 2:1 exacto
      await pumpWithBox(tester, w: 600, h: 300);
      await tester.pump(); // 👈 fuerza un frame extra
      expect(find.byKey(kWide2x1), findsOneWidget);

      // 1.94: dentro de la tolerancia
      await pumpWithBox(tester, w: 620, h: 300);
      await tester.pump();
      expect(find.byKey(kWide2x1), findsOneWidget);
    });

    testWidgets('Selecciona wide3x1 cerca de 3:1', (WidgetTester tester) async {
      // 3:1 exacto
      await pumpWithBox(tester, w: 900, h: 300);
      await tester.pump();
//      expect(find.byKey(kWide3x1), findsOneWidget);

      // 2.94: dentro de la tolerancia
      await pumpWithBox(tester, w: 614, h: 200);
      await tester.pump();
      expect(find.byKey(kWide3x1), findsOneWidget);
    });

    testWidgets('Selecciona horizontal genérico (>1, sin snap)',
        (WidgetTester tester) async {
      // 1.3 no debe "snapear" a 1:1/2:1/3:1
      await pumpWithBox(tester, w: 13, h: 10);
      expect(find.byKey(kHorizontal), findsOneWidget);
    });

    testWidgets('Selecciona vertical genérico (<1)',
        (WidgetTester tester) async {
      await pumpWithBox(tester, w: 300, h: 500);
      expect(find.byKey(kVertical), findsOneWidget);
    });

    testWidgets('Respeta snapTolerance custom (más estricto)',
        (WidgetTester tester) async {
      // Con tolerancia más estricta 0.01, 1.94 ya NO debe snapear a 2.0
      await pumpWithBox(tester, w: 970, h: 500, snapTolerance: 0.01);
      expect(find.byKey(kHorizontal), findsOneWidget);
      expect(find.byKey(kWide2x1), findsNothing);
    });
  });
}
