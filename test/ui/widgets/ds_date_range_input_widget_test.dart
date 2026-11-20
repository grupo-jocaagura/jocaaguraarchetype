import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

final DateTime _firstDay = DateTime(2024, 2);
final DateTime _lastDay = DateTime(2024, 2, 29);
const String _label = 'Periodo de reserva';
const String _placeholder = 'Selecciona un rango de fechas';
const String _completeRange = '{"start":"2024-02-01","end":"2024-02-29"}';
final Finder _dialog = find.byType(DateRangePickerDialog);
final Finder _fieldName = find.bySemanticsLabel(_label);

void main() {
  testWidgets('Given an empty field When saved Then proposes both limits', (
    WidgetTester tester,
  ) async {
    const ModelFieldState initial = ModelFieldState(
      errorText: 'Confirma el rango.',
      isValid: false,
      suggestions: <String>['2024-02-03'],
    );
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    Future<void> render(ModelFieldState value) => tester.pumpWidget(
      _host(_field(field: value, onChangedAttempt: attempts.add)),
    );

    await render(initial);
    expect(find.text(_placeholder), findsOneWidget);
    await _open(tester);
    expect(
      tester.widget<DateRangePickerDialog>(_dialog).initialDateRange,
      isNull,
    );
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(attempts, isEmpty);
    final Finder save = find.text(_messages(tester).saveButtonLabel);
    expect(
      tester
          .widget<TextButton>(
            find.ancestor(of: save, matching: find.byType(TextButton)),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('29'));
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    final ModelFieldState proposal = initial.copyWith(
      value: _completeRange,
      isDirty: true,
    );
    expect(attempts, <ModelFieldState>[proposal]);
    expect(find.text(_placeholder), findsOneWidget);
    await render(proposal);
    expect(find.text('Feb 1, 2024 – Feb 29, 2024'), findsOneWidget);
  });

  testWidgets('Given a typed range When valid Then accepts a single day', (
    WidgetTester tester,
  ) async {
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    await tester.pumpWidget(_host(_field(onChangedAttempt: attempts.add)));
    await _open(tester);
    final MaterialLocalizations messages = _messages(tester);
    await tester.tap(find.byTooltip(messages.inputDateModeButtonLabel));
    await tester.pumpAndSettle();
    final Finder editors = find.descendant(
      of: _dialog,
      matching: find.byType(TextField),
    );
    Future<void> confirm(String start, String end) async {
      await tester.enterText(editors.first, start);
      await tester.enterText(editors.last, end);
      await tester.tap(find.text(messages.okButtonLabel));
      await tester.pumpAndSettle();
    }

    await confirm('02/29/2024', '02/28/2024');
    expect(_dialog, findsOneWidget);
    expect(find.text(messages.invalidDateRangeLabel), findsOneWidget);
    expect(attempts, isEmpty);

    await confirm('02/29/2024', '02/29/2024');
    expect(_dialog, findsNothing);
    expect(attempts.single.value, '{"start":"2024-02-29","end":"2024-02-29"}');
    expect(attempts.single.isDirty, isTrue);
  });

  testWidgets(
    'Given equivalent JSON When saved Then keeps the accepted range',
    (WidgetTester tester) async {
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(
              value: '{ "end": "2024-02-29", "start": "2024-02-01" }',
            ),
            onChangedAttempt: attempts.add,
          ),
        ),
      );
      await _open(tester);
      expect(
        tester.widget<DateRangePickerDialog>(_dialog).initialDateRange,
        DateTimeRange<DateTime>(start: _firstDay, end: _lastDay),
      );
      await tester.tap(find.text(_messages(tester).saveButtonLabel));
      await tester.pumpAndSettle();
      expect(attempts, isEmpty);
    },
  );

  for (final (String value, String? caption) in <(String, String?)>[
    ('{malformed', null),
    ('[]', null),
    ('{"start":"2024-02-01"}', null),
    ('{"start":20240201,"end":"2024-02-29"}', null),
    ('{"start":"2024-02-01","end":"2024-02-30"}', null),
    ('{"start":"2024-02-29","end":"2024-02-01"}', null),
    ('{"start":"2024-01-31","end":"2024-02-01"}', 'Jan 31, 2024 – Feb 1, 2024'),
    ('{"start":"2024-02-29","end":"2024-03-01"}', 'Feb 29, 2024 – Mar 1, 2024'),
  ]) {
    testWidgets('Given $value When opened Then has no selection', (
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
      expect(find.text(caption ?? _placeholder), findsOneWidget);
      await _open(tester);
      expect(
        tester.widget<DateRangePickerDialog>(_dialog).initialDateRange,
        isNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_dialog, findsNothing);
      expect(attempts, isEmpty);
      expect(find.text(caption ?? _placeholder), findsOneWidget);
    });
  }

  testWidgets('Given reversed limits When built Then reports the argument', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(_field(firstDate: _lastDay, lastDate: _firstDay)),
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
    'Given a one-day range When opened Then preselects the same day',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(
              value: '{"start":"2024-02-29","end":"2024-02-29"}',
            ),
            firstDate: DateTime.utc(2024, 2, 29, 23),
            lastDate: DateTime(2024, 2, 29, 1),
          ),
        ),
      );
      await _open(tester);
      expect(
        tester.widget<DateRangePickerDialog>(_dialog).initialDateRange,
        DateTimeRange<DateTime>(start: _lastDay, end: _lastDay),
      );
    },
  );

  testWidgets('Given blocked fields When read Then exposes both endpoints', (
    WidgetTester tester,
  ) async {
    for (final bool readOnly in <bool>[true, false]) {
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(
              value: _completeRange,
              errorText: 'Revisa el periodo.',
            ),
            readOnly: readOnly,
            enabled: readOnly,
            required: true,
            helperText: 'Puedes escoger todo el mes.',
          ),
          locale: const Locale('es'),
        ),
      );
      final SemanticsData data = tester
          .getSemantics(_fieldName)
          .getSemanticsData();
      final MaterialLocalizations messages = MaterialLocalizations.of(
        tester.element(find.byType(DsDateRangeInputWidget)),
      );
      expect(data.value.split('\n'), <String>[
        '${messages.dateRangeStartLabel}: ${messages.formatShortDate(_firstDay)}',
        '${messages.dateRangeEndLabel}: ${messages.formatShortDate(_lastDay)}',
      ]);
      expect(data.hint.split('\n'), <String>[
        'Obligatorio',
        if (readOnly) 'Solo lectura',
        'Revisa el periodo.',
      ]);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.flagsCollection.isRequired, Tristate.isTrue);
      expect(
        data.flagsCollection.isEnabled,
        readOnly ? Tristate.isTrue : Tristate.isFalse,
      );
      expect(data.flagsCollection.isButton, !readOnly);
      expect(data.flagsCollection.isTextField, isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      expect(find.text('Puedes escoger todo el mes.'), findsNothing);
      expect(find.text('Revisa el periodo.'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(_dialog, findsNothing);
    }
  });

  testWidgets('Given keyboard focus When closed Then focus returns to field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(_field(field: const ModelFieldState(value: _completeRange))),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(_fieldName).flagsCollection.isFocused,
      Tristate.isTrue,
    );
    for (final bool save in <bool>[false, true]) {
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_dialog, findsOneWidget);
      if (save) {
        await tester.tap(find.text(_messages(tester).saveButtonLabel));
      } else {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      }
      await tester.pumpAndSettle();
      expect(_dialog, findsNothing);
      expect(
        tester.getSemantics(_fieldName).flagsCollection.isFocused,
        Tristate.isTrue,
      );
    }
  });

  for (final (
        String change,
        Widget Function(ValueChanged<ModelFieldState>) replacement,
      )
      in <(String, Widget Function(ValueChanged<ModelFieldState>))>[
        (
          'a shorter range limit',
          (ValueChanged<ModelFieldState> onChanged) => _field(
            lastDate: DateTime(2024, 2, 15),
            onChangedAttempt: onChanged,
          ),
        ),
        (
          'a disabled field',
          (ValueChanged<ModelFieldState> onChanged) =>
              _field(enabled: false, onChangedAttempt: onChanged),
        ),
        (
          'a read-only field',
          (ValueChanged<ModelFieldState> onChanged) =>
              _field(readOnly: true, onChangedAttempt: onChanged),
        ),
        (
          'an unmounted field',
          (ValueChanged<ModelFieldState> _) => const SizedBox.shrink(),
        ),
      ]) {
    testWidgets(
      'Given $change When the open picker saves Then discards the range',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(_host(_field(onChangedAttempt: attempts.add)));
        await _open(tester);
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('29'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(_host(replacement(attempts.add)));
        await tester.pumpAndSettle();
        expect(_dialog, findsOneWidget);
        await tester.tap(find.text(_messages(tester).saveButtonLabel));
        await tester.pumpAndSettle();
        expect(_dialog, findsNothing);
        expect(attempts, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Given 200% text When opened Then respects each scale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _field(field: const ModelFieldState(value: _completeRange)),
        width: 210,
        textScaler: const TextScaler.linear(2),
      ),
    );
    final Finder caption = find.text('Feb 1, 2024 – Feb 29, 2024');
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      caption,
    );
    expect(paragraph.textScaler.scale(16), 32);
    expect(paragraph.size.height, greaterThan(32));
    expect(paragraph.didExceedMaxLines, isFalse);

    await _open(tester);
    final Finder inputMode = find.byTooltip(
      _messages(tester).inputDateModeButtonLabel,
    );
    double scaleAt(Finder finder) =>
        MediaQuery.textScalerOf(tester.element(finder)).scale(20);
    expect(scaleAt(inputMode), closeTo(26, 0.001));
    await tester.tap(inputMode);
    await tester.pumpAndSettle();
    final Finder startDate = find
        .descendant(of: _dialog, matching: find.byType(TextField))
        .first;
    expect(scaleAt(startDate), closeTo(26, 0.001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Given landscape and 200% text When typing Then both dates fit', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 500);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _host(_field(), textScaler: const TextScaler.linear(2)),
    );
    await _open(tester);
    expect(tester.getSize(find.byType(Dialog)).width, 800);
    final MaterialLocalizations messages = _messages(tester);
    await tester.tap(find.byTooltip(messages.inputDateModeButtonLabel));
    await tester.pumpAndSettle();

    final Finder editors = find.descendant(
      of: _dialog,
      matching: find.byType(EditableText),
    );
    await tester.enterText(editors.first, '02/01/2024');
    await tester.enterText(editors.last, '02/29/2024');
    await tester.pumpAndSettle();

    for (final Finder editor in <Finder>[editors.first, editors.last]) {
      final EditableText input = tester.widget<EditableText>(editor);
      final TextScaler scaler = MediaQuery.textScalerOf(tester.element(editor));
      final RenderEditable render = tester
          .state<EditableTextState>(editor)
          .renderEditable;
      expect(scaler.scale(20), closeTo(26, 0.001));
      expect(
        render.size.width,
        greaterThan(
          TextPainter.computeWidth(
            text: TextSpan(text: input.controller.text, style: input.style),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
          ),
        ),
      );
      expect(render.offset.pixels, 0);
    }
    for (final String label in <String>[
      messages.dateRangeStartLabel,
      messages.dateRangeEndLabel,
    ]) {
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        find.text(label),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Given a 640×360 viewport When typing Then saves both dates', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final List<ModelFieldState> attempts = <ModelFieldState>[];
    await tester.pumpWidget(
      _host(
        _field(onChangedAttempt: attempts.add),
        locale: const Locale('es'),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await _open(tester);
    final MaterialLocalizations messages = _messages(tester);
    await tester.tap(find.byTooltip(messages.inputDateModeButtonLabel));
    await tester.pumpAndSettle();

    final Finder editors = find.descendant(
      of: _dialog,
      matching: find.byType(EditableText),
    );
    expect(editors, findsNWidgets(2));
    await tester.enterText(editors.first, '01/02/2024');
    await tester.enterText(editors.last, '29/02/2024');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(messages.okButtonLabel));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
    expect(attempts.single.value, _completeRange);
    expect(tester.takeException(), isNull);
  });
}

DsDateRangeInputWidget _field({
  ModelFieldState field = const ModelFieldState(),
  DateTime? firstDate,
  DateTime? lastDate,
  String? helperText,
  bool enabled = true,
  bool readOnly = false,
  bool required = false,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
}) => DsDateRangeInputWidget(
  field: field,
  label: _label,
  placeholder: _placeholder,
  helperText: helperText,
  firstDate: firstDate ?? _firstDay,
  lastDate: lastDate ?? _lastDay,
  enabled: enabled,
  readOnly: readOnly,
  required: required,
  requiredSemanticLabel: 'Obligatorio',
  readOnlySemanticLabel: 'Solo lectura',
  onChangedAttempt: onChangedAttempt,
);

Widget _host(
  Widget child, {
  double width = 320,
  Locale? locale,
  TextScaler? textScaler,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const <Locale>[Locale('en', 'US'), Locale('es')],
  home: Scaffold(
    body: Builder(
      builder: (BuildContext context) => Center(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

MaterialLocalizations _messages(WidgetTester tester) =>
    MaterialLocalizations.of(tester.element(_dialog));

Future<void> _open(WidgetTester tester) async {
  await tester.tap(_fieldName);
  await tester.pumpAndSettle();
  expect(_dialog, findsOneWidget);
}

void _ignore(ModelFieldState value) {}
