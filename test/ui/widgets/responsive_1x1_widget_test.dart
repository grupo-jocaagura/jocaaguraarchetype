import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('Responsive1x1Widget has correct width and height',
      (WidgetTester tester) async {
    const double width = 100.0;
    const double expectedWidth = width;
    const double expectedHeight = width;
    const SizedBox child = SizedBox(
      width: expectedWidth,
      height: expectedHeight,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Responsive1x1Widget(
            width: width,
            child: child,
          ),
        ),
      ),
    );

    final Finder widgetFinder = find.byWidget(child);
    expect(widgetFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject<RenderBox>(widgetFinder);
    expect(renderBox.size.width, expectedWidth);
    expect(renderBox.size.height, expectedHeight);
  });

  // Add more test cases if needed
}
