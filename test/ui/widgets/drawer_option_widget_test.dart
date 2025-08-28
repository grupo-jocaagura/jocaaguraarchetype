import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DrawerOptionWidget', () {
    testWidgets('renders label, icon and triggers onTap',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1280, 800));

      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          DrawerOptionWidget(
            responsive: resp,
            label: 'Dashboard',
            icon: Icons.dashboard,
            onTap: () => tapped = true,
            selected: true,
            tooltip: 'Go to dashboard',
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('shows badge when badgeCount > 0', (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768));

      await tester.pumpWidget(
        _wrap(
          DrawerOptionWidget(
            responsive: resp,
            label: 'Inbox',
            icon: Icons.inbox,
            badgeCount: 5,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('disabled when onTap is null or enabled=false',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844));

      await tester.pumpWidget(
        _wrap(
          Column(
            children: <Widget>[
              DrawerOptionWidget(
                responsive: resp,
                label: 'Disabled A',
                icon: Icons.block,
                onTap: null, // disabled by null
              ),
              DrawerOptionWidget(
                responsive: resp,
                label: 'Disabled B',
                icon: Icons.block,
                onTap: () {},
                enabled: false, // forced disabled
              ),
            ],
          ),
        ),
      );

      // Both should be present and not tappable (no exceptions thrown on tap).
      await tester.tap(find.text('Disabled A'));
      await tester.tap(find.text('Disabled B'));
      await tester.pump();
    });
  });
}
