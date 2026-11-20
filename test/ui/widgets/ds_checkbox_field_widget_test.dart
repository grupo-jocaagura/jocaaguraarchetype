import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Acepto los términos';
final Finder _name = find.bySemanticsLabel(_label);
final Finder _tile = find.byType(CheckboxListTile);
final Finder _checkbox = find.byType(Checkbox);

void main() {
  testWidgets(
    'Given stored values When rendered Then only canonical true is checked',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      for (final String value in <String>[
        'true',
        'false',
        '',
        ' TRUE ',
        'true ',
        '1',
      ]) {
        await tester.pumpWidget(
          _host(
            _field(
              field: ModelFieldState(value: value),
              onChangedAttempt: attempts.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(_checkbox).value, value == 'true');
        expect(
          tester
              .getSemantics(_name)
              .getSemanticsData()
              .flagsCollection
              .isChecked,
          value == 'true' ? CheckedState.isTrue : CheckedState.isFalse,
        );
      }
      expect(attempts, isEmpty);
    },
  );

  testWidgets(
    'Given an unchecked field When tapping anywhere in the tile Then proposes once',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      const ModelFieldState initial = ModelFieldState(
        value: ' TRUE ',
        errorText: 'Confirma el acuerdo.',
        isValid: false,
        suggestions: <String>['true'],
      );
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_field(field: field, onChangedAttempt: attempts.add)),
        );
        await tester.pumpAndSettle();
      }

      await render(initial);
      final ModelFieldState checked = initial.copyWith(
        value: 'true',
        isDirty: true,
      );
      await tester.tap(_checkbox);
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[checked]);
      expect(tester.widget<Checkbox>(_checkbox).value, isFalse);

      await tester.tap(find.text(_label));
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[checked, checked]);
      expect(tester.widget<Checkbox>(_checkbox).value, isFalse);

      await render(checked);
      expect(tester.widget<Checkbox>(_checkbox).value, isTrue);
      final Rect bounds = tester.getRect(_tile);
      expect(bounds.height, greaterThanOrEqualTo(48));
      await tester.tapAt(bounds.bottomRight - const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[
        checked,
        checked,
        checked.copyWith(value: 'false'),
      ]);
      expect(tester.widget<Checkbox>(_checkbox).value, isTrue);
    },
  );

  testWidgets(
    'Given a required choice When validation changes Then announces one checkbox with the latest message',
    (WidgetTester tester) async {
      const String help = 'Marca la casilla si estás de acuerdo.';
      const String error = 'Debes aceptar las condiciones.';
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_field(field: field, required: true, helperText: help)),
        );
        await tester.pumpAndSettle();
      }

      await render(const ModelFieldState());
      expect(find.text('$_label *'), findsOneWidget);
      expect(find.text(help), findsOneWidget);
      expect(_name, findsOneWidget);
      expect(tester.getSemantics(_name).hint, 'Obligatorio\n$help');

      await render(const ModelFieldState(errorText: error, isValid: false));
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      expect(find.bySemanticsLabel(error), findsNothing);
      expect(tester.widget<Checkbox>(_checkbox).isError, isTrue);
      expect(
        find.semantics.byPredicate(
          (SemanticsNode node) =>
              !node.isMergedIntoParent &&
              node.getSemanticsData().flagsCollection.isChecked !=
                  CheckedState.none,
        ),
        findsOne,
      );
      final SemanticsData data = tester.getSemantics(_name).getSemanticsData();
      expect(data.flagsCollection.isRequired, Tristate.isTrue);
      expect(data.flagsCollection.isChecked, CheckedState.isFalse);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.hint, 'Obligatorio\n$error');
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await render(const ModelFieldState());
      expect(tester.widget<Checkbox>(_checkbox).isError, isFalse);
      expect(find.text(help), findsOneWidget);
    },
  );

  testWidgets(
    'Given keyboard or assistive input When activating Then proposes just once',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(_field(onChangedAttempt: attempts.add), withNext: true),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(_name).flagsCollection.isFocused,
        Tristate.isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(attempts.map((ModelFieldState attempt) => attempt.value), <String>[
        'true',
      ]);

      tester.semantics.tap(find.semantics.byLabel(_label));
      await tester.pumpAndSettle();
      expect(attempts.map((ModelFieldState attempt) => attempt.value), <String>[
        'true',
        'true',
      ]);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Siguiente'))
            .flagsCollection
            .isFocused,
        Tristate.isTrue,
      );
    },
  );

  for (final (bool enabled, bool readOnly, String value)
      in <(bool, bool, String)>[
        (true, true, 'true'),
        (false, false, 'false'),
        (false, true, 'true'),
      ]) {
    testWidgets(
      'Given enabled=$enabled and readOnly=$readOnly When activated Then leaves the accepted value',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(
          _host(
            _field(
              field: ModelFieldState(value: value),
              enabled: enabled,
              readOnly: readOnly,
              onChangedAttempt: attempts.add,
            ),
            withNext: true,
          ),
        );

        final SemanticsData data = tester
            .getSemantics(_name)
            .getSemanticsData();
        expect(
          data.flagsCollection.isChecked,
          value == 'true' ? CheckedState.isTrue : CheckedState.isFalse,
        );
        expect(
          data.flagsCollection.isEnabled,
          enabled ? Tristate.isTrue : Tristate.isFalse,
        );
        expect(data.hint, enabled && readOnly ? 'Solo lectura' : '');
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        await tester.tap(find.text(_label));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Siguiente'))
              .flagsCollection
              .isFocused,
          Tristate.isTrue,
        );
        expect(attempts, isEmpty);
        expect(tester.widget<Checkbox>(_checkbox).value, value == 'true');
      },
    );
  }

  testWidgets(
    'Given a narrow field at 200% When rendering Then wraps both the label and error',
    (WidgetTester tester) async {
      const String label = 'Acepto los términos y condiciones del servicio';
      const String error = 'Marca la casilla para continuar con la solicitud.';
      await tester.pumpWidget(
        _host(
          _field(
            label: label,
            field: const ModelFieldState(errorText: error, isValid: false),
          ),
          width: 240,
          textScaler: const TextScaler.linear(2),
        ),
      );

      final Rect bounds = tester.getRect(_tile);
      for (final String text in <String>[label, error]) {
        final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
          find.text(text),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          paragraph.size.height,
          greaterThan(paragraph.text.style!.fontSize! * 2),
        );
        final Rect textBounds = tester.getRect(find.text(text));
        expect(bounds.contains(textBounds.topLeft), isTrue);
        expect(textBounds.bottom, lessThanOrEqualTo(bounds.bottom));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Given a blank label When built Then rejects it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: _field(label: '  ')),
      ),
    );
    expect(
      tester.takeException(),
      isA<ArgumentError>().having(
        (ArgumentError error) => error.name,
        'name',
        'label',
      ),
    );
  });
}

DsCheckboxFieldWidget _field({
  ModelFieldState field = const ModelFieldState(),
  String label = _label,
  String? helperText,
  bool required = false,
  bool enabled = true,
  bool readOnly = false,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
}) => DsCheckboxFieldWidget(
  field: field,
  label: label,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                child,
                if (withNext)
                  TextButton(onPressed: () {}, child: const Text('Siguiente')),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);

void _ignore(ModelFieldState field) {}
