import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/gutter_blueprint_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('should render GutterBlueprintWidget',
      (WidgetTester tester) async {
    const double width = 8.0;
    const double height = 400.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: Row(
            children: <Widget>[
              GutterBlueprintWidget(
                width: width,
                height: height,
              ),
            ],
          ),
        ),
      ),
    );

    // Verificar que el widget tenga el tamaño y el color correctos
    final RenderBox renderBox =
        tester.renderObject(find.byType(GutterBlueprintWidget));
    expect(renderBox.size.width, equals(width));
    expect(renderBox.size.height, equals(height));
  });
}
