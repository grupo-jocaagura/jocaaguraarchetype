import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _password = 'Ejemplo-42';
const String _show = 'Mostrar contraseña';
const String _hide = 'Ocultar contraseña';
final Finder _editor = find.byType(EditableText).first;
final Finder _field = find.byType(TextField).first;

void main() {
  testWidgets('uses password keyboard defaults and configurable autofill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        DsPasswordInputWidget(
          field: const ModelFieldState(value: _password),
          label: 'Contraseña',
          onChangedAttempt: (ModelFieldState field) {},
        ),
      ),
    );
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.obscureText, isTrue);
    expect(editor.maxLines, 1);
    expect(editor.keyboardType, TextInputType.visiblePassword);
    expect(editor.autocorrect, isFalse);
    expect(editor.enableSuggestions, isFalse);
    expect(editor.autofillHints, <String>[AutofillHints.password]);

    await tester.pumpWidget(
      _host(_input(autofillHints: const <String>[AutofillHints.newPassword])),
    );
    expect(tester.widget<EditableText>(_editor).autofillHints, <String>[
      AutofillHints.newPassword,
    ]);
    await tester.pumpWidget(_host(_input(autofillHints: null)));
    expect(tester.widget<EditableText>(_editor).autofillHints, isNull);
  });

  testWidgets('visibility preserves the selection and leaves the model alone', (
    WidgetTester tester,
  ) async {
    final List<ModelFieldState> edits = <ModelFieldState>[];
    final List<ModelFieldState> submissions = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(_input(onChanged: edits.add, onSubmitted: submissions.add)),
    );
    await tester.showKeyboard(_field);
    final TextEditingController controller = _state(tester).widget.controller;
    controller.selection = const TextSelection(baseOffset: 2, extentOffset: 7);
    await tester.pump();
    final TextEditingValue original = controller.value;

    final Finder show = find.bySemanticsLabel(_show);
    expect(tester.getSize(show), const Size(48, 48));
    expect(
      tester
          .getSemantics(show)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(show);
    await tester.pump();
    expect(tester.widget<EditableText>(_editor).obscureText, isFalse);
    expect(controller.value, original);
    await tester.tap(find.bySemanticsLabel(_hide));
    await tester.pump();
    expect(tester.widget<EditableText>(_editor).obscureText, isTrue);
    expect(controller.value, original);
    expect(edits, isEmpty);
    expect(submissions, isEmpty);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submissions.single.isDirty, isFalse);
    expect(submissions.single.value, _password);
  });

  testWidgets('Tab moves within the group before leaving and masking', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_input()));
    await tester.tap(find.bySemanticsLabel(_show));
    await tester.pump();
    final EditableText editor = tester.widget<EditableText>(_editor);
    expect(editor.focusNode.hasFocus, isTrue);
    expect(editor.obscureText, isFalse);
    const TextSelection selection = TextSelection(
      baseOffset: 1,
      extentOffset: 5,
    );
    editor.controller.selection = selection;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(editor.focusNode.hasFocus, isFalse);
    expect(tester.widget<EditableText>(_editor).obscureText, isFalse);
    expect(editor.controller.selection, selection);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(tester.widget<EditableText>(_editor).obscureText, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(tester.widget<EditableText>(_editor).obscureText, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(tester.widget<EditableText>(_editor).obscureText, isTrue);
    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .last
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('disabled and read-only mask an already visible password', (
    WidgetTester tester,
  ) async {
    for (final bool readOnly in <bool>[true, false]) {
      await tester.pumpWidget(_host(_input()));
      await tester.tap(find.bySemanticsLabel(_show));
      await tester.pump();
      expect(tester.widget<EditableText>(_editor).obscureText, isFalse);

      await tester.pumpWidget(
        _host(_input(readOnly: readOnly, enabled: readOnly)),
      );
      expect(tester.widget<EditableText>(_editor).obscureText, isTrue);
      expect(find.byType(DsIconButtonWidget), findsNothing);
      expect(_semanticsTree(tester), isNot(contains(_password)));
      if (readOnly) {
        final SemanticsData data = tester
            .getSemantics(find.bySemanticsLabel('Contraseña'))
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.setText), isFalse);
      }
      await tester.pumpWidget(_host(_input()));
      expect(tester.widget<EditableText>(_editor).obscureText, isTrue);
    }
  });

  testWidgets(
    'keeps the password off the clipboard and allows keyboard and menu paste',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          tester.binding.defaultBinaryMessenger;
      final List<String> writes = <String>[];
      messenger.setMockMethodCallHandler(SystemChannels.platform, (
        MethodCall call,
      ) async {
        switch (call.method) {
          case 'Clipboard.setData':
            writes.add(
              (call.arguments as Map<Object?, Object?>)['text']! as String,
            );
          case 'Clipboard.getData':
            return <String, Object?>{'text': 'Texto pegado'};
          case 'Clipboard.hasStrings':
            return <String, Object?>{'value': true};
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final List<ModelFieldState> edits = <ModelFieldState>[];
      await tester.pumpWidget(_host(_input(onChanged: edits.add)));
      await tester.showKeyboard(_field);
      final EditableTextState editor = _state(tester);
      for (final bool hidden in <bool>[true, false]) {
        expect(tester.widget<EditableText>(_editor).obscureText, hidden);
        editor.widget.controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: _password.length,
        );
        await tester.pumpAndSettle();
        if (hidden) {
          expect(_semanticsTree(tester), isNot(contains(_password)));
        }
        final SemanticsData data = tester
            .getSemantics(_editor)
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.copy), isFalse);
        expect(data.hasAction(SemanticsAction.cut), isFalse);
        expect(data.hasAction(SemanticsAction.paste), isTrue);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        expect(writes, isEmpty);
        expect(edits, isEmpty);
        expect(editor.widget.controller.text, _password);
        if (hidden) {
          final SemanticsNode node = tester.getSemantics(_editor);
          node.owner!.performAction(node.id, SemanticsAction.paste);
          await tester.pumpAndSettle();
          expect(edits.single.value, 'Texto pegado');
          expect(edits.single.isDirty, isTrue);
          editor.widget.controller.text = _password;
          edits.clear();
          await tester.tap(find.bySemanticsLabel(_show));
          await tester.pumpAndSettle();
        }
      }

      expect(editor.showToolbar(), isTrue);
      await tester.pumpAndSettle();
      final AdaptiveTextSelectionToolbar toolbar = tester
          .widget<AdaptiveTextSelectionToolbar>(
            find.byType(AdaptiveTextSelectionToolbar),
          );
      final List<ContextMenuButtonType> buttons = toolbar.buttonItems!
          .map((ContextMenuButtonItem button) => button.type)
          .toList();
      expect(buttons, contains(ContextMenuButtonType.paste));
      expect(buttons, isNot(contains(ContextMenuButtonType.copy)));
      expect(buttons, isNot(contains(ContextMenuButtonType.cut)));
      await tester.tap(
        find.descendant(
          of: find.byType(AdaptiveTextSelectionToolbar),
          matching: find.text('Paste'),
        ),
      );
      await tester.pumpAndSettle();
      expect(edits.single.value, 'Texto pegado');
      expect(edits.single.isDirty, isTrue);
      expect(editor.widget.controller.text, 'Texto pegado');

      editor.widget.controller.text = _password;
      editor.widget.controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: _password.length,
      );
      edits.clear();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(edits.single.value, 'Texto pegado');
      expect(edits.single.isDirty, isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('consumer error replaces helper and keeps password hidden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_input()));
    expect(find.text('Usa una contraseña de ejemplo.'), findsOneWidget);
    await tester.pumpWidget(
      _host(
        _input(
          field: const ModelFieldState(
            value: _password,
            isValid: false,
            errorText: 'Agrega otro carácter.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Usa una contraseña de ejemplo.'), findsNothing);
    expect(find.text('Agrega otro carácter.'), findsOneWidget);
    expect(tester.widget<EditableText>(_editor).obscureText, isTrue);
  });
}

EditableTextState _state(WidgetTester tester) =>
    tester.state<EditableTextState>(_editor);

String _semanticsTree(WidgetTester tester) => tester
    .binding
    .renderViews
    .single
    .owner!
    .semanticsOwner!
    .rootSemanticsNode!
    .toStringDeep();

Widget _host(DsPasswordInputWidget input) => MaterialApp(
  home: Scaffold(body: Column(children: <Widget>[input, const TextField()])),
);

DsPasswordInputWidget _input({
  ModelFieldState field = const ModelFieldState(value: _password),
  bool enabled = true,
  bool readOnly = false,
  Iterable<String>? autofillHints = const <String>[AutofillHints.password],
  ValueChanged<ModelFieldState>? onChanged,
  ValueChanged<ModelFieldState>? onSubmitted,
}) => DsPasswordInputWidget(
  field: field,
  label: 'Contraseña',
  helperText: 'Usa una contraseña de ejemplo.',
  enabled: enabled,
  readOnly: readOnly,
  autofillHints: autofillHints,
  showPasswordLabel: _show,
  hidePasswordLabel: _hide,
  onChangedAttempt: onChanged ?? (_) {},
  onSubmittedAttempt: onSubmitted,
);
