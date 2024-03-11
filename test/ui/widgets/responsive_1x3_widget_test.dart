import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/responsive_1x3_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('Responsive1x3Widget has correct width and height',
      (WidgetTester tester) async {
    final Container child = Container();
    const double height = 100.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Responsive1x3Widget(
            height: height,
            child: child,
          ),
        ),
      ),
    );

    const double expectedWidth = height * 3;
    const double expectedHeight = height;

    final Finder widgetFinder = find.byWidget(child);
    expect(widgetFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject<RenderBox>(widgetFinder);
    expect(renderBox.size.width, expectedWidth);
    expect(renderBox.size.height, expectedHeight);
  });

  // Add more test cases if needed
}
