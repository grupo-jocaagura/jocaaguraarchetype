import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const List<DsFormStep> _steps = <DsFormStep>[
  DsFormStep(
    id: 'contact',
    title: 'Contacto',
    content: Text('Datos de contacto'),
  ),
  DsFormStep(
    id: 'details',
    title: 'Detalles',
    content: Text('Datos de la solicitud'),
  ),
  DsFormStep(
    id: 'review',
    title: 'Revisión',
    content: Text('Resumen de la solicitud'),
  ),
];

void main() {
  for (final (
        String description,
        List<DsFormStep> steps,
        String activeStepId,
        String argument,
      )
      in <(String, List<DsFormStep>, String, String)>[
        ('an empty step list', const <DsFormStep>[], 'contact', 'steps'),
        (
          'duplicate step IDs',
          <DsFormStep>[_steps.first, _steps.first],
          'contact',
          'step.id',
        ),
        (
          'a blank step ID',
          const <DsFormStep>[
            DsFormStep(id: ' ', title: 'Contacto', content: SizedBox.shrink()),
          ],
          ' ',
          'step.id',
        ),
        (
          'a blank step title',
          const <DsFormStep>[
            DsFormStep(id: 'contact', title: ' ', content: SizedBox.shrink()),
          ],
          'contact',
          'step.title',
        ),
        ('an unknown active step ID', _steps, 'missing', 'activeStepId'),
      ]) {
    testWidgets('rejects $description', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(_stepper(steps: steps, activeStepId: activeStepId)),
      );
      expect(
        tester.takeException(),
        isA<ArgumentError>().having(
          (ArgumentError error) => error.name,
          'name',
          argument,
        ),
      );
    });
  }

  testWidgets('requests adjacent steps and waits for the active ID to change', (
    WidgetTester tester,
  ) async {
    final List<String> requests = <String>[];
    int finishes = 0;
    Future<void> render(String id) => tester.pumpWidget(
      _host(
        _stepper(
          activeStepId: id,
          onStepChangeAttempt: requests.add,
          onFinishAttempt: () => finishes++,
        ),
      ),
    );

    await render('contact');
    final Finder heading = find.bySemanticsLabel('Paso 1 de 3. Contacto');
    final SemanticsData data = tester.getSemantics(heading).getSemanticsData();
    expect(data.flagsCollection.isHeader, isTrue);
    expect(data.flagsCollection.isFocused, Tristate.isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    expect(find.byType(DsSecondaryButtonWidget), findsNothing);
    expect(find.text('Datos de la solicitud'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Continuar'));
    await tester.pumpAndSettle();
    expect(requests, <String>['details']);
    expect(find.text('Datos de contacto'), findsOneWidget);
    expect(heading, findsOneWidget);

    await render('details');
    await tester.pumpAndSettle();
    expect(find.text('Datos de contacto'), findsNothing);
    expect(find.text('Datos de la solicitud'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Atrás'));
    await tester.tap(find.bySemanticsLabel('Continuar'));
    expect(requests, <String>['details', 'contact', 'review']);

    await render('review');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Continuar'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Finalizar'));
    expect(finishes, 1);
    expect(requests, hasLength(3));
  });

  testWidgets('restores field values and validation from the consumer', (
    WidgetTester tester,
  ) async {
    const String error = 'Escribe un nombre completo.';
    final List<String> requests = <String>[];
    ModelFieldState name = const ModelFieldState(value: 'A');
    Future<void> render(String id) => tester.pumpWidget(
      _host(
        _stepper(
          activeStepId: id,
          onStepChangeAttempt: (String requestedId) {
            requests.add(requestedId);
            name = name.copyWith(isValid: false, errorText: error);
          },
          steps: <DsFormStep>[
            DsFormStep(
              id: 'contact',
              title: 'Contacto',
              content: DsTextInputWidget(
                field: name,
                label: 'Nombre',
                onChangedAttempt: _ignoreEdit,
              ),
            ),
            const DsFormStep(
              id: 'details',
              title: 'Detalles',
              content: DsTextInputWidget(
                field: ModelFieldState(value: 'A'),
                label: 'Motivo',
                onChangedAttempt: _ignoreEdit,
              ),
            ),
          ],
        ),
      ),
    );

    await render('contact');
    await tester.tap(find.bySemanticsLabel('Continuar'));
    await render('contact');
    await tester.pumpAndSettle();
    expect(requests, <String>['details']);
    expect(find.bySemanticsLabel('Paso 1 de 2. Contacto'), findsOneWidget);
    expect(find.text(error), findsOneWidget);

    // Both models have the same value. An unaccepted edit still belongs to
    // the step in which it was made.
    final Finder editor = find.byType(EditableText);
    await tester.enterText(find.byType(TextField), 'Otro borrador');
    expect(
      tester.widget<EditableText>(editor).controller.text,
      'Otro borrador',
    );
    await render('details');
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(editor).controller.text, 'A');
    expect(find.text(error), findsNothing);

    await render('contact');
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(editor).controller.text, 'A');
    expect(find.text(error), findsOneWidget);
  });

  testWidgets('keyboard can advance and focus moves only when accepted', (
    WidgetTester tester,
  ) async {
    const List<DsFormStep> fields = <DsFormStep>[
      DsFormStep(
        id: 'contact',
        title: 'Contacto',
        content: DsTextInputWidget(
          field: ModelFieldState(),
          label: 'Nombre',
          onChangedAttempt: _ignoreEdit,
        ),
      ),
      DsFormStep(
        id: 'details',
        title: 'Detalles',
        content: DsTextInputWidget(
          field: ModelFieldState(),
          label: 'Motivo',
          onChangedAttempt: _ignoreEdit,
        ),
      ),
    ];
    final List<String> requests = <String>[];
    Future<void> render(String id) => tester.pumpWidget(
      _host(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _stepper(
                steps: fields,
                activeStepId: id,
                onStepChangeAttempt: requests.add,
              ),
            ),
            const Expanded(
              child: DsFormStepperWidget(
                steps: <DsFormStep>[
                  DsFormStep(
                    id: 'other',
                    title: 'Otro formulario',
                    content: DsTextInputWidget(
                      field: ModelFieldState(),
                      label: 'Campo de otro formulario',
                      onChangedAttempt: _ignoreEdit,
                    ),
                  ),
                ],
                activeStepId: 'other',
                onStepChangeAttempt: _ignoreStep,
                onFinishAttempt: _ignoreFinish,
              ),
            ),
          ],
        ),
      ),
    );

    await render('contact');
    await tester.showKeyboard(find.byType(TextField).first);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final Finder next = find.bySemanticsLabel('Continuar');
    expect(
      tester.getSemantics(next).flagsCollection.isFocused,
      Tristate.isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(requests, <String>['details']);
    expect(
      tester.getSemantics(next).flagsCollection.isFocused,
      Tristate.isTrue,
    );

    await render('details');
    await tester.pumpAndSettle();
    final Finder heading = find.bySemanticsLabel('Paso 2 de 2. Detalles');
    expect(
      tester.getSemantics(heading).flagsCollection.isFocused,
      Tristate.isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('loading announces progress and blocks both actions', (
    WidgetTester tester,
  ) async {
    final List<String> requests = <String>[];
    int finishes = 0;
    Future<void> render({required bool loading}) => tester.pumpWidget(
      _host(
        _stepper(
          activeStepId: 'review',
          primaryState: ModelInteractiveState(
            semantic: ModelInteractiveSemantic.primary,
            isLoading: loading,
          ),
          onStepChangeAttempt: requests.add,
          onFinishAttempt: () => finishes++,
        ),
      ),
    );

    await render(loading: true);
    final Finder back = find.bySemanticsLabel('Atrás');
    final Finder finish = find.bySemanticsLabel('Finalizar');
    final SemanticsData primary = tester
        .getSemantics(finish)
        .getSemanticsData();
    expect(primary.value, 'Enviando');
    expect(find.byType(DsLoadingWidget), findsOneWidget);
    final Finder surface = find.descendant(
      of: find.byType(DsPrimaryButtonWidget),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is DecoratedBox && widget.decoration is ShapeDecoration,
      ),
    );
    final ShapeDecoration decoration =
        tester.widget<DecoratedBox>(surface).decoration as ShapeDecoration;
    expect(
      decoration.color,
      Theme.of(tester.element(surface)).colorScheme.primaryContainer,
    );
    expect(primary.hasAction(SemanticsAction.tap), isFalse);
    expect(
      tester
          .getSemantics(back)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    await tester.tap(find.byType(DsSecondaryButtonWidget));
    await tester.tap(find.byType(DsPrimaryButtonWidget));
    expect(requests, isEmpty);
    expect(finishes, 0);

    await render(loading: false);
    expect(find.byType(DsLoadingWidget), findsNothing);
    await tester.tap(back);
    await tester.tap(finish);
    expect(requests, <String>['details']);
    expect(finishes, 1);
  });

  testWidgets('keeps the summary and actions readable at 200 percent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(_stepper(activeStepId: 'review'), width: 560),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pumpWidget(
      _host(
        _stepper(
          activeStepId: 'review',
          finishLabel: 'Enviar solicitud completa',
        ),
        width: 200,
        scaler: const TextScaler.linear(2),
      ),
    );
    expect(find.text('Paso 3 de 3'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel('Enviar solicitud completa'), findsOneWidget);
    for (final Type button in <Type>[
      DsPrimaryButtonWidget,
      DsSecondaryButtonWidget,
    ]) {
      expect(
        tester.getSize(find.byType(button)).height,
        greaterThanOrEqualTo(48),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a single-step form offers only the finish action', (
    WidgetTester tester,
  ) async {
    int finishes = 0;
    await tester.pumpWidget(
      _host(
        _stepper(
          steps: <DsFormStep>[_steps.first],
          onFinishAttempt: () => finishes++,
        ),
      ),
    );
    expect(find.byType(DsSecondaryButtonWidget), findsNothing);
    expect(find.text('Paso 1 de 1'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Finalizar'));
    expect(finishes, 1);
  });
}

DsFormStepperWidget _stepper({
  List<DsFormStep> steps = _steps,
  String activeStepId = 'contact',
  String finishLabel = 'Finalizar',
  ModelInteractiveState primaryState = const ModelInteractiveState(
    semantic: ModelInteractiveSemantic.primary,
  ),
  ValueChanged<String> onStepChangeAttempt = _ignoreStep,
  VoidCallback onFinishAttempt = _ignoreFinish,
}) => DsFormStepperWidget(
  steps: steps,
  activeStepId: activeStepId,
  primaryState: primaryState,
  previousLabel: 'Atrás',
  continueLabel: 'Continuar',
  finishLabel: finishLabel,
  loadingSemanticLabel: 'Enviando',
  progressLabelBuilder: (int step, int count) => 'Paso $step de $count',
  onStepChangeAttempt: onStepChangeAttempt,
  onFinishAttempt: onFinishAttempt,
);

Widget _host(Widget stepper, {double width = 560, TextScaler? scaler}) =>
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: scaler),
            child: SingleChildScrollView(
              child: SizedBox(width: width, child: stepper),
            ),
          ),
        ),
      ),
    );

void _ignoreEdit(ModelFieldState field) {}
void _ignoreStep(String id) {}
void _ignoreFinish() {}
