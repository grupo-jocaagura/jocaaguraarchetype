import 'dart:ui' show CheckedState, SemanticsRole, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Tipo de movimiento';
const List<String> _options = <String>['income', 'expense'];
final Finder _rows = find.byType(RadioListTile<String>);
final Finder _name = find.bySemanticsLabel(_label);

void main() {
  testWidgets(
    'Given a controlled selection When choosing another option Then proposes its key once',
    (WidgetTester tester) async {
      const ModelFieldState initial = ModelFieldState(
        value: 'income',
        isValid: false,
        errorText: 'Verifica el movimiento.',
        suggestions: <String>['expense'],
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
      expect(_rows, findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text('Ingreso')).dy,
        lessThan(tester.getTopLeft(find.text('Gasto')).dy),
      );
      expect(_state(tester, 'Ingreso').isChecked, CheckedState.isTrue);
      expect(_state(tester, 'Gasto').isChecked, CheckedState.isFalse);
      await tester.tap(find.text('Ingreso'));
      await tester.pumpAndSettle();
      expect(attempts, isEmpty);

      final Rect row = tester.getRect(_rows.last);
      expect(row.height, greaterThanOrEqualTo(48));
      final Finder radio = find.descendant(
        of: _rows.last,
        matching: find.byType(Radio<String>),
      );
      expect(
        tester.getRect(radio).right,
        lessThan(tester.getRect(find.text('Gasto')).left),
      );
      await tester.tapAt(row.bottomRight - const Offset(2, 2));
      await tester.pumpAndSettle();
      final ModelFieldState proposal = initial.copyWith(
        value: 'expense',
        isDirty: true,
      );
      expect(attempts, <ModelFieldState>[proposal]);
      expect(_state(tester, 'Ingreso').isChecked, CheckedState.isTrue);
      expect(_state(tester, 'Gasto').isChecked, CheckedState.isFalse);

      await render(proposal);
      expect(_state(tester, 'Ingreso').isChecked, CheckedState.isFalse);
      expect(_state(tester, 'Gasto').isChecked, CheckedState.isTrue);
      await tester.tap(radio);
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[proposal]);

      await render(proposal, options: const <String>['income']);
      expect(_state(tester, 'Ingreso').isChecked, CheckedState.isFalse);
      expect(attempts, <ModelFieldState>[proposal]);
      await render(proposal);
      expect(_state(tester, 'Gasto').isChecked, CheckedState.isTrue);
    },
  );

  testWidgets(
    'Given no options When built Then names the empty state and skips it on Tab',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(options: const <String>[], onChangedAttempt: attempts.add),
          withNext: true,
        ),
      );

      expect(find.text(_label), findsOneWidget);
      expect(find.text('Sin opciones disponibles'), findsOneWidget);
      expect(_rows, findsNothing);
      expect(tester.getSemantics(_name).hint, 'Sin opciones disponibles');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Siguiente').isFocused, Tristate.isTrue);
      expect(attempts, isEmpty);
    },
  );

  testWidgets(
    'Given a required group When invalid Then one named group announces its error',
    (WidgetTester tester) async {
      const String help = 'Elige la opción que corresponda.';
      const String error = 'Selecciona un tipo de movimiento.';
      Future<void> render(ModelFieldState field) => tester.pumpWidget(
        _host(_field(field: field, helperText: help, required: true)),
      );

      await render(const ModelFieldState());
      expect(find.text('$_label *'), findsOneWidget);
      expect(find.text(help), findsOneWidget);
      expect(_state(tester, 'Ingreso').isChecked, CheckedState.isFalse);
      expect(_state(tester, 'Gasto').isChecked, CheckedState.isFalse);
      expect(tester.getSemantics(_name).hint, 'Obligatorio\n$help');

      await render(const ModelFieldState(errorText: error, isValid: false));
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      expect(find.bySemanticsLabel(error), findsNothing);
      final SemanticsData group = tester.getSemantics(_name).getSemanticsData();
      expect(
        find.semantics.byPredicate(
          (SemanticsNode node) =>
              node.getSemanticsData().role == SemanticsRole.radioGroup,
        ),
        findsOne,
      );
      expect(group.role, SemanticsRole.radioGroup);
      expect(group.label, _label);
      expect(group.flagsCollection.isRequired, Tristate.isTrue);
      expect(group.validationResult, SemanticsValidationResult.invalid);
      expect(group.hint, 'Obligatorio\n$error');
      for (final String option in <String>['Ingreso', 'Gasto']) {
        expect(find.semantics.byLabel(option), findsOne);
        expect(_state(tester, option).isInMutuallyExclusiveGroup, isTrue);
      }
    },
  );

  testWidgets(
    'Given keyboard focus When pressing Space or arrows Then proposes the focused option and Tab exits',
    (WidgetTester tester) async {
      ModelFieldState form = const ModelFieldState();
      final List<String> attempts = <String>[];
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => _field(
              field: form,
              onChangedAttempt: (ModelFieldState next) {
                attempts.add(next.value);
                setState(() => form = next);
              },
            ),
          ),
          withNext: true,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Ingreso').isFocused, Tristate.isTrue);
      expect(attempts, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(attempts, <String>['income']);
      expect(_state(tester, 'Ingreso').isChecked, CheckedState.isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Gasto').isFocused, Tristate.isTrue);
      expect(_state(tester, 'Gasto').isChecked, CheckedState.isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Ingreso').isFocused, Tristate.isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Gasto').isFocused, Tristate.isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(attempts, <String>['income', 'expense', 'income', 'expense']);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Siguiente').isFocused, Tristate.isTrue);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(_state(tester, 'Gasto').isFocused, Tristate.isTrue);
    },
  );

  for (final (bool enabled, bool readOnly) in <(bool, bool)>[
    (true, true),
    (false, false),
    (false, true),
  ]) {
    testWidgets(
      'Given enabled=$enabled and readOnly=$readOnly When interacting Then leaves the value',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(
          _host(
            _field(
              field: const ModelFieldState(value: 'income'),
              enabled: enabled,
              readOnly: readOnly,
              onChangedAttempt: attempts.add,
            ),
            withNext: true,
          ),
        );
        expect(
          tester.getSemantics(_name).hint,
          enabled && readOnly ? 'Solo lectura' : '',
        );
        final SemanticsData other = tester
            .getSemantics(find.bySemanticsLabel('Gasto'))
            .getSemanticsData();
        expect(other.hasAction(SemanticsAction.tap), isFalse);
        expect(other.flagsCollection.isEnabled, Tristate.isFalse);
        await tester.tap(find.text('Gasto'));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(_state(tester, 'Siguiente').isFocused, Tristate.isTrue);
        expect(_state(tester, 'Ingreso').isChecked, CheckedState.isTrue);
        expect(attempts, isEmpty);
      },
    );
  }

  testWidgets(
    'Given text at 200% When rendering in a narrow form Then shows the full option and error',
    (WidgetTester tester) async {
      const String option = 'Resumen de todas las operaciones al final del día';
      const String error = 'Selecciona cuándo quieres recibir los avisos.';
      await tester.pumpWidget(
        _host(
          _field(
            options: const <String>[option],
            optionLabelBuilder: null,
            field: const ModelFieldState(errorText: error, isValid: false),
          ),
          width: 240,
          textScaler: const TextScaler.linear(2),
        ),
      );
      for (final String caption in <String>[option, error]) {
        final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
          find.text(caption),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          paragraph.size.height,
          greaterThan(paragraph.text.style!.fontSize! * 2),
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Given invalid configuration When built Then rejects it', (
    WidgetTester tester,
  ) async {
    for (final (String name, DsRadioGroupFieldWidget field)
        in <(String, DsRadioGroupFieldWidget)>[
          ('label', _field(label: ' ')),
          ('options', _field(options: const <String>[''])),
          ('options', _field(options: const <String>['income', 'income'])),
          ('optionLabelBuilder', _field(optionLabelBuilder: (_) => ' ')),
          (
            'emptyMessage',
            _field(options: const <String>[], emptyMessage: ' '),
          ),
        ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: field)));
      expect(
        tester.takeException(),
        isA<ArgumentError>().having(
          (ArgumentError error) => error.name,
          'name',
          name,
        ),
      );
    }
  });
}

SemanticsFlags _state(WidgetTester tester, String label) => tester
    .getSemantics(find.bySemanticsLabel(label))
    .getSemanticsData()
    .flagsCollection;

DsRadioGroupFieldWidget _field({
  ModelFieldState field = const ModelFieldState(),
  List<String> options = _options,
  String Function(String)? optionLabelBuilder = _optionLabel,
  String label = _label,
  String emptyMessage = 'Sin opciones disponibles',
  String? helperText,
  bool required = false,
  bool enabled = true,
  bool readOnly = false,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
}) => DsRadioGroupFieldWidget(
  field: field,
  options: options,
  optionLabelBuilder: optionLabelBuilder,
  label: label,
  emptyMessage: emptyMessage,
  helperText: helperText,
  required: required,
  enabled: enabled,
  readOnly: readOnly,
  requiredSemanticLabel: 'Obligatorio',
  readOnlySemanticLabel: 'Solo lectura',
  onChangedAttempt: onChangedAttempt,
);

Widget _host(
  Widget child, {
  bool withNext = false,
  double width = 360,
  TextScaler? textScaler,
}) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (BuildContext context) => Center(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  child,
                  if (withNext)
                    TextButton(
                      onPressed: () {},
                      child: const Text('Siguiente'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

String _optionLabel(String key) => key == 'income' ? 'Ingreso' : 'Gasto';

void _ignore(ModelFieldState field) {}
