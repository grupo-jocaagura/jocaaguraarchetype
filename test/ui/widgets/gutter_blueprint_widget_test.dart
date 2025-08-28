import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('GutterBlueprintWidget', () {
    testWidgets('uses responsive.gutterWidth as thickness (vertical)',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1280, 800)); // desktop → gutter wider

      await tester.pumpWidget(
        _wrap(
          GutterBlueprintWidget(
            responsive: resp,
            extent: 120,
          ),
        ),
      );

      final SizedBox box = tester.widget(find.byType(SizedBox)) as SizedBox;
      expect(box.width, equals(resp.gutterWidth));
      expect(box.height, equals(120));
    });

    testWidgets('adapts thickness on mobile (horizontal)',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(
          const Size(390, 844),
        ); // mobile → potentially different gutter

      await tester.pumpWidget(
        _wrap(
          GutterBlueprintWidget(
            responsive: resp,
            axis: Axis.horizontal,
            extent: 200,
          ),
        ),
      );

      final SizedBox box = tester.widget(find.byType(SizedBox)) as SizedBox;
      expect(box.height, equals(resp.gutterWidth));
      expect(box.width, equals(200));
    });
  });
}
