import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MainMenuWidget', () {
    testWidgets('vertical full mode renders labels and triggers onSelect',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1280, 800));
      String? selected;

      await tester.pumpWidget(
        _wrap(
          MainMenuWidget(
            responsive: resp,
            items: const <MainMenuItem>[
              MainMenuItem(id: 'home', label: 'Home', icon: Icons.home),
              MainMenuItem(
                id: 'dash',
                label: 'Dashboard',
                icon: Icons.dashboard,
              ),
            ],
            selectedId: 'home',
            onSelect: (String id) => selected = id,
            maxWidthColumns: 3,
            autoCollapse: false,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(selected, equals('dash'));
    });

    testWidgets('vertical collapsed renders icon-only with tooltip',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768));

      await tester.pumpWidget(
        _wrap(
          MainMenuWidget(
            responsive: resp,
            items: const <MainMenuItem>[
              MainMenuItem(id: 'a', label: 'A', icon: Icons.star, tooltip: 'A'),
              MainMenuItem(
                id: 'b',
                label: 'B',
                icon: Icons.settings,
                tooltip: 'B',
              ),
            ],
            selectedId: 'a',
            collapsed: true, // force collapsed
            autoCollapse: false, // ensure it's collapsed by flag, not size
          ),
        ),
      );

      // Labels should not be visible in collapsed mode
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsNothing);

      // Icons are present
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('horizontal bar scrolls when overflowed and triggers onSelect',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(800, 600));
      String? selected;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 80,
            child: MainMenuWidget(
              responsive: resp,
              axis: Axis.horizontal,
              items: const <MainMenuItem>[
                MainMenuItem(id: 'one', label: 'One', icon: Icons.looks_one),
                MainMenuItem(id: 'two', label: 'Two', icon: Icons.looks_two),
                MainMenuItem(id: 'thr', label: 'Three', icon: Icons.looks_3),
                MainMenuItem(id: 'fou', label: 'Four', icon: Icons.looks_4),
              ],
              onSelect: (String id) => selected = id,
            ),
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      expect(selected, equals('two'));
    });
  });
}
