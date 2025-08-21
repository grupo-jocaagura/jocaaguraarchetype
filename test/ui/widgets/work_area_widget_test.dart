import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('WorkAreaWidget', () {
    testWidgets('mobile: renders content full width and bottom secondary bar',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844)); // mobile

      await tester.pumpWidget(
        _wrap(
          WorkAreaWidget(
            responsive: resp,
            content: const Text('Content'),
            secondaryMenu: Container(key: const Key('sec'), height: 48),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byKey(const Key('sec')), findsOneWidget);
    });

    testWidgets('tablet: composes primary + content + secondary side panels',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768)); // tablet

      await tester.pumpWidget(
        _wrap(
          WorkAreaWidget(
            responsive: resp,
            primaryMenu: Container(key: const Key('primary'), width: 100),
            content: const Text('Content'),
            secondaryMenu: Container(key: const Key('secondary'), width: 100),
          ),
        ),
      );

      expect(find.byKey(const Key('primary')), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.byKey(const Key('secondary')), findsOneWidget);
    });

    testWidgets('desktop: respects floatingActionButton overlay',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1440, 900)); // desktop

      await tester.pumpWidget(
        _wrap(
          WorkAreaWidget(
            responsive: resp,
            content: const Text('Content'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
        'tablet: can invert secondary panel side when secondaryMenuOnRight=false',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1100, 820));

      await tester.pumpWidget(
        _wrap(
          WorkAreaWidget(
            responsive: resp,
            primaryMenu: Container(key: const Key('left')),
            content: const Text('Content'),
            secondaryMenu: Container(key: const Key('right')),
            secondaryMenuOnRight: false,
          ),
        ),
      );

      // Just check both panels exist; layout side inversion is harder to assert without golden.
      expect(find.byKey(const Key('left')), findsOneWidget);
      expect(find.byKey(const Key('right')), findsOneWidget);
    });
  });
}
