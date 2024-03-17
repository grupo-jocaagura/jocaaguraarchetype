import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/ui/widgets/main_menu_option_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('MainMenuOptionWidget should display the correct content',
      (WidgetTester tester) async {
    // Create a dummy ModelMainMenu
    final ModelMainMenuModel option = ModelMainMenuModel(
      label: 'Option 1',
      description: 'Description for Option 1',
      iconData: Icons.star,
      onPressed: () {},
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainMenuOptionWidget(
            option: option,
          ),
        ),
      ),
    );

    // Verify the content
    expect(find.text('Option 1'), findsOneWidget);
    expect(find.text('Description for Option 1'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('MainMenuOptionWidget should call onPressed callback on tap',
      (WidgetTester tester) async {
    bool onPressedCalled = false;

    // Create a dummy ModelMainMenu
    final ModelMainMenuModel option = ModelMainMenuModel(
      label: 'Option 1',
      description: 'Description for Option 1',
      iconData: Icons.star,
      onPressed: () {
        onPressedCalled = true;
      },
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainMenuOptionWidget(
            option: option,
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
