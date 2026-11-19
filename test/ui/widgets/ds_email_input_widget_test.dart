import 'dart:ui' show Tristate;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Correo electrónico';
final Finder _editor = find.byType(EditableText);
final Finder _field = find.byType(TextField);

void main() {
  testWidgets('uses a single-line email keyboard and configurable autofill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DsEmailInputWidget(
          field: ModelFieldState(),
          label: _label,
          onChangedAttempt: _ignore,
        ),
      ),
    );
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.keyboardType, TextInputType.emailAddress);
    expect(editor.maxLines, 1);
    expect(editor.autocorrect, isFalse);
    expect(editor.enableSuggestions, isFalse);
    expect(editor.smartDashesType, SmartDashesType.disabled);
    expect(editor.smartQuotesType, SmartQuotesType.disabled);
    expect(editor.autofillHints, const <String>[AutofillHints.email]);
    expect(editor.onSubmitted, isNull);
    expect(tester.widget<TextField>(_field).decoration?.hintText, isNull);

    await tester.pumpWidget(
      _host(
        const DsEmailInputWidget(
          field: ModelFieldState(),
          label: _label,
          onChangedAttempt: _ignore,
          autofillHints: <String>[AutofillHints.username],
          placeholder: 'nombre@example.com',
        ),
      ),
    );
    expect(tester.widget<EditableText>(_editor).autofillHints, const <String>[
      AutofillHints.username,
    ]);
    expect(
      tester.widget<TextField>(_field).decoration?.hintText,
      'nombre@example.com',
    );

    await tester.pumpWidget(
      _host(
        const DsEmailInputWidget(
          field: ModelFieldState(),
          label: _label,
          onChangedAttempt: _ignore,
          autofillHints: null,
        ),
      ),
    );
    expect(tester.widget<EditableText>(_editor).autofillHints, isNull);
  });

  testWidgets('pastes and submits the email exactly as entered', (
    WidgetTester tester,
  ) async {
    const String raw = '  Nombre+Alias@Example.COM  ';
    const ModelFieldState initial = ModelFieldState();
    final TestDefaultBinaryMessenger messenger =
        tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (
      MethodCall call,
    ) async {
      return call.method == 'Clipboard.getData'
          ? <String, String>{'text': raw}
          : null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final List<ModelFieldState> edits = <ModelFieldState>[];
    final List<ModelFieldState> submissions = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(
        DsEmailInputWidget(
          field: initial,
          label: _label,
          textInputAction: TextInputAction.search,
          onChangedAttempt: edits.add,
          onSubmittedAttempt: submissions.add,
        ),
      ),
    );
    await tester.showKeyboard(_field);
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.textInputAction, TextInputAction.search);
    Actions.invoke(
      editor.focusNode.context!,
      const PasteTextIntent(SelectionChangedCause.keyboard),
    );
    await tester.pumpAndSettle();
    final ModelFieldState proposal = initial.copyWith(
      value: raw,
      isDirty: true,
    );
    expect(editor.controller.text, raw);
    expect(edits, <ModelFieldState>[proposal]);
    expect(submissions, isEmpty);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(submissions, <ModelFieldState>[proposal]);
  });

  testWidgets('a validation update preserves the IME and announces the error', (
    WidgetTester tester,
  ) async {
    const String helper = 'Usa un correo de contacto.';
    const String error = 'Revisa la dirección de correo.';
    const TextEditingValue draft = TextEditingValue(
      text: '  Nombre@Example.COM  ',
      selection: TextSelection(baseOffset: 8, extentOffset: 5),
      composing: TextRange(start: 2, end: 8),
    );
    final List<ModelFieldState> edits = <ModelFieldState>[];
    Future<void> render(ModelFieldState field) => tester.pumpWidget(
      _host(
        DsEmailInputWidget(
          field: field,
          label: _label,
          helperText: helper,
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          onChangedAttempt: edits.add,
        ),
      ),
    );

    await render(const ModelFieldState());
    expect(find.text(helper), findsOneWidget);
    await tester.showKeyboard(_field);
    tester.testTextInput.updateEditingValue(draft);
    await tester.pump();
    expect(edits.single.value, draft.text);

    await render(const ModelFieldState(errorText: error, isValid: false));
    await tester.pumpAndSettle();
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.controller.value, draft);
    expect(editor.focusNode.hasFocus, isTrue);
    expect(edits, hasLength(1));
    expect(find.text(helper), findsNothing);
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

  testWidgets('read-only email can be copied and disabled email skips focus', (
    WidgetTester tester,
  ) async {
    const String address = 'lectura@example.com';
    String? clipboard;
    final TestDefaultBinaryMessenger messenger =
        tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (
      MethodCall call,
    ) async {
      if (call.method == 'Clipboard.setData') {
        clipboard =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    Future<void> render({required bool enabled}) => tester.pumpWidget(
      _host(
        DsEmailInputWidget(
          field: const ModelFieldState(value: address),
          label: _label,
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          enabled: enabled,
          onChangedAttempt: _ignore,
        ),
      ),
    );

    await render(enabled: true);
    final Finder name = find.bySemanticsLabel(_label);
    final SemanticsData data = tester.getSemantics(name).getSemanticsData();
    expect(data.flagsCollection.isReadOnly, isTrue);
    expect(data.hasAction(SemanticsAction.setText), isFalse);
    expect(data.value, address);
    expect(data.hint, 'Solo lectura');
    await tester.tap(_field);
    await tester.pump();
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.focusNode.hasFocus, isTrue);
    editor.controller.selection = const TextSelection.collapsed(offset: 0);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    expect(
      editor.controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: address.length),
    );
    if (kIsWeb) {
      Actions.invoke(editor.focusNode.context!, CopySelectionTextIntent.copy);
    } else {
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(clipboard, address);

    await render(enabled: false);
    await tester.pumpAndSettle();
    final SemanticsData disabled = tester.getSemantics(name).getSemanticsData();
    expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
    expect(editor.focusNode.canRequestFocus, isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}

Widget _host(Widget input) => MaterialApp(home: Scaffold(body: input));

void _ignore(ModelFieldState field) {}
