import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/list_tile_exit_drawer_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('ListTileExitDrawerWidget', () {
    testWidgets('renders ListTile with correct values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListTileExitDrawerWidget(),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Salir'), findsOneWidget);
      expect(find.text('Cerrar menú lateral'), findsOneWidget);
    });

    testWidgets('opens end drawer when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            endDrawer: Drawer(
              child: Container(),
            ),
            body: const ListTileExitDrawerWidget(),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(Drawer), findsOneWidget);
    });
  });
}
