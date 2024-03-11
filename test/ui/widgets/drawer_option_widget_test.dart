import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/drawer_option_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('DrawerOptionWidget', () {
    late VoidCallback onPressed;
    late String label;
    late IconData icondata;
    late String description;
    late bool getOutOnTap;

    setUp(() {
      onPressed = () {};
      label = 'Option';
      icondata = Icons.star;
      description = 'Option description';
      getOutOnTap = true;
    });

    testWidgets('renders ListTile with correct values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawerOptionWidget(
              onPressed: onPressed,
              label: label,
              icondata: icondata,
              description: description,
              getOutOnTap: getOutOnTap,
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      expect(find.byIcon(icondata), findsOneWidget);
      expect(find.text(description), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool onPressedCalled = false;
      onPressed = () {
        onPressedCalled = true;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawerOptionWidget(
              onPressed: onPressed,
              label: label,
              icondata: icondata,
              description: description,
              getOutOnTap: getOutOnTap,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(onPressedCalled, isTrue);
    });

    testWidgets('does not open drawer when getOutOnTap is false',
        (WidgetTester tester) async {
      getOutOnTap = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: Drawer(
              child: Container(),
            ),
            body: DrawerOptionWidget(
              onPressed: onPressed,
              label: label,
              icondata: icondata,
              description: description,
              getOutOnTap: getOutOnTap,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(Drawer), findsNothing);
    });
  });
}
