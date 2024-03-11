import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/my_app_button_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('MyAppButtonWidget displays label and icon',
      (WidgetTester tester) async {
    // Create a MaterialApp to provide a context for the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyAppButtonWidget(
            iconData: Icons.add,
            label: 'Add',
            onPressed: () {},
          ),
        ),
      ),
    );

    // Find the MyAppButtonWidget by its label text
    final Finder labelFinder = find.text('Add');
    expect(labelFinder, findsOneWidget);

    // Find the Icon widget
    final Finder iconFinder = find.byIcon(Icons.add);
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('MyAppButtonWidget calls onPressed when tapped',
      (WidgetTester tester) async {
    // Define a variable to track the onPressed callback call count
    int onPressedCallCount = 0;

    // Create a MaterialApp to provide a context for the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyAppButtonWidget(
            iconData: Icons.add,
            label: 'Add',
            onPressed: () {
              onPressedCallCount++;
            },
          ),
        ),
      ),
    );

    // Tap the MyAppButtonWidget
    await tester.tap(find.byType(MyAppButtonWidget));
    await tester.pump();

    // Verify that onPressed was called once
    expect(onPressedCallCount, 1);
  });
}
