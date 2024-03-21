import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/responsive_1x2_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('Responsive1x2Widget has correct width and height',
      (WidgetTester tester) async {
    const double height = 100.0;
    const double expectedWidth = height * 2;
    const double expectedHeight = height;

    const SizedBox child = SizedBox(
      width: expectedWidth,
      height: expectedHeight,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Responsive1x2Widget(
            height: height,
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
}
