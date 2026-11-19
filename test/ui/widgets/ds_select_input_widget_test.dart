import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'proposes a localized choice without changing the accepted field',
    (WidgetTester tester) async {
      const ModelFieldState initial = ModelFieldState(
        errorText: 'Confirma el documento.',
        isValid: false,
        suggestions: <String>['id_card'],
      );
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      Future<void> render(
        ModelFieldState field, {
        List<String> options = _options,
      }) => tester.pumpWidget(
        _host(
          _field(
            field: field,
            options: options,
            onChangedAttempt: attempts.add,
          ),
        ),
      );

      await render(initial);
      expect(find.text('Selecciona un tipo'), findsOneWidget);
      await _open(tester);
      expect(_menuText('Cédula'), findsOneWidget);
      expect(_menuText('id_card'), findsNothing);
      await tester.tap(_menuText('Pasaporte'));
      await tester.pumpAndSettle();

      final ModelFieldState proposal = initial.copyWith(
        value: 'passport',
        isDirty: true,
      );
      expect(attempts, <ModelFieldState>[proposal]);
      expect(find.text('Selecciona un tipo'), findsOneWidget);
      expect(tester.widget<DropdownButton<String>>(_trigger).value, isNull);

      await render(proposal);
      expect(find.text('Pasaporte'), findsOneWidget);
      expect(tester.widget<DropdownButton<String>>(_trigger).value, 'passport');
      await _open(tester);
      await tester.tap(_menuText('Pasaporte'));
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[proposal]);

      await render(proposal, options: const <String>['id_card']);
      expect(find.text('Selecciona un tipo'), findsOneWidget);
      expect(attempts, <ModelFieldState>[proposal]);
    },
  );

  testWidgets('uses the key by default and rejects blank and duplicate keys', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _field(
          field: const ModelFieldState(value: 'id_card'),
          optionLabelBuilder: null,
        ),
      ),
    );
    expect(find.text('id_card'), findsOneWidget);

    for (final List<String> options in const <List<String>>[
      <String>[''],
      <String>['id_card', 'id_card'],
    ]) {
      await tester.pumpWidget(_host(_field(options: options)));
      expect(tester.takeException(), isArgumentError);
    }
  });

  testWidgets(
    'the error replaces helper text and the required name stays unified',
    (WidgetTester tester) async {
      const String helper = 'Elige el documento que vas a presentar.';
      const String error = 'El tipo de documento es obligatorio.';
      const String announcement = 'Tipo de documento\nSelecciona un tipo';
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_field(field: field, helperText: helper, required: true)),
        );
        await tester.pumpAndSettle();
      }

      await render(const ModelFieldState());
      expect(find.text(helper), findsOneWidget);
      expect(find.text('Tipo de documento *'), findsOneWidget);
      final Finder name = find.bySemanticsLabel(announcement);
      expect(name, findsOneWidget);
      expect(find.bySemanticsLabel('Tipo de documento'), findsNothing);
      expect(find.bySemanticsLabel('Selecciona un tipo'), findsNothing);
      expect(
        tester.getSemantics(name).flagsCollection.isRequired,
        Tristate.isTrue,
      );

      await render(const ModelFieldState(errorText: error, isValid: false));
      expect(find.text(helper), findsNothing);
      expect(find.text(error), findsOneWidget);
      expect(name, findsOneWidget);
      final SemanticsData data = tester.getSemantics(name).getSemanticsData();
      expect(data.flagsCollection.isRequired, Tristate.isTrue);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(
        data.hint.split('\n'),
        unorderedEquals(<String>[error, 'Obligatorio']),
      );
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await render(const ModelFieldState());
      expect(find.text(error), findsNothing);
      expect(find.text(helper), findsOneWidget);
    },
  );

  testWidgets(
    'read-only and disabled fields keep the value and block an open menu',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      Future<void> render({bool enabled = true, bool readOnly = false}) =>
          tester.pumpWidget(
            _host(
              _field(
                field: const ModelFieldState(value: 'passport'),
                onChangedAttempt: attempts.add,
                enabled: enabled,
                readOnly: readOnly,
              ),
            ),
          );
      for (final (bool enabled, bool readOnly) in const <(bool, bool)>[
        (true, true),
        (false, false),
        (false, true),
      ]) {
        await render();
        await _open(tester);
        await render(enabled: enabled, readOnly: readOnly);
        await tester.tap(_menuText('Cédula'));
        await tester.pumpAndSettle();

        final InputDecorator decorator = tester.widget<InputDecorator>(
          find.byType(InputDecorator),
        );
        expect(decorator.decoration.enabled, enabled);
        expect(find.text('Pasaporte'), findsOneWidget);
        expect(
          find.byIcon(Icons.lock_outline),
          enabled && readOnly ? findsOneWidget : findsNothing,
        );
        final SemanticsData data = tester
            .getSemantics(find.bySemanticsLabel('Tipo de documento\nPasaporte'))
            .getSemanticsData();
        expect(data.flagsCollection.isReadOnly, enabled && readOnly);
        expect(data.hint, enabled && readOnly ? 'Solo lectura' : '');
        expect(data.flagsCollection.isEnabled, Tristate.isFalse);
        expect(data.hasAction(SemanticsAction.tap), isFalse);

        await tester.tap(_trigger);
        await tester.pumpAndSettle();
        expect(_menuText('Cédula'), findsNothing);
        expect(attempts, isEmpty);
      }
    },
  );

  testWidgets('keyboard navigation returns focus to the outlined field', (
    WidgetTester tester,
  ) async {
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(
        _field(
          field: const ModelFieldState(value: 'id_card'),
          onChangedAttempt: attempts.add,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final FocusNode focus = FocusManager.instance.primaryFocus!;
    expect(
      tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
      isTrue,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_menuText('Pasaporte'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(focus.hasPrimaryFocus, isTrue);
    expect(attempts, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(attempts, const <ModelFieldState>[
      ModelFieldState(value: 'passport', isDirty: true),
    ]);
    expect(focus.hasPrimaryFocus, isTrue);
  });

  testWidgets('options wrap at 200 percent in both the field and menu', (
    WidgetTester tester,
  ) async {
    const String caption = 'Documento de identidad para residentes extranjeros';
    await tester.pumpWidget(
      _host(
        _field(
          field: const ModelFieldState(value: 'id_card'),
          optionLabelBuilder: (String option) =>
              option == 'id_card' ? caption : 'Pasaporte',
        ),
        width: 210,
        scaler: const TextScaler.linear(2),
        scrollable: true,
      ),
    );
    final Size triggerSize = tester.getSize(_trigger);
    expect(triggerSize.width, greaterThanOrEqualTo(48));
    expect(triggerSize.height, greaterThan(48));
    _expectWrapped(tester, find.text(caption), caption);

    await _open(tester);
    final Finder item = _menuText(caption);
    _expectWrapped(tester, item, caption);
    final Finder row = find.ancestor(of: item, matching: find.byType(InkWell));
    expect(tester.getSize(row).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
  });
}

const List<String> _options = <String>['id_card', 'passport'];
final Finder _trigger = find.byType(DropdownButton<String>);

DsSelectInputWidget _field({
  ModelFieldState field = const ModelFieldState(),
  List<String> options = _options,
  String Function(String key)? optionLabelBuilder = _documentLabel,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
  String? helperText,
  bool required = false,
  bool enabled = true,
  bool readOnly = false,
}) => DsSelectInputWidget(
  field: field,
  onChangedAttempt: onChangedAttempt,
  options: options,
  label: 'Tipo de documento',
  placeholder: 'Selecciona un tipo',
  optionLabelBuilder: optionLabelBuilder,
  helperText: helperText,
  required: required,
  enabled: enabled,
  readOnly: readOnly,
  requiredSemanticLabel: 'Obligatorio',
  readOnlySemanticLabel: 'Solo lectura',
);

Widget _host(
  Widget child, {
  double width = 340,
  TextScaler? scaler,
  bool scrollable = false,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: scrollable
              ? SingleChildScrollView(
                  child: SizedBox(width: width, child: child),
                )
              : SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(_trigger);
  await tester.pumpAndSettle();
}

Finder _menuText(String label) =>
    find.descendant(of: find.byType(ListView), matching: find.text(label));

void _expectWrapped(WidgetTester tester, Finder text, String caption) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(text);
  final List<TextBox> boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: caption.length),
  );
  expect(paragraph.textScaler.scale(10), 20);
  expect(boxes.map((TextBox box) => box.top).toSet().length, greaterThan(1));
  expect(boxes.last.bottom, lessThanOrEqualTo(paragraph.size.height));
}

String _documentLabel(String key) => key == 'id_card' ? 'Cédula' : 'Pasaporte';

void _ignore(ModelFieldState next) {}
