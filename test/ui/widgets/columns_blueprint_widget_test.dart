import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ColumnsBlueprintWidget', () {
    testWidgets('renders children and respects spans (desktop)',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1440, 900)); // desktop → más columnas

      await tester.pumpWidget(
        _wrap(
          ColumnsBlueprintWidget(
            responsive: resp,
            children: const <ColumnSlot>[
              ColumnSlot(span: 2, child: Text('A')),
              ColumnSlot(span: 6, child: Text('B')),
              ColumnSlot(span: 2, child: Text('C')),
            ],
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('clamps spans when exceeding grid',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768)); // tablet

      await tester.pumpWidget(
        _wrap(
          ColumnsBlueprintWidget(
            responsive: resp,
            children: const <ColumnSlot>[
              ColumnSlot(span: 8, child: Text('Left')),
              ColumnSlot(span: 8, child: Text('Right')), // will clamp/trim
            ],
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('uses custom gap and shows guides',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(800, 600));

      await tester.pumpWidget(
        _wrap(
          ColumnsBlueprintWidget(
            responsive: resp,
            children: const <ColumnSlot>[
              ColumnSlot(span: 3, child: Text('X')),
              ColumnSlot(span: 3, child: Text('Y')),
            ],
            gapOverride: 24.0,
            showGuides: true,
            backgroundColor: Colors.white,
          ),
        ),
      );

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
    });

    testWidgets('works on mobile with SafeArea', (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844)); // mobile

      await tester.pumpWidget(
        _wrap(
          ColumnsBlueprintWidget(
            responsive: resp,
            children: const <ColumnSlot>[
              ColumnSlot(span: 2, child: Text('One')),
              ColumnSlot(span: 2, child: Text('Two')),
            ],
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });
  });
}
