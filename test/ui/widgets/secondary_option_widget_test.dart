import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/secondary_option_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('SecondaryOptionWidget should display the correct content',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecondaryOptionWidget(
            onPressed: () {},
            label: 'Option 1',
            icondata: Icons.star,
            description: 'Description for Option 1',
          ),
        ),
      ),
    );

    // Verify the content
    expect(find.text('Option 1'), findsOneWidget);
    expect(find.text('Description for Option 1'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('SecondaryOptionWidget should call onPressed callback on tap',
      (WidgetTester tester) async {
    bool onPressedCalled = false;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecondaryOptionWidget(
            onPressed: () {
              onPressedCalled = true;
            },
            label: 'Option 1',
            icondata: Icons.star,
          ),
        ),
      ),
    );

    // Tap the widget
    await tester.tap(find.byType(ListTile));

    // Verify that onPressed callback was called
    expect(onPressedCalled, isTrue);
  });
}
