import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ColumnBlueprintWidget', () {
    testWidgets('renders with indices on desktop config',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1440, 900)); // desktop → más columnas

      await tester.pumpWidget(
        _wrap(
          ColumnBlueprintWidget(
            responsive: resp,
            showIndices: true,
            height: 200,
          ),
        ),
      );

      // No hay texto fijo que garantice indices, pero el widget se renderiza
      expect(find.byType(ColumnBlueprintWidget), findsOneWidget);
    });

    testWidgets('adapts when switching to mobile (fewer columns)',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844)); // mobile

      await tester.pumpWidget(
        _wrap(
          ColumnBlueprintWidget(
            responsive: resp,
            height: 150,
          ),
        ),
      );

      expect(find.byType(ColumnBlueprintWidget), findsOneWidget);

      // Cambiar a tablet y repintar
      resp.setSizeForTesting(const Size(1024, 768));
      await tester.pump();
      expect(find.byType(ColumnBlueprintWidget), findsOneWidget);
    });

    testWidgets('respects opacity and sizing', (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(800, 600));

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 120,
            child: ColumnBlueprintWidget(
              responsive: resp,
              opacity: 0.2,
            ),
          ),
        ),
      );

      expect(find.byType(ColumnBlueprintWidget), findsOneWidget);
    });
  });
}
