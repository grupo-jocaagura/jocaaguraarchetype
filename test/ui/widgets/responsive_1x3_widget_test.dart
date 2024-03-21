import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/responsive_1x3_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('Responsive1x3Widget has correct width and height',
      (WidgetTester tester) async {
    const double height = 100.0;
    const double expectedWidth = height * 3;
    const double expectedHeight = height;
    const SizedBox child = SizedBox(
      width: expectedWidth,
      height: expectedHeight,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Responsive1x3Widget(
            height: height,
            child: child,
          ),
        ),
      ),
    );

    final Finder widgetFinder = find.byWidget(child);
    expect(widgetFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject<RenderBox>(widgetFinder);
    print(renderBox.size);

    expect(renderBox.size.width, expectedWidth);
    expect(renderBox.size.height, expectedHeight);
  });

  // Add more test cases if needed
}
