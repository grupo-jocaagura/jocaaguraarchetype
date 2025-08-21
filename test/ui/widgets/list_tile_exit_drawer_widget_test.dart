import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ListTileExitDrawerWidget', () {
    testWidgets('renders label, icon and confirms before exit',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844));

      bool exited = false;

      await tester.pumpWidget(
        _wrap(
          ListTileExitDrawerWidget(
            responsive: resp,
            onExit: () => exited = true,
            confirmMessage: 'Sure?',
            cancelActionLabel: 'No',
          ),
        ),
      );

      expect(find.text('Sign out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Sure?'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(exited, isTrue);
    });

    testWidgets('executes immediately when confirmBeforeExit=false',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(1024, 768));

      bool exited = false;

      await tester.pumpWidget(
        _wrap(
          ListTileExitDrawerWidget(
            responsive: resp,
            label: 'Exit',
            confirmBeforeExit: false,
            onExit: () => exited = true,
          ),
        ),
      );

      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(exited, isTrue);
    });
    testWidgets('disabled state prevents tap & dialog',
        (WidgetTester tester) async {
      final BlocResponsive resp = BlocResponsive()
        ..setSizeForTesting(const Size(390, 844));
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTileExitDrawerWidget(
              responsive: resp,
              onExit: () => called = true,
              enabled: false, // 👈 deshabilitado
            ),
          ),
        ),
      );

      await tester.tap(
        find.byType(InkWell),
      ); // no debería abrir diálogo ni llamar callback
      await tester.pumpAndSettle();

      expect(called, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
