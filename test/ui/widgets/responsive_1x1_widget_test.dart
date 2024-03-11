import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/responsive_1x1_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('Responsive1x1Widget has correct width and height',
      (WidgetTester tester) async {
    final Container child = Container();
    const double width = 100.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Responsive1x1Widget(
            width: width,
            child: child,
          ),
        ),
      ),
    );

    const double expectedWidth = width;
    const double expectedHeight = width;

    final Finder widgetFinder = find.byWidget(child);
    expect(widgetFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject<RenderBox>(widgetFinder);
    expect(renderBox.size.width, expectedWidth);
    expect(renderBox.size.height, expectedHeight);
  });

  // Add more test cases if needed
}
