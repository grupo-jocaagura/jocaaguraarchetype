import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/responsive_1x2_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('Responsive1x2Widget has correct width and height',
      (WidgetTester tester) async {
    final Container child = Container();
    const double height = 100.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Responsive1x2Widget(
            height: height,
            child: child,
          ),
        ),
      ),
    );

    const double expectedWidth = height * 2;
    const double expectedHeight = height;

    final Finder widgetFinder = find.byWidget(child);
    expect(widgetFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject<RenderBox>(widgetFinder);
    expect(renderBox.size.width, expectedWidth);
    expect(renderBox.size.height, expectedHeight);
  });
}
