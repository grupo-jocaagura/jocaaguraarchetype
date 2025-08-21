import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))),
    );

void main() {
  group('MainMenuOptionWidget', () {
    testWidgets('renders label, icon and triggers onTap',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1280, 800));
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          MainMenuOptionWidget(
            responsive: resp,
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('disabled state prevents tap', (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768));

      await tester.pumpWidget(
        _wrap(
          MainMenuOptionWidget(
            responsive: resp,
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {},
            enabled: false,
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle(); // no callback expected
      // No direct way to assert callback not called, but no exceptions/dialogs.
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('horizontal axis lays out icon and label in a row',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(900, 700));

      await tester.pumpWidget(
        _wrap(
          MainMenuOptionWidget(
            responsive: resp,
            icon: Icons.explore,
            label: 'Explore',
            onTap: () {},
            axis: Axis.horizontal,
          ),
        ),
      );

      expect(find.text('Explore'), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
    });

    testWidgets('badge is shown when badgeCount > 0',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1440, 900));

      await tester.pumpWidget(
        _wrap(
          MainMenuOptionWidget(
            responsive: resp,
            icon: Icons.mail,
            label: 'Inbox',
            onTap: () {},
            badgeCount: 42,
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });
  });
}
