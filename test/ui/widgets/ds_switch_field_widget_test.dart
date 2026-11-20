import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Activar avisos';
final Finder _name = find.bySemanticsLabel(_label);
final Finder _switch = find.byType(Switch);
final Finder _tile = find.byType(SwitchListTile);

void main() {
  testWidgets(
    'Given stored values When rendered Then only canonical true is on',
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
        expect(tester.widget<Switch>(_switch).value, value == 'true');
        expect(
          tester
              .getSemantics(_name)
              .getSemanticsData()
              .flagsCollection
              .isToggled,
          value == 'true' ? Tristate.isTrue : Tristate.isFalse,
        );
      }
      expect(attempts, isEmpty);
    },
  );

  testWidgets(
    'Given a controlled switch When tapping the control or row Then proposes once per tap',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      const ModelFieldState initial = ModelFieldState(
        value: ' TRUE ',
        isValid: false,
        errorText: 'Activa los avisos para continuar.',
        suggestions: <String>['true'],
      );
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_field(field: field, onChangedAttempt: attempts.add)),
        );
        await tester.pumpAndSettle();
      }

      await render(initial);
      final ModelFieldState on = initial.copyWith(value: 'true', isDirty: true);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[on]);
      expect(tester.widget<Switch>(_switch).value, isFalse);

      await tester.tap(find.text(_label));
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[on, on]);
      expect(tester.widget<Switch>(_switch).value, isFalse);

      await render(on);
      final Rect bounds = tester.getRect(_tile);
      expect(bounds.height, greaterThanOrEqualTo(48));
      await tester.tapAt(bounds.bottomLeft + const Offset(2, -2));
      await tester.pumpAndSettle();
      expect(attempts, <ModelFieldState>[on, on, on.copyWith(value: 'false')]);
      expect(tester.widget<Switch>(_switch).value, isTrue);
    },
  );

  for (final TextDirection direction in TextDirection.values) {
    testWidgets(
      'Given a trailing switch in ${direction.name} When dragging Then proposes only a different value',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(
          _host(_field(onChangedAttempt: attempts.add), direction: direction),
        );
        final Rect control = tester.getRect(_switch);
        final Rect tile = tester.getRect(_tile);
        final bool ltr = direction == TextDirection.ltr;
        expect(
          control.center.dx,
          ltr ? greaterThan(tile.center.dx) : lessThan(tile.center.dx),
        );
        final double forward = ltr ? 1 : -1;

        final TestGesture returning = await tester.startGesture(control.center);
        await returning.moveBy(Offset(24 * forward, 0));
        await returning.moveBy(Offset(32 * forward, 0));
        await returning.moveBy(Offset(-32 * forward, 0));
        await returning.up();
        await tester.pumpAndSettle();
        expect(attempts, isEmpty);

        final TestGesture changing = await tester.startGesture(control.center);
        await changing.moveBy(Offset(24 * forward, 0));
        await changing.moveBy(Offset(32 * forward, 0));
        expect(attempts, isEmpty);
        await changing.up();
        await tester.pumpAndSettle();
        expect(attempts, const <ModelFieldState>[
          ModelFieldState(value: 'true', isDirty: true),
        ]);
        expect(tester.widget<Switch>(_switch).value, isFalse);
      },
    );
  }

  testWidgets(
    'Given validation When the field rebuilds Then one switch exposes the error in place of help',
    (WidgetTester tester) async {
      const String help = 'Puedes cambiar la preferencia más tarde.';
      const String error = 'Activa los avisos para continuar.';
      Future<void> render(ModelFieldState field) => tester.pumpWidget(
        _host(_field(field: field, helperText: help, required: true)),
      );

      await render(const ModelFieldState());
      expect(find.text('$_label *'), findsOneWidget);
      expect(find.text(help), findsOneWidget);
      expect(tester.getSemantics(_name).hint, 'Obligatorio\n$help');

      await render(const ModelFieldState(errorText: error, isValid: false));
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      expect(find.bySemanticsLabel(error), findsNothing);
      expect(
        find.semantics.byPredicate(
          (SemanticsNode node) =>
              !node.isMergedIntoParent &&
              node.getSemanticsData().flagsCollection.isToggled !=
                  Tristate.none,
        ),
        findsOne,
      );
      final SemanticsData data = tester.getSemantics(_name).getSemanticsData();
      expect(data.flagsCollection.isRequired, Tristate.isTrue);
      expect(data.flagsCollection.isToggled, Tristate.isFalse);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.hint, 'Obligatorio\n$error');
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(
        tester.widget<Text>(find.text(error)).style?.color,
        Theme.of(tester.element(_tile)).colorScheme.error,
      );
    },
  );

  testWidgets(
    'Given keyboard and assistive input When activating Then proposes once per action',
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
      expect(attempts, hasLength(1));

      tester.semantics.tap(find.semantics.byLabel(_label));
      await tester.pumpAndSettle();
      expect(attempts, hasLength(2));
      expect(
        attempts.every(
          (ModelFieldState state) => state.value == 'true' && state.isDirty,
        ),
        isTrue,
      );

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

  for (final (bool enabled, bool readOnly, bool active) in <(bool, bool, bool)>[
    (true, true, true),
    (false, false, true),
    (false, true, false),
  ]) {
    testWidgets(
      'Given enabled=$enabled and readOnly=$readOnly When interacting Then keeps the accepted state',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(
          _host(
            _field(
              field: ModelFieldState(value: active.toString()),
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
          data.flagsCollection.isToggled,
          active ? Tristate.isTrue : Tristate.isFalse,
        );
        expect(data.hint, enabled && readOnly ? 'Solo lectura' : '');
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        await tester.tap(find.text(_label));
        await tester.drag(_switch, Offset(active ? -56 : 56, 0));
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
        expect(tester.widget<Switch>(_switch).value, active);
      },
    );
  }

  testWidgets(
    'Given a narrow field at 200% When rendered Then shows the full label and error',
    (WidgetTester tester) async {
      const String label = 'Activar avisos de seguridad para esta cuenta';
      const String error = 'Activa los avisos para poder continuar.';
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
        final Finder caption = find.text(text);
        final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
          caption,
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          paragraph.size.height,
          greaterThan(paragraph.text.style!.fontSize! * 2),
        );
        expect(
          tester.getRect(caption).bottom,
          lessThanOrEqualTo(bounds.bottom),
        );
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

DsSwitchFieldWidget _field({
  ModelFieldState field = const ModelFieldState(),
  String label = _label,
  String? helperText,
  bool required = false,
  bool enabled = true,
  bool readOnly = false,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
}) => DsSwitchFieldWidget(
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
  TextDirection direction = TextDirection.ltr,
  TextScaler? textScaler,
}) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (BuildContext context) => Center(
        child: Directionality(
          textDirection: direction,
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
  ),
);

void _ignore(ModelFieldState field) {}
