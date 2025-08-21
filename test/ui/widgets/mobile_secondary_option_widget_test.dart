import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('MobileSecondaryOptionWidget', () {
    testWidgets('renders icon + label and triggers onPressed',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844));
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: MobileSecondaryOptionWidget(
              icon: Icons.settings,
              label: 'Settings',
              responsive: resp,
              onPressed: () => tapped = true,
              tooltip: 'Open settings',
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(360, 780));

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: MobileSecondaryOptionWidget(
              icon: Icons.info,
              label: 'Info',
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
