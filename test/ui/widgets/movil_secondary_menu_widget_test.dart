import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/models/model_main_menu.dart';
import 'package:jocaaguraarchetype/ui/widgets/movil_secondary_menu_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void testMe() {}
void main() {
  testWidgets('MovilSecondaryMenuWidget should render correctly',
      (WidgetTester tester) async {
    const List<ModelMainMenu> listOfModelMainMenu = <ModelMainMenu>[
      ModelMainMenu(
        iconData: Icons.ac_unit,
        onPressed: testMe,
        label: 'Option 1',
        description: 'Description 1',
      ),
      ModelMainMenu(
        iconData: Icons.access_alarm,
        onPressed: testMe,
        label: 'Option 2',
        description: 'Description 2',
      ),
    ];
    const double menuItemWidth = 60.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: Scaffold(
            body: MovilSecondaryMenuWidget(
              listOfModelMainMenu: listOfModelMainMenu,
              menuItemWidth: menuItemWidth,
            ),
          ),
        ),
      ),
    );

    // Verificar que los elementos del widget se muestren correctamente
    for (final ModelMainMenu modelMainMenu in listOfModelMainMenu) {
      expect(find.text(modelMainMenu.label), findsOneWidget);
      expect(find.byIcon(modelMainMenu.iconData), findsOneWidget);
    }

    // Verificar la cantidad de elementos y separadores
    final Finder rowFinder = find.byType(Row);
    expect(rowFinder, findsOneWidget);
    final Row row = tester.widget<Row>(rowFinder);
    final List<Widget> children = row.children;
    final int numOfOptions = listOfModelMainMenu.length;
    final int numOfSeparators = numOfOptions;
    expect(children.length, numOfOptions + numOfSeparators);

    // Verificar el ancho del menú de opciones
    final Finder sizedBoxFinder = find.byType(SizedBox);
    expect(sizedBoxFinder, findsAtLeastNWidgets(1));

    // Verificar el ancho del separador
    final Finder separatorFinder = find.byType(SizedBox).last;
    expect(separatorFinder, findsOneWidget);
    final SizedBox separator = tester.widget<SizedBox>(separatorFinder);
    const double expectedSeparatorWidth = menuItemWidth * 0.2;
    expect(separator.width, expectedSeparatorWidth);
  });
}
