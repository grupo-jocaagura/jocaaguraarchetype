import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Cantidad';
final Finder _field = find.byType(TextField);
final Finder _editor = find.byType(EditableText);

void main() {
  testWidgets('uses numeric keyboard options and configurable autofill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DsNumberInputWidget(
          field: ModelFieldState(),
          label: _label,
          onChangedAttempt: _ignore,
        ),
      ),
    );
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.keyboardType, TextInputType.number);
    expect(editor.maxLines, 1);
    expect(editor.autocorrect, isFalse);
    expect(editor.enableSuggestions, isFalse);
    expect(editor.autofillHints, isNull);
    expect(editor.onSubmitted, isNull);

    const List<String> hints = <String>[AutofillHints.transactionAmount];
    for (final bool signed in <bool>[false, true]) {
      for (final bool decimal in <bool>[false, true]) {
        await tester.pumpWidget(
          _host(
            DsNumberInputWidget(
              field: const ModelFieldState(),
              label: _label,
              placeholder: '0',
              onChangedAttempt: _ignore,
              signed: signed,
              decimal: decimal,
              autofillHints: hints,
            ),
          ),
        );
        final EditableText configured = tester.widget<EditableText>(_editor);
        expect(
          configured.keyboardType,
          TextInputType.numberWithOptions(signed: signed, decimal: decimal),
        );
        expect(configured.autofillHints, hints);
        expect(tester.widget<TextField>(_field).decoration?.hintText, '0');
      }
    }
  });

  testWidgets('keeps intermediate edits and submits pasted text unchanged', (
    WidgetTester tester,
  ) async {
    const String pasted = '  +001.234,50  ';
    const ModelFieldState initial = ModelFieldState();
    final TestDefaultBinaryMessenger messenger =
        tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (
      MethodCall call,
    ) async {
      return call.method == 'Clipboard.getData'
          ? <String, String>{'text': pasted}
          : null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final List<ModelFieldState> edits = <ModelFieldState>[];
    final List<ModelFieldState> submissions = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(
        DsNumberInputWidget(
          field: initial,
          label: _label,
          textInputAction: TextInputAction.done,
          onChangedAttempt: edits.add,
          onSubmittedAttempt: submissions.add,
        ),
      ),
    );
    for (final String raw in <String>['0007', '-', '1,']) {
      await tester.enterText(_field, raw);
      expect(edits.last, initial.copyWith(value: raw, isDirty: true));
    }
    expect(edits, hasLength(3));

    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.textInputAction, TextInputAction.done);
    editor.controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: editor.controller.text.length,
    );
    Actions.invoke(
      editor.focusNode.context!,
      const PasteTextIntent(SelectionChangedCause.keyboard),
    );
    await tester.pumpAndSettle();
    final ModelFieldState proposal = initial.copyWith(
      value: pasted,
      isDirty: true,
    );
    expect(editor.controller.text, pasted);
    expect(edits, hasLength(4));
    expect(edits.last, proposal);
    expect(submissions, isEmpty);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submissions, <ModelFieldState>[proposal]);
  });

  testWidgets('validation preserves the draft, selection and composition', (
    WidgetTester tester,
  ) async {
    const String help = 'Indica el peso en kilogramos.';
    const String error = 'El peso debe ser positivo.';
    const TextEditingValue draft = TextEditingValue(
      text: '-001,5',
      selection: TextSelection(baseOffset: 4, extentOffset: 2),
      composing: TextRange(start: 1, end: 4),
    );
    final List<ModelFieldState> edits = <ModelFieldState>[];
    Future<void> render(ModelFieldState field) => tester.pumpWidget(
      _host(
        DsNumberInputWidget(
          field: field,
          label: _label,
          helperText: help,
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          signed: true,
          decimal: true,
          onChangedAttempt: edits.add,
        ),
      ),
    );

    await render(const ModelFieldState());
    expect(find.text(help), findsOneWidget);
    await tester.showKeyboard(_field);
    tester.testTextInput.updateEditingValue(draft);
    await tester.pump();
    expect(edits.single.value, draft.text);

    await render(const ModelFieldState(isValid: false, errorText: error));
    await tester.pumpAndSettle();
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.controller.value, draft);
    expect(editor.focusNode.hasFocus, isTrue);
    expect(edits, hasLength(1));
    expect(find.text(help), findsNothing);
    expect(find.text(error), findsOneWidget);
    final Finder name = find.bySemanticsLabel(_label);
    expect(name, findsOneWidget);
    final SemanticsData semantics = tester
        .getSemantics(name)
        .getSemanticsData();
    expect(semantics.flagsCollection.isRequired, Tristate.isTrue);
    expect(semantics.validationResult, SemanticsValidationResult.invalid);
    expect(
      semantics.hint.split('\n'),
      unorderedEquals(<String>[error, 'Obligatorio']),
    );
  });

  testWidgets('exposes the original value as read-only and disables focus', (
    WidgetTester tester,
  ) async {
    const ModelFieldState accepted = ModelFieldState(value: '00125');
    Future<void> render({required bool enabled}) => tester.pumpWidget(
      _host(
        DsNumberInputWidget(
          field: accepted,
          label: _label,
          enabled: enabled,
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          onChangedAttempt: _ignore,
        ),
      ),
    );

    await render(enabled: true);
    final Finder name = find.bySemanticsLabel(_label);
    final SemanticsData semantics = tester
        .getSemantics(name)
        .getSemanticsData();
    expect(semantics.value, accepted.value);
    expect(semantics.hint, 'Solo lectura');
    expect(semantics.flagsCollection.isReadOnly, isTrue);
    expect(semantics.hasAction(SemanticsAction.setText), isFalse);
    expect(tester.widget<EditableText>(_editor).onChanged, isNull);

    await render(enabled: false);
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(_editor).focusNode.canRequestFocus,
      false,
    );
    final SemanticsData disabled = tester.getSemantics(name).getSemanticsData();
    expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
  });
}

Widget _host(Widget input) => MaterialApp(home: Scaffold(body: input));

void _ignore(ModelFieldState field) {}
