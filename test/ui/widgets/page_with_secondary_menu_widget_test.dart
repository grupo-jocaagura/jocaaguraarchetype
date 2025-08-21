import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PageWithSecondaryMenuWidget', () {
    testWidgets(
        'mobile: renders content and bottom overlay when secondary exists',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844)); // mobile

      await tester.pumpWidget(
        _wrap(
          PageWithSecondaryMenuWidget(
            responsive: resp,
            content: const Text('MainContent'),
            secondaryMenu: Container(key: const Key('sec'), height: 48),
          ),
        ),
      );

      expect(find.text('MainContent'), findsOneWidget);
      expect(find.byKey(const Key('sec')), findsOneWidget);
    });

    testWidgets('tablet: renders side panel with constrained content width',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768)); // tablet

      await tester.pumpWidget(
        _wrap(
          PageWithSecondaryMenuWidget(
            responsive: resp,
            content: const Text('MainContent'),
            secondaryMenu: Container(key: const Key('sec-panel'), width: 100),
          ),
        ),
      );

      expect(find.text('MainContent'), findsOneWidget);
      expect(find.byKey(const Key('sec-panel')), findsOneWidget);
    });

    testWidgets('desktop: supports secondaryOnRight = false (left panel)',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1440, 900)); // desktop

      await tester.pumpWidget(
        _wrap(
          PageWithSecondaryMenuWidget(
            responsive: resp,
            content: const Text('Content'),
            secondaryMenu: Container(key: const Key('left-panel')),
            secondaryOnRight: false,
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byKey(const Key('left-panel')), findsOneWidget);
    });

    testWidgets('mobile: hides overlay when no secondaryMenu provided',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(375, 812));

      await tester.pumpWidget(
        _wrap(
          PageWithSecondaryMenuWidget(
            responsive: resp,
            content: const Text('OnlyContent'),
          ),
        ),
      );

      expect(find.text('OnlyContent'), findsOneWidget);
      // No secondary menu should be found.
      expect(find.byKey(const Key('mobile-secondary')), findsNothing);
    });
  });
}
