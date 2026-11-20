import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Capacidades';
const List<String> _options = <String>['catalog', 'inventory', 'reports'];
final Finder _chips = find.byType(FilterChip);
final Finder _group = find.bySemanticsLabel(_label);

void main() {
  testWidgets(
    'Given persisted values When displayed Then requires a JSON array of strings',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      for (final String value in <String>[
        '',
        '[]',
        'catalog',
        '"catalog"',
        '{"catalog":true}',
        '["catalog",17]',
        '["catalog"',
      ]) {
        await tester.pumpWidget(
          _host(
            _field(
              field: ModelFieldState(value: value),
              onChangedAttempt: attempts.add,
            ),
          ),
        );
        expect(
          tester
              .widgetList<FilterChip>(_chips)
              .every((FilterChip chip) => !chip.selected),
          isTrue,
        );
      }
      expect(attempts, isEmpty);
      await tester.tap(find.text('Inventario'));
      await tester.pumpAndSettle();
      expect(attempts.single.value, '["inventory"]');
      expect(_chip(tester, 'inventory').selected, isFalse);
    },
  );

  testWidgets(
    'Given stored duplicates and absent keys When changing a chip Then preserves the remaining order',
    (WidgetTester tester) async {
      const ModelFieldState initial = ModelFieldState(
        value: '["reports","archived","catalog","reports","archived"]',
        isValid: false,
        errorText: 'Verifica las capacidades.',
        suggestions: <String>['inventory'],
      );
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      Future<void> render(
        ModelFieldState field, {
        List<String> options = _options,
      }) async {
        await tester.pumpWidget(
          _host(
            _field(
              field: field,
              options: options,
              onChangedAttempt: attempts.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await render(initial);
      expect(
        tester
            .widgetList<FilterChip>(_chips)
            .map((FilterChip chip) => (chip.key! as ValueKey<String>).value),
        _options,
      );
      expect(find.text('archived'), findsNothing);
      expect(_chip(tester, 'catalog').selected, isTrue);
      expect(_chip(tester, 'reports').selected, isTrue);
      expect(_chip(tester, 'inventory').selected, isFalse);

      await tester.tap(find.text('Inventario'));
      await tester.pumpAndSettle();
      final ModelFieldState added = initial.copyWith(
        value: '["reports","archived","catalog","inventory"]',
        isDirty: true,
      );
      expect(attempts, <ModelFieldState>[added]);
      expect(_chip(tester, 'inventory').selected, isFalse);

      await render(added, options: const <String>['catalog', 'inventory']);
      expect(_chip(tester, 'inventory').selected, isTrue);
      await tester.tap(find.text('Catálogo'));
      await tester.pumpAndSettle();
      final ModelFieldState removed = added.copyWith(
        value: '["reports","archived","inventory"]',
      );
      expect(attempts, <ModelFieldState>[added, removed]);
      expect(_chip(tester, 'catalog').selected, isTrue);

      await render(removed);
      expect(_chip(tester, 'catalog').selected, isFalse);
      expect(_chip(tester, 'reports').selected, isTrue);
      expect(_chip(tester, 'inventory').selected, isTrue);
    },
  );

  testWidgets(
    'Given one selected key When toggling it off Then proposes an empty array',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(value: '["catalog"]'),
            onChangedAttempt: attempts.add,
          ),
        ),
      );
      await tester.tap(find.text('Catálogo'));
      await tester.pumpAndSettle();
      expect(attempts, const <ModelFieldState>[
        ModelFieldState(value: '[]', isDirty: true),
      ]);
      expect(_chip(tester, 'catalog').selected, isTrue);
    },
  );

  testWidgets(
    'Given short labels and a compact theme When tapping the target edges Then each tap proposes once',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            options: const <String>['I'],
            optionLabelBuilder: null,
            onChangedAttempt: attempts.add,
          ),
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
      final Rect target = tester.getRect(_chips);
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      await tester.tapAt(target.topLeft + const Offset(2, 2));
      await tester.pumpAndSettle();
      await tester.tapAt(target.bottomRight - const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(attempts.map((ModelFieldState state) => state.value), <String>[
        '["I"]',
        '["I"]',
      ]);
    },
  );

  testWidgets(
    'Given a required group When invalid Then announces the error on the group',
    (WidgetTester tester) async {
      const String help = 'Elige las capacidades de la tienda.';
      const String error = 'Selecciona al menos una capacidad.';
      Future<void> render(ModelFieldState field) => tester.pumpWidget(
        _host(_field(field: field, helperText: help, required: true)),
      );
      await render(const ModelFieldState());
      expect(find.text('$_label *'), findsOneWidget);
      expect(find.text(help), findsOneWidget);
      expect(tester.getSemantics(_group).hint, 'Obligatorio\n$help');

      await render(
        const ModelFieldState(
          value: '["catalog"]',
          errorText: error,
          isValid: false,
        ),
      );
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      expect(find.bySemanticsLabel(error), findsNothing);
      final SemanticsData group = tester
          .getSemantics(_group)
          .getSemanticsData();
      expect(group.label, _label);
      expect(group.hint, 'Obligatorio\n$error');
      expect(group.flagsCollection.isRequired, Tristate.isTrue);
      expect(group.validationResult, SemanticsValidationResult.invalid);
      for (final String caption in <String>[
        'Catálogo',
        'Inventario',
        'Informes',
      ]) {
        expect(find.semantics.byLabel(caption), findsOne);
        final SemanticsData chip = _semantics(tester, caption);
        expect(
          chip.flagsCollection.isSelected,
          caption == 'Catálogo' ? Tristate.isTrue : Tristate.isFalse,
        );
        expect(chip.hasAction(SemanticsAction.tap), isTrue);
      }
    },
  );

  testWidgets(
    'Given no options When displayed Then announces the localized empty message',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(value: '["catalog"]'),
            options: const <String>[],
            onChangedAttempt: attempts.add,
          ),
          withNext: true,
        ),
      );
      expect(find.text('Sin opciones disponibles'), findsOneWidget);
      expect(_chips, findsNothing);
      expect(tester.getSemantics(_group).hint, 'Sin opciones disponibles');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        _semantics(tester, 'Siguiente').flagsCollection.isFocused,
        Tristate.isTrue,
      );
      expect(attempts, isEmpty);
    },
  );

  testWidgets(
    'Given keyboard focus When tabbing and pressing Space Then each chip toggles by itself',
    (WidgetTester tester) async {
      ModelFieldState field = const ModelFieldState();
      final List<String> attempts = <String>[];
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => _field(
              field: field,
              onChangedAttempt: (ModelFieldState next) {
                attempts.add(next.value);
                setState(() => field = next);
              },
            ),
          ),
          withNext: true,
        ),
      );
      for (final String name in <String>[
        'Catálogo',
        'Inventario',
        'Informes',
      ]) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(
          _semantics(tester, name).flagsCollection.isFocused,
          Tristate.isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
      }
      expect(attempts, <String>[
        '["catalog"]',
        '["catalog","inventory"]',
        '["catalog","inventory","reports"]',
      ]);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        _semantics(tester, 'Siguiente').flagsCollection.isFocused,
        Tristate.isTrue,
      );
    },
  );

  for (final (bool enabled, bool readOnly) in <(bool, bool)>[
    (true, true),
    (false, false),
    (false, true),
  ]) {
    testWidgets(
      'Given enabled=$enabled and readOnly=$readOnly When interacting Then leaves the selection',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(
          _host(
            _field(
              field: const ModelFieldState(value: '["catalog"]'),
              enabled: enabled,
              readOnly: readOnly,
              onChangedAttempt: attempts.add,
            ),
            withNext: true,
          ),
        );
        expect(
          tester.getSemantics(_group).hint,
          enabled && readOnly ? 'Solo lectura' : '',
        );
        expect(
          _semantics(tester, 'Catálogo').flagsCollection.isSelected,
          Tristate.isTrue,
        );
        expect(
          _semantics(tester, 'Catálogo').flagsCollection.isEnabled,
          Tristate.isFalse,
        );
        expect(
          _semantics(tester, 'Inventario').hasAction(SemanticsAction.tap),
          isFalse,
        );
        await tester.tap(find.text('Inventario'));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(
          _semantics(tester, 'Siguiente').flagsCollection.isFocused,
          Tristate.isTrue,
        );
        expect(attempts, isEmpty);
      },
    );
  }

  testWidgets(
    'Given a narrow group at 200% When laid out Then keeps every line of a selected chip visible',
    (WidgetTester tester) async {
      const String label =
          'Informes diarios de operaciones y movimientos de inventario';
      const String error =
          'Selecciona al menos una capacidad para usar los informes.';
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(
              value: '["reports"]',
              errorText: error,
              isValid: false,
            ),
            options: const <String>['I', 'reports'],
            optionLabelBuilder: (String key) => key == 'reports' ? label : key,
          ),
          width: 180,
          textScaler: const TextScaler.linear(2),
        ),
      );
      expect(
        tester.getTopLeft(_chips.last).dy,
        greaterThan(tester.getTopLeft(_chips.first).dy),
      );
      for (final String caption in <String>[label, error]) {
        final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
          find.text(caption),
        );
        final List<TextBox> boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: caption.length),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(boxes.last.bottom, greaterThan(boxes.first.bottom));
        expect(boxes.last.bottom, lessThanOrEqualTo(paragraph.size.height));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Given invalid configuration When built Then rejects it', (
    WidgetTester tester,
  ) async {
    for (final (String name, DsChipsSelectWidget field)
        in <(String, DsChipsSelectWidget)>[
          ('label', _field(label: ' ')),
          ('options', _field(options: const <String>[''])),
          ('options', _field(options: const <String>['catalog', 'catalog'])),
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

FilterChip _chip(WidgetTester tester, String key) =>
    tester.widget<FilterChip>(find.byKey(ValueKey<String>(key)));

SemanticsData _semantics(WidgetTester tester, String name) =>
    tester.getSemantics(find.bySemanticsLabel(name)).getSemanticsData();

DsChipsSelectWidget _field({
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
}) => DsChipsSelectWidget(
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
  ThemeData? theme,
}) => MaterialApp(
  theme: theme,
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

String _optionLabel(String key) => switch (key) {
  'catalog' => 'Catálogo',
  'inventory' => 'Inventario',
  _ => 'Informes',
};

void _ignore(ModelFieldState field) {}
