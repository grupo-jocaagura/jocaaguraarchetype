import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('SecondaryOptionWidget', () {
    testWidgets('renders and respects selected state',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1440, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SecondaryOptionWidget(
              icon: Icons.dashboard,
              label: 'Dashboard',
              responsive: resp,
              onPressed: () {},
              selected: true,
            ),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
    });

    testWidgets('handles disabled state', (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SecondaryOptionWidget(
              icon: Icons.delete,
              label: 'Delete',
              responsive: resp,
              onPressed: null,
            ),
          ),
        ),
      );

      final TextButton btn = tester.widget<TextButton>(find.byType(TextButton));
      expect(btn.onPressed, isNull);
    });
  });
}
