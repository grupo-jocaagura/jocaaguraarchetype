import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

final DateTime _firstDate = DateTime(2024, 2);
final DateTime _lastDate = DateTime(2024, 2, 29);
const String _label = 'Fecha de la cita';
const String _placeholder = 'Selecciona una fecha';

void main() {
  testWidgets('Given a blank field When a day is confirmed Then proposes it', (
    WidgetTester tester,
  ) async {
    const ModelFieldState initial = ModelFieldState(
      errorText: 'Verifica la fecha.',
      isValid: false,
      suggestions: <String>['2024-02-15'],
    );
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    Future<void> render(ModelFieldState field) => tester.pumpWidget(
      _host(_field(field: field, onChangedAttempt: attempts.add)),
    );

    await render(initial);
    expect(find.text(_placeholder), findsOneWidget);
    await _open(tester);
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      _lastDate,
    );
    await _tapDay(tester, 1);
    await _confirm(tester);

    final ModelFieldState proposal = initial.copyWith(
      value: '2024-02-01',
      isDirty: true,
    );
    expect(attempts, <ModelFieldState>[proposal]);
    expect(find.text(_placeholder), findsOneWidget);
    await render(proposal);
    expect(find.text('Feb 1, 2024'), findsOneWidget);

    await _open(tester);
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      _firstDate,
    );
    await _confirm(tester);
    expect(attempts, <ModelFieldState>[proposal]);
  });

  testWidgets('Given typed dates When confirmed Then accepts the leap day', (
    WidgetTester tester,
  ) async {
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(
        _field(
          field: const ModelFieldState(value: '2024-02-09'),
          onChangedAttempt: attempts.add,
        ),
      ),
    );
    await _open(tester);
    final MaterialLocalizations messages = _messages(tester);
    await tester.tap(find.byTooltip(messages.inputDateModeButtonLabel));
    await tester.pumpAndSettle();
    final Finder editor = find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(editor, '02/30/2024');
    await _confirm(tester);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(attempts, isEmpty);

    await tester.enterText(editor, '02/29/2024');
    await _confirm(tester);
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(attempts.single.value, '2024-02-29');
    expect(attempts.single.isDirty, isTrue);
    expect(find.text('Feb 9, 2024'), findsOneWidget);
  });

  for (final (String value, String? displayed) in <(String, String?)>[
    ('2024-02-30', null),
    ('2023-02-29', null),
    ('2024-2-09', null),
    ('2024-02-09T23:00:00-05:00', null),
    ('2024-03-01', 'Mar 1, 2024'),
  ]) {
    testWidgets('Given $value When opened Then uses a bounded initial day', (
      WidgetTester tester,
    ) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            field: ModelFieldState(value: value),
            onChangedAttempt: attempts.add,
          ),
        ),
      );
      expect(find.text(displayed ?? value), findsOneWidget);
      await _open(tester);
      expect(
        tester
            .widget<DatePickerDialog>(find.byType(DatePickerDialog))
            .initialDate,
        _lastDate,
      );
      await _cancel(tester);
      expect(attempts, isEmpty);
      expect(find.text(displayed ?? value), findsOneWidget);
    });
  }

  testWidgets('Given one future day When opened Then both bounds allow it', (
    WidgetTester tester,
  ) async {
    final int year = DateTime.now().year + 1;
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(
        _field(
          firstDate: DateTime.utc(year, 1, 8, 23),
          lastDate: DateTime(year, 1, 8, 1),
          onChangedAttempt: attempts.add,
        ),
      ),
    );
    await _open(tester);
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      DateTime(year, 1, 8),
    );
    await _confirm(tester);
    expect(attempts.single.value, '$year-01-08');
  });

  testWidgets('Given invalid configuration When built Then reports the error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_field(label: '  ')));
    expect(
      tester.takeException(),
      isA<ArgumentError>().having(
        (ArgumentError error) => error.name,
        'name',
        'label',
      ),
    );
    await tester.pumpWidget(
      _host(_field(firstDate: _lastDate, lastDate: _firstDate)),
    );
    expect(
      tester.takeException(),
      isA<ArgumentError>().having(
        (ArgumentError error) => error.name,
        'name',
        'lastDate',
      ),
    );
  });

  testWidgets(
    'Given a date When rendered in Spanish Then localizes the value',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          _field(field: const ModelFieldState(value: '2024-02-29')),
          locale: const Locale('es'),
        ),
      );
      final MaterialLocalizations messages = MaterialLocalizations.of(
        tester.element(find.byType(DsDateInputWidget)),
      );
      final String expected = messages.formatShortDate(_lastDate);
      expect(expected, isNot('Feb 29, 2024'));
      expect(find.text(expected), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel(_label)).value,
        expected,
      );
      await _open(tester);
      expect(find.text(messages.cancelButtonLabel), findsOneWidget);
      expect(find.byTooltip(messages.inputDateModeButtonLabel), findsOneWidget);
      await _cancel(tester);
    },
  );

  testWidgets(
    'Given validation When built Then announces the field and error',
    (WidgetTester tester) async {
      const String help = 'Elige el día de tu cita.';
      const String error = 'Selecciona una fecha.';
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_field(field: field, helperText: help, required: true)),
        );
        await tester.pumpAndSettle();
      }

      await render(const ModelFieldState());
      expect(find.text(help), findsOneWidget);
      expect(find.bySemanticsLabel(_placeholder), findsNothing);
      final Finder name = find.bySemanticsLabel(_label);
      expect(name, findsOneWidget);
      expect(tester.getSemantics(name).value, _placeholder);
      expect(
        tester.getSemantics(name).flagsCollection.isRequired,
        Tristate.isTrue,
      );

      await render(const ModelFieldState(isValid: false, errorText: error));
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      final SemanticsData data = tester.getSemantics(name).getSemanticsData();
      expect(data.hint.split('\n'), <String>['Obligatorio', error]);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
    },
  );

  testWidgets(
    'Given blocked fields When tapped Then never opens the calendar',
    (WidgetTester tester) async {
      const ModelFieldState field = ModelFieldState(value: '2024-02-29');
      for (final bool readOnly in <bool>[true, false]) {
        await tester.pumpWidget(
          _host(_field(field: field, readOnly: readOnly, enabled: readOnly)),
        );
        final Finder name = find.bySemanticsLabel(_label);
        final SemanticsData data = tester.getSemantics(name).getSemanticsData();
        expect(data.value, 'Feb 29, 2024');
        expect(
          data.flagsCollection.isEnabled,
          readOnly ? Tristate.isTrue : Tristate.isFalse,
        );
        expect(data.flagsCollection.isReadOnly, readOnly);
        expect(data.flagsCollection.isButton, !readOnly);
        expect(data.flagsCollection.isTextField, isFalse);
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        if (readOnly) {
          expect(data.hint, 'Solo lectura');
        }
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsNothing);
      }
    },
  );

  testWidgets('Given keyboard focus When the dialog closes Then restores it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_field()));
    final Finder name = find.bySemanticsLabel(_label);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(name).flagsCollection.isFocused,
      Tristate.isTrue,
    );
    for (final bool confirm in <bool>[false, true]) {
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      if (confirm) {
        await _confirm(tester);
      } else {
        await _cancel(tester);
      }
      expect(
        tester.getSemantics(name).flagsCollection.isFocused,
        Tristate.isTrue,
      );
    }
  });

  testWidgets(
    'Given changed bounds When confirming Then rechecks availability',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      Future<void> render({DateTime? lastDate, bool enabled = true}) =>
          tester.pumpWidget(
            _host(
              _field(
                lastDate: lastDate,
                enabled: enabled,
                onChangedAttempt: attempts.add,
              ),
            ),
          );
      await render();
      await _open(tester);
      await render(lastDate: DateTime(2024, 2, 15));
      await _confirm(tester);
      expect(attempts, isEmpty);

      await render();
      await _open(tester);
      await render(enabled: false);
      await _confirm(tester);
      expect(attempts, isEmpty);
    },
  );

  testWidgets('Given local text scaling When opened Then scales the dialog', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 665);
    await tester.pumpWidget(
      _host(
        _field(),
        locale: const Locale('es'),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await _open(tester);
    expect(
      MediaQuery.textScalerOf(tester.element(find.byType(DatePickerDialog)))
          .scale(16),
      32,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(
      find.byTooltip(_messages(tester).inputDateModeButtonLabel),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputDatePickerFormField), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _cancel(tester);
  });
}

DsDateInputWidget _field({
  ModelFieldState field = const ModelFieldState(),
  String label = _label,
  String? helperText,
  DateTime? firstDate,
  DateTime? lastDate,
  bool required = false,
  bool enabled = true,
  bool readOnly = false,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
}) => DsDateInputWidget(
  field: field,
  label: label,
  placeholder: _placeholder,
  helperText: helperText,
  firstDate: firstDate ?? _firstDate,
  lastDate: lastDate ?? _lastDate,
  required: required,
  enabled: enabled,
  readOnly: readOnly,
  requiredSemanticLabel: 'Obligatorio',
  readOnlySemanticLabel: 'Solo lectura',
  onChangedAttempt: onChangedAttempt,
);

Widget _host(Widget child, {Locale? locale, TextScaler? textScaler}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const <Locale>[Locale('en', 'US'), Locale('es')],
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => Center(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: SizedBox(width: 320, child: child),
            ),
          ),
        ),
      ),
    );

MaterialLocalizations _messages(WidgetTester tester) =>
    MaterialLocalizations.of(
      tester.element(find.byType(DatePickerDialog, skipOffstage: false)),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel(_label));
  await tester.pumpAndSettle();
  expect(find.byType(DatePickerDialog), findsOneWidget);
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text(_messages(tester).okButtonLabel));
  await tester.pumpAndSettle();
}

Future<void> _cancel(WidgetTester tester) async {
  await tester.tap(find.text(_messages(tester).cancelButtonLabel));
  await tester.pumpAndSettle();
}

Future<void> _tapDay(WidgetTester tester, int day) async {
  await tester.tap(
    find.descendant(
      of: find.byType(CalendarDatePicker),
      matching: find.text('$day'),
    ),
  );
  await tester.pumpAndSettle();
}

void _ignore(ModelFieldState next) {}
