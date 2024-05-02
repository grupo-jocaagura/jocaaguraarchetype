import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/ui/widgets/my_snack_bar_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('MySnackBarWidget displays correct message',
      (WidgetTester tester) async {
    final BlocGeneral<String> toastStreamController = BlocGeneral<String>('');
    final Stream<String> toastStream = toastStreamController.stream;
    const String message = 'This is a toast message';

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Scaffold(
            body: MySnackBarWidget(
              gutterWidth: 8.0,
              marginWidth: 16.0,
              width: 200.0,
              toastStream: toastStream,
            ),
          ),
        ),
      ),
    );

    // Verify that MySnackBarWidget is initially not visible
    expect(find.byType(SizedBox), findsOneWidget);

    // Emit a toast message and trigger a rebuild
    toastStreamController.value = message;
    await tester.pump();

    // Verify that MySnackBarWidget is visible with the correct message
    expect(find.byType(MySnackBarWidget), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    // Emit an empty toast message and trigger a rebuild
    toastStreamController.value = '';
    await tester.pumpAndSettle();

    // Verify that MySnackBarWidget is no longer visible
    expect(find.byType(MySnackBarWidget), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
