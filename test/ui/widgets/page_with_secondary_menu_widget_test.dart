import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/ui/widgets/movil_secondary_menu_widget.dart';
import 'package:jocaaguraarchetype/ui/widgets/page_with_secondary_menu_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void testMe() {}
void main() {
  testWidgets('PageWidthSecondaryMenuWidget should render correctly',
      (WidgetTester tester) async {
    const List<ModelMainMenuModel> listOfModelMainMenu = <ModelMainMenuModel>[
      ModelMainMenuModel(
        iconData: Icons.ac_unit,
        onPressed: testMe,
        label: 'Option 1',
        description: 'Description 1',
      ),
      ModelMainMenuModel(
        iconData: Icons.access_alarm,
        onPressed: testMe,
        label: 'Option 2',
        description: 'Description 2',
      ),
    ];
    const double secondaryMenuWidth = 200.0;
    const ScreenSizeEnum screenSizeEnum = ScreenSizeEnum.tablet;
    final Container page =
        Container(); // Debes proporcionar un widget válido para la página

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageWidthSecondaryMenuWidget(
            listOfModelMainMenu: listOfModelMainMenu,
            secondaryMenuWidth: secondaryMenuWidth,
            screenSizeEnum: screenSizeEnum,
            page: page,
          ),
        ),
      ),
    );

    // Verificar que el widget se renderice correctamente según la lógica del widget
    if (listOfModelMainMenu.isEmpty) {
      expect(find.byType(Container), findsOneWidget);
    } else if (screenSizeEnum == ScreenSizeEnum.mobile ||
        screenSizeEnum == ScreenSizeEnum.tablet) {
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(MovilSecondaryMenuWidget), findsOneWidget);
    } else {
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    }
  });
}
