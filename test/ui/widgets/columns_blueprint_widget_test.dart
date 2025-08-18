import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('should render ColumnsBluePrintWidget',
      (WidgetTester tester) async {
    const int numberOfColumns = 3;
    const double marginWidth = 16.0;
    const double columnWidth = 100.0;
    const double gutterWidth = 8.0;
    const Size workAreaSize = Size(800.0, 600.0);

    await tester.pumpWidget(
      const MaterialApp(
        home: ColumnsBluePrintWidget(
          numberOfColumns: numberOfColumns,
          marginWidth: marginWidth,
          columnWidth: columnWidth,
          gutterWidth: gutterWidth,
          workAreaSize: workAreaSize,
        ),
      ),
    );

    // Verificar que se rendericen las columnas y los margenes correctamente
    expect(find.byType(ColumnBlueprintWidget), findsNWidgets(numberOfColumns));
    expect(
      find.byType(GutterBlueprintWidget),
      findsNWidgets(numberOfColumns - 1),
    );
    expect(find.byType(MarginBlueprintWidget), findsNWidgets(2));

    // Verificar el tamaño del widget
    final RenderBox renderBox =
        tester.renderObject(find.byType(ColumnsBluePrintWidget));
    expect(renderBox.size.width, lessThanOrEqualTo(workAreaSize.width));
    expect(renderBox.size.height, equals(workAreaSize.height));
  });
}
