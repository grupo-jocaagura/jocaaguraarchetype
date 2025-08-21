import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  testWidgets('CustomAutoCompleteInputWidget test',
      (WidgetTester tester) async {
    // Define any necessary test data
    String valTmp = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Scaffold(
            body: CustomAutoCompleteInputWidget(
              onChanged: (String val) {
                valTmp = val;
              },
              suggestList: const <String>['Apple', 'Banana', 'Orange'],
              label: 'Label',
              icondata: Icons.search,
              placeholder: 'Placeholder',
              onEditingValidateFunction: (String? val) => null,
              initialData: 'Initial Data',
            ),
          ),
        ),
      ),
    );

    // Perform any necessary test actions and assertions

    // Example: Verify that the label is displayed
    expect(find.text('Label'), findsOneWidget);

    // Example: Verify that the initial data is set to the text field
    expect(find.text('Initial Data'), findsOneWidget);

    // Tap on the text field to activate it
    await tester.tap(find.byType(TextField));
    await tester.pump();

    // Enter text in the text field to trigger suggestion list
    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    // Example: Verify that the selected suggestion is set to the text field
    expect(valTmp, 'A');
    // Verify that the suggestion list is displayed
    await tester.pumpAndSettle();
    // Example: Verify that the suggestion list is displayed
    final Finder finder = find.text('Apple');
    expect(finder, findsOneWidget);
//
    // // Example: Select a suggestion
    await tester.tap(finder);
    await tester.pump();

    // Example: Verify that the onEditingValueFunction is called with the selected value
    // Aquí puedes acceder directamente a la instancia de MockDrawerMainMenuBloc
    expect(valTmp, 'Apple');
  });
}
