import 'dart:ui' show Tristate;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('edits propose raw text and keep consumer validation', (
    WidgetTester tester,
  ) async {
    const ModelFieldState initial = ModelFieldState(
      errorText: 'Revisa el nombre.',
      isValid: false,
      suggestions: <String>['Ana'],
    );
    final List<ModelFieldState> edits = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(_input(field: initial, onChangedAttempt: edits.add)),
    );
    await tester.enterText(_textField, '  Ana  ');
    expect(edits, <ModelFieldState>[
      initial.copyWith(value: '  Ana  ', isDirty: true),
    ]);
    expect(_editor(tester).controller.text, '  Ana  ');
    expect(find.text('Revisa el nombre.'), findsOneWidget);

    await tester.pumpWidget(
      _host(
        _input(
          field: initial,
          onChangedAttempt: edits.add,
          key: const ValueKey<int>(1),
        ),
      ),
    );
    expect(_editor(tester).controller.text, isEmpty);
    expect(edits, hasLength(1));
  });

  testWidgets(
    'model sync keeps IME and selection until the text replaces them',
    (WidgetTester tester) async {
      final List<ModelFieldState> edits = <ModelFieldState>[];
      Future<void> render(ModelFieldState field) => tester.pumpWidget(
        _host(_input(field: field, onChangedAttempt: edits.add)),
      );
      await render(const ModelFieldState());
      await tester.showKeyboard(_textField);
      const TextEditingValue draft = TextEditingValue(
        text: 'abかなz',
        selection: TextSelection(
          baseOffset: 3,
          extentOffset: 4,
          isDirectional: true,
        ),
        composing: TextRange(start: 2, end: 4),
      );
      tester.testTextInput.updateEditingValue(draft);
      await tester.pump();
      final TextEditingController controller = _editor(tester).controller;
      expect(controller.value, draft);

      await render(
        const ModelFieldState(errorText: 'Valida este texto.', isValid: false),
      );
      expect(controller.value, draft);
      await render(const ModelFieldState(value: 'abかなz', isDirty: true));
      expect(controller.value, draft);

      await render(const ModelFieldState(value: 'Xabかなz', isDirty: true));
      expect(
        controller.value,
        const TextEditingValue(
          text: 'Xabかなz',
          selection: TextSelection(
            baseOffset: 4,
            extentOffset: 5,
            isDirectional: true,
          ),
          composing: TextRange(start: 3, end: 5),
        ),
      );
      await render(const ModelFieldState(value: '!', isDirty: true));
      expect(controller.text, '!');
      expect(controller.selection.baseOffset, 1);
      expect(controller.selection.extentOffset, 1);
      expect(controller.value.composing, TextRange.empty);
      expect(edits.map((ModelFieldState edit) => edit.value), <String>[
        draft.text,
      ]);
    },
  );

  testWidgets(
    'an external edit shifts selection endpoints in the preserved IME suffix',
    (WidgetTester tester) async {
      final List<ModelFieldState> edits = <ModelFieldState>[];
      Future<void> render(String value) => tester.pumpWidget(
        _host(
          _input(
            field: ModelFieldState(value: value),
            onChangedAttempt: edits.add,
          ),
        ),
      );

      for (final (String next, TextSelection selection, TextSelection expected)
          in const <(String, TextSelection, TextSelection)>[
            (
              'Xabかなz',
              TextSelection.collapsed(offset: 1),
              TextSelection.collapsed(offset: 2),
            ),
            (
              'Xabかなz',
              TextSelection.collapsed(offset: 3),
              TextSelection.collapsed(offset: 4),
            ),
            (
              'Xabかなz',
              TextSelection.collapsed(offset: 5),
              TextSelection.collapsed(offset: 6),
            ),
            (
              'AABかなz',
              TextSelection(baseOffset: 5, extentOffset: 1),
              TextSelection(baseOffset: 6, extentOffset: 1),
            ),
          ]) {
        await render('abかなz');
        final TextEditingController controller = _editor(tester).controller;
        final TextEditingValue before = TextEditingValue(
          text: 'abかなz',
          selection: selection,
          composing: const TextRange(start: 2, end: 4),
        );
        // Set both ranges together so Flutter's caret movement does not end
        // composition before the external model update under test.
        controller.value = before;
        await tester.pump();
        expect(controller.value, before);

        await render(next);
        expect(
          controller.value,
          TextEditingValue(
            text: next,
            selection: expected,
            composing: const TextRange(start: 3, end: 5),
          ),
        );
        expect(edits, isEmpty);
      }
    },
  );

  testWidgets(
    'submitting an untouched field keeps its state and advances focus',
    (WidgetTester tester) async {
      const ModelFieldState initial = ModelFieldState(value: 'Ana');
      final List<ModelFieldState> submissions = <ModelFieldState>[];
      final List<ModelFieldState> edits = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _input(
                field: initial,
                textInputAction: TextInputAction.next,
                onChangedAttempt: edits.add,
                onSubmittedAttempt: submissions.add,
              ),
              const DsTextInputWidget(
                field: ModelFieldState(),
                label: 'Apellido',
                onChangedAttempt: _ignore,
              ),
            ],
          ),
        ),
      );
      await tester.showKeyboard(_textField.first);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(_editor(tester, index: 1).focusNode.hasFocus, isTrue);
      expect(submissions, <ModelFieldState>[initial]);
      expect(edits, isEmpty);
    },
  );

  testWidgets(
    'submits the current draft and lets multiline input insert newlines',
    (WidgetTester tester) async {
      final List<ModelFieldState> submissions = <ModelFieldState>[];
      final List<ModelFieldState> edits = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _input(
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            onChangedAttempt: edits.add,
            onSubmittedAttempt: submissions.add,
          ),
        ),
      );
      await tester.enterText(_textField, '  Línea uno\nLínea dos  ');
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();
      expect(_editor(tester).focusNode.hasFocus, isTrue);
      expect(submissions, isEmpty);
      expect(edits.single.value, '  Línea uno\nLínea dos  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(submissions, <ModelFieldState>[edits.single]);
    },
  );

  testWidgets(
    'uses one accessible label and gives the error priority over help',
    (WidgetTester tester) async {
      const String help = 'Usa el nombre de tu documento.';
      const String error = 'Completa el nombre.';
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_input(field: field, required: true, helperText: help)),
        );
        await tester.pumpAndSettle();
      }

      await render(const ModelFieldState());
      expect(find.text(help), findsOneWidget);
      expect(find.text('Nombre *'), findsOneWidget);
      await render(
        const ModelFieldState(value: 'Ana', errorText: error, isValid: false),
      );
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      final Finder name = find.bySemanticsLabel('Nombre');
      expect(name, findsOneWidget);
      final SemanticsData data = tester.getSemantics(name).getSemanticsData();
      expect(data.flagsCollection.isTextField, isTrue);
      expect(data.flagsCollection.isRequired, Tristate.isTrue);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.value, 'Ana');
      expect(
        data.hint.split('\n'),
        unorderedEquals(<String>[error, 'Obligatorio']),
      );
    },
  );

  testWidgets(
    'read-only text can be selected and copied while disabled skips focus',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      String? copiedText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      Future<void> render({required bool enabled}) => tester.pumpWidget(
        _host(
          _input(
            field: const ModelFieldState(value: 'Ana'),
            enabled: enabled,
            readOnly: true,
            onChangedAttempt: attempts.add,
            onSubmittedAttempt: attempts.add,
          ),
        ),
      );

      await render(enabled: true);
      final Finder name = find.bySemanticsLabel('Nombre');
      final SemanticsData data = tester.getSemantics(name).getSemanticsData();
      expect(data.flagsCollection.isReadOnly, isTrue);
      expect(data.flagsCollection.isTextField, !kIsWeb);
      expect(data.hasAction(SemanticsAction.setText), isFalse);
      expect(data.value, 'Ana');
      expect(data.hint, 'Solo lectura');
      await tester.tap(_textField);
      await tester.pump();
      final EditableText editable = _editor(tester);
      expect(editable.focusNode.hasFocus, isTrue);
      editable.controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 3,
      );
      Actions.invoke(editable.focusNode.context!, CopySelectionTextIntent.copy);
      await tester.pump();
      expect(copiedText, 'Ana');
      expect(editable.onChanged, isNull);
      expect(editable.onSubmitted, isNull);

      await render(enabled: false);
      await tester.pumpAndSettle();
      final SemanticsData disabled = tester
          .getSemantics(name)
          .getSemanticsData();
      expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
      expect(_editor(tester).controller.text, 'Ana');
      expect(_editor(tester).focusNode.canRequestFocus, isFalse);
      expect(attempts, isEmpty);
    },
  );

  testWidgets('the editor and validation message respect text at 200 percent', (
    WidgetTester tester,
  ) async {
    const String error =
        'Incluye el nombre completo que figura en el documento.';
    await tester.pumpWidget(
      _host(
        _input(
          field: const ModelFieldState(
            value: 'Ana María',
            errorText: error,
            isValid: false,
          ),
          maxLines: 3,
        ),
        scaler: const TextScaler.linear(2),
      ),
    );

    final RenderEditable editor = tester
        .state<EditableTextState>(find.byType(EditableText))
        .renderEditable;
    expect(editor.textScaler.scale(10), 20);
    final RenderParagraph message = tester.renderObject<RenderParagraph>(
      find.text(error),
    );
    expect(message.textScaler.scale(10), 20);
    final List<TextBox> bounds = message.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: error.length),
    );
    expect(
      bounds.map((TextBox box) => box.top).toSet(),
      hasLength(greaterThan(1)),
    );
    expect(bounds.last.bottom, lessThanOrEqualTo(message.size.height));
  });
}

final Finder _textField = find.byType(TextField);

EditableText _editor(WidgetTester tester, {int index = 0}) =>
    tester.widget<EditableText>(find.byType(EditableText).at(index));

DsTextInputWidget _input({
  Key? key,
  ModelFieldState field = const ModelFieldState(),
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
  ValueChanged<ModelFieldState>? onSubmittedAttempt,
  TextInputAction? textInputAction,
  String? helperText,
  bool required = false,
  bool readOnly = false,
  bool enabled = true,
  int maxLines = 1,
}) => DsTextInputWidget(
  key: key,
  field: field,
  label: 'Nombre',
  placeholder: 'Escribe tu nombre',
  onChangedAttempt: onChangedAttempt,
  onSubmittedAttempt: onSubmittedAttempt,
  textInputAction: textInputAction,
  helperText: helperText,
  required: required,
  readOnly: readOnly,
  enabled: enabled,
  maxLines: maxLines,
  requiredSemanticLabel: 'Obligatorio',
  readOnlySemanticLabel: 'Solo lectura',
);

Widget _host(Widget input, {TextScaler? scaler}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: 240, child: input),
          ),
        ),
      ),
    ),
  ),
);

void _ignore(ModelFieldState next) {}
