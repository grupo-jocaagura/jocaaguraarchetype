import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('only visible actions reserve space', (
    WidgetTester tester,
  ) async {
    const ModelInteractiveState hidden = ModelInteractiveState(
      isVisible: false,
    );

    await _render(
      tester,
      const DsFormActionsWidget(primaryLabel: 'Save', onPrimary: _noop),
    );
    expect(find.byType(DsSecondaryButtonWidget), findsNothing);
    expect(tester.getSize(find.byType(DsPrimaryButtonWidget)).width, 540);

    await _render(
      tester,
      const DsFormActionsWidget(
        primaryLabel: 'Save',
        onPrimary: _noop,
        primaryState: hidden,
        secondaryLabel: 'Cancel',
        onSecondary: _noop,
      ),
    );
    expect(find.bySemanticsLabel('Save'), findsNothing);
    expect(tester.getSize(find.byType(DsSecondaryButtonWidget)).width, 540);

    await _render(
      tester,
      const DsFormActionsWidget(
        primaryLabel: 'Save',
        onPrimary: _noop,
        primaryState: hidden,
        secondaryLabel: 'Cancel',
        secondaryState: hidden,
      ),
    );
    expect(find.bySemanticsLabel('Cancel'), findsNothing);
    expect(tester.getSize(find.byType(DsFormActionsWidget)).height, 0);
  });

  testWidgets('secondary availability requires a callback and enabled state', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    Future<void> render({
      VoidCallback? callback,
      ModelInteractiveState state = const ModelInteractiveState(
        semantic: ModelInteractiveSemantic.secondary,
      ),
    }) => _render(
      tester,
      DsFormActionsWidget(
        primaryLabel: 'Save',
        onPrimary: _noop,
        secondaryLabel: 'Cancel',
        onSecondary: callback,
        secondaryState: state,
      ),
    );

    final Finder secondary = find.bySemanticsLabel('Cancel');
    await render();
    expect(secondary, findsOneWidget);
    expect(
      tester.getSemantics(secondary).flagsCollection.isEnabled,
      Tristate.isFalse,
    );

    const ModelInteractiveState disabled = ModelInteractiveState(
      semantic: ModelInteractiveSemantic.warning,
      isEnabled: false,
      reasonText: 'Cancellation unavailable',
    );
    await render(callback: () => calls++, state: disabled);
    expect(
      tester
          .widget<DsSecondaryButtonWidget>(find.byType(DsSecondaryButtonWidget))
          .state,
      same(disabled),
    );
    expect(tester.getSemantics(secondary).hint, 'Cancellation unavailable');
    await tester.tap(secondary);
    expect(calls, 0);

    await render(callback: () => calls++);
    expect(
      tester.getSemantics(secondary).flagsCollection.isEnabled,
      Tristate.isTrue,
    );
    await tester.tap(secondary);
    expect(calls, 1);
  });

  testWidgets('actions default to their respective semantic intents', (
    WidgetTester tester,
  ) async {
    await _render(
      tester,
      const DsFormActionsWidget(
        primaryLabel: 'Save',
        onPrimary: _noop,
        secondaryLabel: 'Cancel',
        onSecondary: _noop,
      ),
    );
    expect(
      tester
          .widget<DsPrimaryButtonWidget>(find.byType(DsPrimaryButtonWidget))
          .state
          .semantic,
      ModelInteractiveSemantic.primary,
    );
    expect(
      tester
          .widget<DsSecondaryButtonWidget>(find.byType(DsSecondaryButtonWidget))
          .state
          .semantic,
      ModelInteractiveSemantic.secondary,
    );
  });

  for (final bool primaryLoads in <bool>[true, false]) {
    testWidgets(
      '${primaryLoads ? 'primary' : 'secondary'} loads independently',
      (WidgetTester tester) async {
        int saves = 0;
        int cancels = 0;
        await _render(
          tester,
          DsFormActionsWidget(
            primaryLabel: 'Save',
            onPrimary: () => saves++,
            primaryState: ModelInteractiveState(isLoading: primaryLoads),
            primaryLoadingSemanticLabel: 'Guardando',
            secondaryLabel: 'Cancel',
            onSecondary: () => cancels++,
            secondaryState: ModelInteractiveState(isLoading: !primaryLoads),
            secondaryLoadingSemanticLabel: 'Cancelando',
          ),
        );
        final Finder save = find.bySemanticsLabel('Save');
        final Finder cancel = find.bySemanticsLabel('Cancel');
        final Finder loading = primaryLoads ? save : cancel;
        final Finder available = primaryLoads ? cancel : save;
        expect(find.byType(DsLoadingWidget), findsOneWidget);
        expect(
          tester.getSemantics(loading).value,
          primaryLoads ? 'Guardando' : 'Cancelando',
        );
        expect(
          tester.getSemantics(loading).flagsCollection.isLiveRegion,
          isTrue,
        );
        expect(
          tester
              .getSemantics(loading)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
        );
        expect(
          tester
              .getSemantics(available)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
        await tester.tap(save);
        await tester.tap(cancel);
        expect(saves, primaryLoads ? 0 : 1);
        expect(cancels, primaryLoads ? 1 : 0);
      },
    );
  }

  testWidgets('width and enlarged labels determine the layout', (
    WidgetTester tester,
  ) async {
    const DsFormActionsWidget actions = DsFormActionsWidget(
      primaryLabel: 'Guardar cambios',
      onPrimary: _noop,
      secondaryLabel: 'Cancelar',
      onSecondary: _noop,
    );
    final Finder secondary = find.byType(DsSecondaryButtonWidget);
    final Finder primary = find.byType(DsPrimaryButtonWidget);

    await _render(tester, actions);
    expect(tester.getRect(secondary).top, tester.getRect(primary).top);
    expect(
      tester.getRect(secondary).right,
      lessThan(tester.getRect(primary).left),
    );
    expect(tester.getSize(secondary).width, tester.getSize(primary).width);

    await _render(tester, actions, width: 180);
    expect(
      tester.getRect(secondary).bottom,
      lessThan(tester.getRect(primary).top),
    );
    expect(tester.getSize(secondary).width, 180);
    expect(tester.getSize(primary).width, 180);

    await _render(tester, actions, textScaler: const TextScaler.linear(2));
    expect(
      tester.getRect(secondary).bottom,
      lessThan(tester.getRect(primary).top),
    );
    expect(tester.getSize(secondary).width, 540);
    expect(tester.getSize(primary).width, 540);
    expect(tester.takeException(), isNull);
  });

  for (final double width in <double>[540, 150]) {
    testWidgets('Tab activates secondary before primary at width $width', (
      WidgetTester tester,
    ) async {
      final List<String> activations = <String>[];
      await _render(
        tester,
        DsFormActionsWidget(
          primaryLabel: 'Save changes',
          onPrimary: () => activations.add('save'),
          secondaryLabel: 'Cancel editing',
          onSecondary: () => activations.add('cancel'),
        ),
        width: width,
      );

      final Finder secondary = find.bySemanticsLabel('Cancel editing');
      final Finder primary = find.bySemanticsLabel('Save changes');
      for (final Finder action in <Finder>[secondary, primary]) {
        final Size target = tester.getSemantics(action).rect.size;
        expect(target.width, greaterThanOrEqualTo(48));
        expect(target.height, greaterThanOrEqualTo(48));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(action).flagsCollection.isFocused,
          Tristate.isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      }
      expect(activations, <String>['cancel', 'save']);
    });
  }
}

Future<void> _render(
  WidgetTester tester,
  DsFormActionsWidget actions, {
  double width = 540,
  TextScaler textScaler = TextScaler.noScaling,
}) => tester.pumpWidget(
  MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: actions),
        ),
      ),
    ),
  ),
);

void _noop() {}
