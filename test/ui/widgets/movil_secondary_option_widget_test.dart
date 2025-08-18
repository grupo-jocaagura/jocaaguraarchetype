import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('MovilSecondaryOptionWidget should render correctly',
      (WidgetTester tester) async {
    void onPressed() {}

    const String label = 'Option';
    const String description = 'Description';
    const IconData icondata = Icons.ac_unit;
    const double width = 100.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Scaffold(
            body: MobileSecondaryOptionWidget(
              onPressed: onPressed,
              label: label,
              description: description,
              icondata: icondata,
              width: width,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Verificar que los elementos del widget se muestren correctamente
    expect(find.text(label), findsOneWidget);
    //expect(find.text(description), findsOneWidget);
    expect(find.byIcon(icondata), findsOneWidget);
  });
}
