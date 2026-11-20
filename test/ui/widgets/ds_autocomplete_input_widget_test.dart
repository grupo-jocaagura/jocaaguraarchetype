import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'Given free text When edited and submitted Then preserves the raw value',
    (WidgetTester tester) async {
      const ModelFieldState field = ModelFieldState(
        errorText: 'Revisa la ciudad.',
        isValid: false,
        suggestions: <String>['Medellín'],
      );
      final List<ModelFieldState> edits = <ModelFieldState>[];
      final List<ModelFieldState> submissions = <ModelFieldState>[];
      await tester.pumpWidget(
        _form(field: field, onEdit: edits.add, onSubmit: submissions.add),
      );
      await tester.enterText(_textField, '  Bogotá  ');
      await tester.pumpAndSettle();
      expect(find.text('Medellín'), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final ModelFieldState proposal = field.copyWith(
        value: '  Bogotá  ',
        isDirty: true,
      );
      expect(edits, <ModelFieldState>[proposal]);
      expect(submissions, <ModelFieldState>[proposal]);
      expect(find.text('Revisa la ciudad.'), findsOneWidget);
      expect(find.text('Escribe o elige una ciudad.'), findsNothing);
    },
  );

  testWidgets(
    'Given an active IME When options arrive Then updates the list in place',
    (WidgetTester tester) async {
      final List<ModelFieldState> edits = <ModelFieldState>[];
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(_form(field: field, onEdit: edits.add));
        await tester.pumpAndSettle();
      }

      await render(const ModelFieldState());
      await tester.showKeyboard(_textField);
      const TextEditingValue composing = TextEditingValue(
        text: 'かな',
        selection: TextSelection(baseOffset: 0, extentOffset: 1),
        composing: TextRange(start: 0, end: 2),
      );
      tester.testTextInput.updateEditingValue(composing);
      await tester.pump();
      final ModelFieldState accepted = edits.single;
      await render(accepted);
      final EditableText editor = tester.widget<EditableText>(_editor);
      expect(editor.controller.value, composing);
      expect(find.text('Osaka'), findsNothing);

      await render(accepted.copyWith(suggestions: <String>['Osaka', 'かながわ']));
      expect(find.text('Osaka'), findsOneWidget);
      expect(find.text('かながわ'), findsOneWidget);
      expect(editor.focusNode.hasFocus, isTrue);
      expect(editor.controller.value, composing);
      expect(edits, <ModelFieldState>[accepted]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Osaka'))
            .flagsCollection
            .isSelected,
        Tristate.isFalse,
      );
      expect(edits, hasLength(1));
      final TextEditingValue afterArrow = editor.controller.value;
      expect(afterArrow.composing, composing.composing);

      await render(accepted.copyWith(suggestions: <String>['かなざわ']));
      expect(find.text('かなざわ'), findsOneWidget);
      expect(find.text('Osaka'), findsNothing);
      expect(editor.controller.value, afterArrow);

      await render(accepted);
      expect(find.text('かなざわ'), findsNothing);
      expect(editor.controller.value, afterArrow);
    },
  );

  testWidgets(
    'Given ordered results When a row is tapped Then proposes it once',
    (WidgetTester tester) async {
      const ModelFieldState field = ModelFieldState(
        suggestions: <String>['Santa Marta', 'Bogotá'],
      );
      final List<ModelFieldState> edits = <ModelFieldState>[];
      await tester.pumpWidget(_form(field: field, onEdit: edits.add));
      await tester.showKeyboard(_textField);
      await tester.pumpAndSettle();
      expect(find.text('Santa Marta'), findsNothing);

      await tester.enterText(_textField, 'sa');
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Santa Marta')).dy,
        lessThan(tester.getTopLeft(find.text('Bogotá')).dy),
      );
      await tester.tap(find.text('Bogotá'));
      await tester.pumpAndSettle();
      expect(edits, <ModelFieldState>[
        field.copyWith(value: 'sa', isDirty: true),
        field.copyWith(value: 'Bogotá', isDirty: true),
      ]);
      final EditableText editor = tester.widget<EditableText>(_editor);
      expect(editor.focusNode.hasFocus, isTrue);
      expect(editor.controller.text, 'sa');
      expect(find.text('Santa Marta'), findsNothing);

      await tester.pumpWidget(_form(field: edits.last, onEdit: edits.add));
      await tester.pumpAndSettle();
      expect(editor.controller.text, 'Bogotá');
      expect(find.text('Santa Marta'), findsNothing);
      expect(edits, hasLength(2));
    },
  );

  for (final bool nativeAction in <bool>[false, true]) {
    testWidgets('Given a highlighted option When confirming with '
        '${nativeAction ? 'the input action' : 'Enter'} Then only chooses it', (
      WidgetTester tester,
    ) async {
      const ModelFieldState field = ModelFieldState(
        suggestions: <String>['Santa Marta', 'Santa Rosa'],
      );
      final List<ModelFieldState> edits = <ModelFieldState>[];
      final List<ModelFieldState> submissions = <ModelFieldState>[];
      await tester.pumpWidget(
        _form(field: field, onEdit: edits.add, onSubmit: submissions.add),
      );
      await tester.enterText(_textField, 'Santa');
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          WidgetsLocalizations.of(tester.element(_textField))
              .searchResultsFound,
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      final SemanticsData option = tester
          .getSemantics(find.bySemanticsLabel('Santa Marta'))
          .getSemanticsData();
      expect(option.flagsCollection.isSelected, Tristate.isTrue);

      if (nativeAction) {
        await tester.testTextInput.receiveAction(TextInputAction.done);
      } else {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      }
      await tester.pumpAndSettle();
      expect(edits, <ModelFieldState>[
        field.copyWith(value: 'Santa', isDirty: true),
        field.copyWith(value: 'Santa Marta', isDirty: true),
      ]);
      expect(submissions, isEmpty);
      expect(tester.widget<EditableText>(_editor).focusNode.hasFocus, isTrue);
      expect(find.text('Santa Rosa'), findsNothing);
    });
  }

  testWidgets(
    'Given visible options When pressing Escape or Tab Then closes without choosing',
    (WidgetTester tester) async {
      const ModelFieldState field = ModelFieldState(
        suggestions: <String>['Santa Marta'],
      );
      final List<ModelFieldState> edits = <ModelFieldState>[];
      await tester.pumpWidget(_form(field: field, onEdit: edits.add));
      await tester.enterText(_textField, 'sa');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      final EditableText editor = tester.widget<EditableText>(_editor);
      expect(editor.focusNode.hasFocus, isTrue);
      expect(editor.controller.text, 'sa');
      expect(find.text('Santa Marta'), findsNothing);

      await tester.pumpWidget(
        _form(
          field: field.copyWith(suggestions: <String>['Santa Rosa']),
          onEdit: edits.add,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Santa Rosa'), findsNothing);
      await tester.enterText(_textField, 'san');
      await tester.pumpAndSettle();
      expect(find.text('Santa Rosa'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(editor.focusNode.hasFocus, isFalse);
      expect(find.text('Santa Rosa'), findsNothing);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<TextButton>(),
        isNotNull,
      );
      expect(edits.map((ModelFieldState edit) => edit.value), <String>[
        'sa',
        'san',
      ]);
    },
  );

  for (final bool readOnly in <bool>[true, false]) {
    testWidgets(
      'Given an open field When made ${readOnly ? 'read-only' : 'disabled'} '
      'Then blocks suggestions and submissions',
      (WidgetTester tester) async {
        const ModelFieldState field = ModelFieldState(
          suggestions: <String>['Santa Marta'],
        );
        final List<ModelFieldState> edits = <ModelFieldState>[];
        final List<ModelFieldState> submissions = <ModelFieldState>[];
        await tester.pumpWidget(_form(field: field, onEdit: edits.add));
        await tester.enterText(_textField, 'sa');
        await tester.pumpAndSettle();
        expect(find.text('Santa Marta'), findsOneWidget);

        await tester.pumpWidget(
          _form(
            field: edits.single,
            onEdit: edits.add,
            onSubmit: submissions.add,
            enabled: readOnly,
            readOnly: readOnly,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Santa Marta'), findsNothing);
        final TextField input = tester.widget<TextField>(_textField);
        expect(input.onChanged, isNull);
        expect(input.onSubmitted, isNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(edits, hasLength(1));
        expect(submissions, isEmpty);
      },
    );
  }

  testWidgets(
    'Given text at 200% When navigating a narrow list Then scrolls to options',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(240, 340);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final List<String> suggestions = <String>[
        for (int i = 0; i < 8; i++) 'Santa Rosa de Cabal, Colombia ${i + 1}',
      ];
      final List<ModelFieldState> edits = <ModelFieldState>[];
      await tester.pumpWidget(
        _form(
          field: ModelFieldState(suggestions: suggestions),
          onEdit: edits.add,
          textScale: 2,
        ),
      );
      await tester.enterText(_textField, 'Santa');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(find.text(suggestions.last).hitTestable(), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(edits.last.value, suggestions.last);
      expect(tester.takeException(), isNull);
    },
  );
}

final Finder _textField = find.byType(TextField);
final Finder _editor = find.byType(EditableText);

Widget _form({
  required ModelFieldState field,
  required ValueChanged<ModelFieldState> onEdit,
  ValueChanged<ModelFieldState>? onSubmit,
  bool enabled = true,
  bool readOnly = false,
  double textScale = 1,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (BuildContext context) => MediaQuery.withClampedTextScaling(
          minScaleFactor: textScale,
          maxScaleFactor: textScale,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DsAutocompleteInputWidget(
                  field: field,
                  label: 'Ciudad',
                  helperText: 'Escribe o elige una ciudad.',
                  onChangedAttempt: onEdit,
                  onSubmittedAttempt: onSubmit,
                  enabled: enabled,
                  readOnly: readOnly,
                ),
                TextButton(onPressed: () {}, child: const Text('Siguiente')),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
