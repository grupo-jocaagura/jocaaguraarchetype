import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('MobileSecondaryMenuWidget', () {
    testWidgets('renders items and toggles visibility',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844));
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: <Widget>[
                const ColoredBox(color: Colors.black12),
                MobileSecondaryMenuWidget(
                  responsive: resp,
                  items: <SecondaryMenuItem>[
                    SecondaryMenuItem(
                      Icons.home,
                      'Home',
                      onTap: () => tapped = true,
                    ),
                    SecondaryMenuItem(Icons.search, 'Search', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Toggle visibility (rebuild)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: <Widget>[
                const ColoredBox(color: Colors.black12),
                MobileSecondaryMenuWidget(
                  responsive: resp,
                  visible: false,
                  items: const <SecondaryMenuItem>[],
                ),
              ],
            ),
          ),
        ),
      );
      await tester
          .pump(const Duration(milliseconds: 250)); // complete animation
      expect(find.byType(MobileSecondaryOptionWidget), findsNothing);
    });
  });
}
