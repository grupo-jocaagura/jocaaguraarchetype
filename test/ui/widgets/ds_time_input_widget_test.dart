import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const String _label = 'Hora de la cita';
const String _placeholder = 'Selecciona una hora';
final Finder _dialog = find.byType(TimePickerDialog);
final Finder _fieldName = find.bySemanticsLabel(_label);
final Finder _editors = find.descendant(
  of: _dialog,
  matching: find.byType(EditableText),
);

void main() {
  testWidgets(
    'Given an accepted time When confirming a dial change Then proposes it',
    (WidgetTester tester) async {
      const ModelFieldState initial = ModelFieldState(
        value: '09:15',
        isValid: false,
        errorText: 'Verifica la hora.',
        suggestions: <String>['03:30'],
      );
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      Future<void> render(ModelFieldState field) => tester.pumpWidget(
        _host(
          _field(field: field, onChangedAttempt: attempts.add),
          use24Hours: true,
        ),
      );

      await render(initial);
      await _open(tester);
      final TimePickerDialog picker = tester.widget<TimePickerDialog>(_dialog);
      expect(picker.initialEntryMode, TimePickerEntryMode.dial);
      expect(picker.initialTime, const TimeOfDay(hour: 9, minute: 15));

      final Finder dial = find.descendant(
        of: _dialog,
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint &&
              widget.painter.runtimeType.toString() == '_DialPainter',
        ),
      );
      final Rect face = tester.getRect(dial);
      final double radius = face.shortestSide / 2 - 28;
      await tester.tapAt(face.center + Offset(radius, 0));
      await tester.pumpAndSettle();
      await tester.tapAt(face.center + Offset(0, radius));
      await tester.pumpAndSettle();
      await _confirm(tester);

      final ModelFieldState proposal = initial.copyWith(
        value: '03:30',
        isDirty: true,
      );
      expect(attempts, <ModelFieldState>[proposal]);
      expect(find.text('09:15'), findsOneWidget);
      await render(proposal);
      expect(find.text('03:30'), findsOneWidget);
      await _open(tester);
      await _confirm(tester);
      expect(attempts, <ModelFieldState>[proposal]);
    },
  );

  for (final String value in <String>[
    '',
    '9:30',
    '24:00',
    '23:60',
    '12:00\n',
    '2026-11-20T13:00:00Z',
  ]) {
    testWidgets(
      'Given ${value.isEmpty ? 'no selection' : value.trim()} When opening '
      'Then starts at local time and cancelling keeps the value',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        await tester.pumpWidget(
          _host(
            _field(
              field: ModelFieldState(value: value),
              onChangedAttempt: attempts.add,
            ),
          ),
        );

        final Finder caption = find.text(value.isEmpty ? _placeholder : value);
        expect(caption, findsOneWidget);
        final TimeOfDay before = TimeOfDay.now();
        await _open(tester);
        expect(
          tester.widget<TimePickerDialog>(_dialog).initialTime,
          isIn(<TimeOfDay>[before, TimeOfDay.now()]),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(_dialog, findsNothing);
        expect(attempts, isEmpty);
        expect(caption, findsOneWidget);
      },
    );
  }

  for (final (String value, String twelveHourCaption) in <(String, String)>[
    ('00:00', '12:00 AM'),
    ('12:00', '12:00 PM'),
    ('23:59', '11:59 PM'),
  ]) {
    testWidgets(
      'Given $value When changing hour preference Then formats the field',
      (WidgetTester tester) async {
        final DsTimeInputWidget field = _field(
          field: ModelFieldState(value: value),
        );
        await tester.pumpWidget(_host(field));
        expect(find.text(twelveHourCaption), findsOneWidget);
        expect(tester.getSemantics(_fieldName).value, twelveHourCaption);
        await tester.pumpWidget(_host(field, use24Hours: true));
        expect(find.text(value), findsOneWidget);
        expect(tester.getSemantics(_fieldName).value, value);
      },
    );
  }

  testWidgets(
    'Given a local Spanish locale at 200% When typing in landscape Then fits',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(640, 360);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(value: '21:30'),
            onChangedAttempt: attempts.add,
          ),
          use24Hours: true,
          locale: const Locale('es'),
          textScaler: const TextScaler.linear(2),
        ),
      );
      await _open(tester);
      final BuildContext dialogContext = tester.element(_dialog);
      expect(Localizations.localeOf(dialogContext), const Locale('es'));
      expect(
        MediaQuery.textScalerOf(dialogContext).scale(16),
        closeTo(17.6, 0.01),
      );
      expect(
        MediaQuery.textScalerOf(tester.element(find.byType(DsTimeInputWidget)))
            .scale(16),
        32,
      );
      expect(MediaQuery.alwaysUse24HourFormatOf(dialogContext), isTrue);
      expect(tester.takeException(), isNull);

      await _switchToTyping(tester);
      expect(tester.takeException(), isNull);
      await _enterTime(tester, hour: '23', minute: '60');
      await _confirm(tester);
      expect(_dialog, findsOneWidget);
      expect(attempts, isEmpty);
      expect(tester.takeException(), isNull);
      await _enterTime(tester, hour: '23', minute: '59');
      await _confirm(tester);
      expect(_dialog, findsNothing);
      expect(attempts.single.value, '23:59');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given a 12-hour picker at 200% When typing in landscape Then keeps PM',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(640, 360);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final List<ModelFieldState> attempts = <ModelFieldState>[];
      await tester.pumpWidget(
        _host(
          _field(
            field: const ModelFieldState(value: '21:30'),
            onChangedAttempt: attempts.add,
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );
      await _open(tester);
      expect(tester.takeException(), isNull);
      await _switchToTyping(tester);
      expect(tester.takeException(), isNull);
      await _enterTime(tester, hour: '08', minute: '05');
      await _confirm(tester);
      expect(attempts.single.value, '20:05');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given validation When building Then announces a single field and error',
    (WidgetTester tester) async {
      const String help = 'Elige la hora de tu cita.';
      const String error = 'Selecciona una hora válida.';
      Future<void> render(ModelFieldState field) async {
        await tester.pumpWidget(
          _host(_field(field: field, helperText: help, required: true)),
        );
        await tester.pumpAndSettle();
      }

      await render(const ModelFieldState());
      expect(find.text(help), findsOneWidget);
      expect(find.bySemanticsLabel(_placeholder), findsNothing);
      expect(_fieldName, findsOneWidget);
      expect(tester.getSemantics(_fieldName).value, _placeholder);
      expect(
        tester.getSemantics(_fieldName).flagsCollection.isRequired,
        Tristate.isTrue,
      );
      expect(tester.getSize(_fieldName).shortestSide, greaterThanOrEqualTo(48));

      await render(const ModelFieldState(isValid: false, errorText: error));
      expect(find.text(help), findsNothing);
      expect(find.text(error), findsOneWidget);
      final SemanticsData data = tester
          .getSemantics(_fieldName)
          .getSemanticsData();
      expect(data.hint.split('\n'), <String>['Obligatorio', error]);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
    },
  );

  testWidgets(
    'Given blocked fields When tapping Then exposes values without opening',
    (WidgetTester tester) async {
      for (final bool readOnly in <bool>[true, false]) {
        await tester.pumpWidget(
          _host(
            _field(
              field: const ModelFieldState(value: '14:15'),
              readOnly: readOnly,
              enabled: readOnly,
            ),
          ),
        );
        final SemanticsData data = tester
            .getSemantics(_fieldName)
            .getSemanticsData();
        expect(data.value, '2:15 PM');
        expect(
          data.flagsCollection.isEnabled,
          readOnly ? Tristate.isTrue : Tristate.isFalse,
        );
        expect(data.flagsCollection.isTextField, isFalse);
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        if (readOnly) {
          expect(data.hint, 'Solo lectura');
        }
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();
        expect(_dialog, findsNothing);
      }
    },
  );

  testWidgets(
    'Given a keyboard user When closing the picker Then restores field focus',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(_field()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      for (final bool confirm in <bool>[false, true]) {
        expect(
          tester.getSemantics(_fieldName).flagsCollection.isFocused,
          Tristate.isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(_dialog, findsOneWidget);
        if (confirm) {
          await _confirm(tester);
        } else {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
        }
      }
      expect(
        tester.getSemantics(_fieldName).flagsCollection.isFocused,
        Tristate.isTrue,
      );
    },
  );

  for (final String cause in <String>['disabled', 'read-only', 'removed']) {
    testWidgets(
      'Given a field made $cause while open When confirming Then discards it',
      (WidgetTester tester) async {
        final List<ModelFieldState> attempts = <ModelFieldState>[];
        Widget field({bool enabled = true, bool readOnly = false}) => _field(
          field: const ModelFieldState(value: '09:15'),
          enabled: enabled,
          readOnly: readOnly,
          onChangedAttempt: attempts.add,
        );
        await tester.pumpWidget(_host(field(), use24Hours: true));
        await _open(tester);
        await _switchToTyping(tester);
        await _enterTime(tester, hour: '10', minute: '25');
        await tester.pumpWidget(
          _host(
            cause == 'removed'
                ? const SizedBox.shrink()
                : field(
                    enabled: cause != 'disabled',
                    readOnly: cause == 'read-only',
                  ),
            use24Hours: true,
          ),
        );
        await _confirm(tester);
        expect(_dialog, findsNothing);
        expect(attempts, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Given a blank label When built Then rejects it', (
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
  });
}

DsTimeInputWidget _field({
  ModelFieldState field = const ModelFieldState(),
  String label = _label,
  String? helperText,
  bool required = false,
  bool enabled = true,
  bool readOnly = false,
  ValueChanged<ModelFieldState> onChangedAttempt = _ignore,
}) => DsTimeInputWidget(
  field: field,
  label: label,
  placeholder: _placeholder,
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
  bool use24Hours = false,
  Locale? locale,
  TextScaler? textScaler,
}) => MaterialApp(
  locale: const Locale('en', 'US'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const <Locale>[Locale('en', 'US'), Locale('es')],
  home: Scaffold(
    body: Builder(
      builder: (BuildContext context) => Center(
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: use24Hours, textScaler: textScaler),
          child: Localizations.override(
            context: context,
            locale: locale,
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(_fieldName);
  await tester.pumpAndSettle();
  expect(_dialog, findsOneWidget);
}

Future<void> _switchToTyping(WidgetTester tester) async {
  await tester.tap(find.byTooltip(_messages(tester).inputTimeModeButtonLabel));
  await tester.pumpAndSettle();
  expect(_editors, findsNWidgets(2));
}

Future<void> _enterTime(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await tester.enterText(_editors.first, hour);
  await tester.enterText(_editors.last, minute);
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text(_messages(tester).okButtonLabel));
  await tester.pumpAndSettle();
}

MaterialLocalizations _messages(WidgetTester tester) =>
    MaterialLocalizations.of(tester.element(_dialog));

void _ignore(ModelFieldState field) {}
