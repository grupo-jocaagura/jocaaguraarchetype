import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/ui/widgets/columns_blueprint_widget.dart';
import 'package:jocaaguraarchetype/ui/widgets/main_menu_widget.dart';
import 'package:jocaaguraarchetype/ui/widgets/work_area_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('WorkAreaWidget', () {
    testWidgets('should render ColumnsBluePrintWidget for mobile screens',
        (WidgetTester tester) async {
      // Arrange
      const ScreenSizeEnum screenSizeEnum = ScreenSizeEnum.mobile;
      const WorkAreaWidget widget = WorkAreaWidget(
        screenSizeEnum: screenSizeEnum,
        columnsNumber: 2,
        workAreaSize: Size(300, 600),
        marginWidth: 16,
        columnWidth: 120,
        gutterWidth: 8,
        drawerWidth: 200,
        listMenuOptions: <ModelMainMenuModel>[],
        listSecondaryMenuOptions: <ModelMainMenuModel>[],
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(child: widget),
        ),
      );

      // Assert
      expect(find.byType(ColumnsBluePrintWidget), findsOneWidget);
    });

    testWidgets(
        'should render ColumnsBluePrintWidget and MainMenuWidget for tablet screens with menu options',
        (WidgetTester tester) async {
      // Arrange
      const ScreenSizeEnum screenSizeEnum = ScreenSizeEnum.tablet;
      final WorkAreaWidget widget = WorkAreaWidget(
        screenSizeEnum: screenSizeEnum,
        columnsNumber: 3,
        workAreaSize: const Size(600, 800),
        marginWidth: 24,
        columnWidth: 180,
        gutterWidth: 12,
        drawerWidth: 240,
        listSecondaryMenuOptions: const <ModelMainMenuModel>[],
        listMenuOptions: <ModelMainMenuModel>[
          ModelMainMenuModel(
            label: 'Option 1',
            onPressed: () {},
            iconData: Icons.add,
          ),
          ModelMainMenuModel(
            label: 'Option 2',
            onPressed: () {},
            iconData: Icons.add,
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(child: widget),
        ),
      );

      // Assert
      expect(find.byType(ColumnsBluePrintWidget), findsOneWidget);
      expect(find.byType(MainMenuWidget), findsNothing);
    });

    testWidgets(
        'should render ColumnsBluePrintWidget and MainMenuWidget for TV screens',
        (WidgetTester tester) async {
      // Arrange
      const ScreenSizeEnum screenSizeEnum = ScreenSizeEnum.tv;
      final WorkAreaWidget widget = WorkAreaWidget(
        screenSizeEnum: screenSizeEnum,
        columnsNumber: 4,
        workAreaSize: const Size(800, 1200),
        marginWidth: 32,
        columnWidth: 200,
        gutterWidth: 16,
        drawerWidth: 280,
        listSecondaryMenuOptions: const <ModelMainMenuModel>[],
        listMenuOptions: <ModelMainMenuModel>[
          ModelMainMenuModel(
            label: 'Option 1',
            onPressed: () {},
            iconData: Icons.add,
          ),
          ModelMainMenuModel(
            label: 'Option 2',
            onPressed: () {},
            iconData: Icons.add,
          ),
          ModelMainMenuModel(
            label: 'Option 3',
            onPressed: () {},
            iconData: Icons.add,
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(child: widget),
        ),
      );

      // Assert
      expect(find.byType(ColumnsBluePrintWidget), findsOneWidget);
      expect(find.byType(MainMenuWidget), findsOneWidget);
    });

    testWidgets('should render ColumnsBluePrintWidget for desktop screens',
        (WidgetTester tester) async {
      // Arrange
      const ScreenSizeEnum screenSizeEnum = ScreenSizeEnum.desktop;
      const WorkAreaWidget widget = WorkAreaWidget(
        screenSizeEnum: screenSizeEnum,
        columnsNumber: 4,
        workAreaSize: Size(1024, 768),
        marginWidth: 32,
        columnWidth: 200,
        gutterWidth: 16,
        drawerWidth: 280,
        listSecondaryMenuOptions: <ModelMainMenuModel>[],
        listMenuOptions: <ModelMainMenuModel>[],
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Material(child: widget),
          ),
        ),
      );

      // Assert
      expect(find.byType(ColumnsBluePrintWidget), findsOneWidget);
    });
  });
}
