import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ResponsiveGeneratorWidget', () {
    late BlocResponsive responsive;

    setUp(() {
      responsive = BlocResponsive();
      responsive.setSize(const Size(1200, 900));
    });

    testWidgets('builds items with spans clamped to columns',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveGeneratorWidget(
              responsive: responsive,
              itemCount: 3,
              spanForIndex: (int i, BlocResponsive r) => r.columnsNumber + 10,
              itemBuilder: (BuildContext context, int index, BlocResponsive r) {
                return Text('Item $index ${r.columnsNumber}');
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('Item 0'), findsOneWidget);
      expect(find.textContaining('${responsive.columnsNumber}'), findsWidgets);
    });

    testWidgets('applies custom gap and padding overrides',
        (WidgetTester tester) async {
      const double gap = 32;
      const EdgeInsets padding = EdgeInsets.all(10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveGeneratorWidget(
              responsive: responsive,
              itemCount: 1,
              gapOverride: gap,
              padding: padding,
              itemBuilder: (_, __, ___) => const SizedBox(height: 20),
              spanForIndex: (_, __) => 1,
            ),
          ),
        ),
      );

      final Padding paddingWidget = tester.widget(find.byType(Padding));
      expect(paddingWidget.padding, padding);
      final Wrap wrap = tester.widget(find.byType(Wrap));
      expect(wrap.spacing, gap);
      expect(wrap.runSpacing, gap);
    });
  });
}
