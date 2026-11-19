import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('fixed surfaces default to primary and secondary intent', (
    WidgetTester tester,
  ) async {
    final ThemeData theme = ThemeData();
    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DsPrimaryButtonWidget(label: 'Save', onPressed: _noop),
            DsSecondaryButtonWidget(label: 'Cancel', onPressed: _noop),
          ],
        ),
        theme: theme,
      ),
    );
    final ShapeDecoration primary = _surface(tester, DsPrimaryButtonWidget);
    final ShapeDecoration secondary = _surface(tester, DsSecondaryButtonWidget);
    expect(primary.color, theme.colorScheme.primaryContainer);
    expect((primary.shape as RoundedRectangleBorder).side, BorderSide.none);
    expect(secondary.color, theme.colorScheme.surface);
    expect(
      (secondary.shape as RoundedRectangleBorder).side.color,
      theme.colorScheme.secondary,
    );
  });

  for (final bool primary in <bool>[true, false]) {
    final String kind = primary ? 'primary' : 'secondary';
    testWidgets('$kind gives pointer, keyboard and semantics a 48 px target', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(_host(_button(primary, label: 'Go')));
      final Finder target = find.byType(InkWell);
      expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(target).height, 48);

      await tester.pumpWidget(
        _host(
          SizedBox.square(
            dimension: 48,
            child: _button(primary, label: '  Go  ', onPressed: () => taps++),
          ),
        ),
      );

      final Finder name = find.bySemanticsLabel('Go');
      expect(name, findsOneWidget);
      expect(tester.getSemantics(name).flagsCollection.isButton, isTrue);
      expect(tester.getSemantics(name).childrenCount, 0);
      expect(tester.getSemantics(name).rect.size, const Size.square(48));
      expect(tester.getSize(target), const Size.square(48));
      await tester.tapAt(tester.getTopLeft(target) + const Offset(1, 1));
      expect(taps, 1, reason: 'Pointer activates at the corner of the target.');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(name).flagsCollection.isFocused,
        Tristate.isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 2, reason: 'Enter activates the focused button.');
      tester.semantics.tap(find.semantics.byLabel('Go'));
      expect(taps, 3);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_host(_button(primary, label: '   ')));
      expect(tester.takeException(), isArgumentError);
    });

    testWidgets('$kind wraps enlarged labelLarge and keeps its size in load', (
      WidgetTester tester,
    ) async {
      const String label = 'Descargar todos los comprobantes';
      final ThemeData theme = ThemeData(
        textTheme: const TextTheme(labelLarge: TextStyle(fontSize: 19)),
      );
      int taps = 0;
      Future<void> render(ModelInteractiveState state, {DsLoading? loading}) =>
          tester.pumpWidget(
            _host(
              SizedBox(
                width: 144,
                child: _button(
                  primary,
                  label: label,
                  state: state,
                  loading: loading ?? const DsLoadingWidget(),
                  onPressed: () => taps++,
                ),
              ),
              theme: theme,
              textScaler: const TextScaler.linear(2),
            ),
          );

      await render(const ModelInteractiveState());
      final Finder labelText = find.text(label);
      final Finder target = find.byType(InkWell);
      final Rect idleTarget = tester.getRect(target);
      final Rect idleLabel = tester.getRect(labelText);
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        labelText,
      );
      expect(paragraph.text.style?.fontSize, 19);
      expect(paragraph.textScaler.scale(19), 38);
      expect(
        paragraph
            .getBoxesForSelection(
              const TextSelection(baseOffset: 0, extentOffset: label.length),
            )
            .map((TextBox box) => box.top)
            .toSet()
            .length,
        greaterThan(2),
      );
      expect(
        paragraph.getBoxesForSelection(
          const TextSelection(
            baseOffset: label.length - 1,
            extentOffset: label.length,
          ),
        ),
        hasLength(1),
      );
      expect(idleTarget.height, greaterThan(48));

      for (final DsLoading loading in const <DsLoading>[
        DsLoadingWidget(),
        _CustomLoading(),
      ]) {
        await render(
          const ModelInteractiveState(isLoading: true),
          loading: loading,
        );
        expect(tester.getRect(target), idleTarget);
        expect(tester.getRect(labelText), idleLabel);
        expect(
          find.byType(
            loading is DsLoadingWidget
                ? CircularProgressIndicator
                : _CustomLoading,
          ),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Inner loader'), findsNothing);
        final SemanticsData data = tester
            .getSemantics(find.bySemanticsLabel(label))
            .getSemanticsData();
        expect(data.value, 'Cargando');
        expect(data.flagsCollection.isLiveRegion, isTrue);
        expect(data.flagsCollection.isEnabled, Tristate.isFalse);
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        await tester.tap(target);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(taps, 0);
      }
      await render(const ModelInteractiveState());
      expect(tester.getRect(target), idleTarget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$kind keeps DS state precedence and allows enabled retries', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      Future<void> render(ModelInteractiveState state) => tester.pumpWidget(
        _host(
          _button(
            primary,
            label: 'Confirm',
            icon: Icons.send,
            state: state,
            onPressed: () => taps++,
          ),
        ),
      );

      await render(const ModelInteractiveState());
      expect(find.byIcon(Icons.send), findsOneWidget);
      final Finder target = find.byType(InkWell);
      final Rect idleTarget = tester.getRect(target);

      await render(
        const ModelInteractiveState(
          isEnabled: false,
          isSelected: true,
          reasonText: 'Locked',
        ),
      );
      final Finder name = find.bySemanticsLabel('Confirm');
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        tester.getSemantics(name).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(
        tester.getSemantics(name).flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(tester.getSemantics(name).hint, 'Locked');
      await tester.tap(target);
      expect(taps, 0);

      const ModelInteractiveState error = ModelInteractiveState(
        isSelected: true,
        errorText: 'Try again',
      );
      await render(error);
      expect(tester.getRect(target), idleTarget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(tester.getSemantics(name).hint, 'Try again');
      tester.semantics.tap(find.semantics.byLabel('Confirm'));
      expect(taps, 1);

      final ModelInteractiveState loading = error.copyWith(isLoading: true);
      await render(loading);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getRect(target), idleTarget);

      await render(loading.copyWith(isVisible: false));
      expect(target, findsNothing);
      expect(name, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('intents use DS semantic colors and both brightness fallbacks', (
    WidgetTester tester,
  ) async {
    for (final Brightness brightness in Brightness.values) {
      final ModelSemanticColors fallback = brightness == Brightness.dark
          ? ModelSemanticColors.fallbackDark()
          : ModelSemanticColors.fallbackLight();
      final ModelSemanticColors custom = fallback.copyWith(
        success: const Color(0xFF003152),
        onSuccess: Colors.white,
        successContainer: const Color(0xFFE5EFF8),
        onSuccessContainer: const Color(0xFF003152),
        warning: const Color(0xFF512819),
        onWarning: Colors.white,
        warningContainer: const Color(0xFFFBEADD),
        onWarningContainer: const Color(0xFF512819),
      );
      for (final ModelSemanticColors? extension in <ModelSemanticColors?>[
        null,
        custom,
      ]) {
        final ThemeData theme = ThemeData(
          brightness: brightness,
          extensions: <ThemeExtension<dynamic>>[
            if (extension != null)
              DsSemanticColorsExtension(semantic: extension),
          ],
        );
        final ModelSemanticColors semantic = extension ?? fallback;
        final ColorScheme scheme = theme.colorScheme;
        for (final ModelInteractiveSemantic intent
            in ModelInteractiveSemantic.values) {
          final (Color fill, Color foreground, Color border) = switch (intent) {
            ModelInteractiveSemantic.primary => (
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
              scheme.primary,
            ),
            ModelInteractiveSemantic.secondary => (
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
              scheme.secondary,
            ),
            ModelInteractiveSemantic.neutral => (
              scheme.surfaceContainerHighest,
              scheme.onSurface,
              scheme.outline,
            ),
            ModelInteractiveSemantic.success => (
              semantic.successContainer,
              semantic.onSuccessContainer,
              semantic.success,
            ),
            ModelInteractiveSemantic.warning => (
              semantic.warningContainer,
              semantic.onWarningContainer,
              semantic.warning,
            ),
            ModelInteractiveSemantic.danger => (
              scheme.errorContainer,
              scheme.onErrorContainer,
              scheme.error,
            ),
          };
          final ModelInteractiveState state = ModelInteractiveState(
            semantic: intent,
          );
          await tester.pumpWidget(
            _host(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _button(true, label: 'Apply', state: state),
                  _button(false, label: 'Cancel', state: state),
                ],
              ),
              theme: theme,
            ),
          );
          final ShapeDecoration primary = _surface(
            tester,
            DsPrimaryButtonWidget,
          );
          final ShapeDecoration secondary = _surface(
            tester,
            DsSecondaryButtonWidget,
          );
          expect(primary.color, fill);
          expect(
            tester.widget<Text>(find.text('Apply')).style?.color,
            foreground,
          );
          expect(secondary.color, scheme.surface);
          expect(
            (secondary.shape as RoundedRectangleBorder).side.color,
            border,
          );
          expect(
            tester.widget<Text>(find.text('Cancel')).style?.color,
            scheme.onSurface,
          );
        }
      }
    }
  });
}

Widget _host(Widget child, {ThemeData? theme, TextScaler? textScaler}) =>
    MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (BuildContext context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child,
            ),
          ),
        ),
      ),
    );

Widget _button(
  bool primary, {
  required String label,
  IconData? icon,
  ModelInteractiveState state = const ModelInteractiveState(),
  DsLoading loading = const DsLoadingWidget(),
  VoidCallback onPressed = _noop,
}) => primary
    ? DsPrimaryButtonWidget(
        label: label,
        icon: icon,
        state: state,
        loading: loading,
        loadingSemanticLabel: 'Cargando',
        onPressed: onPressed,
      )
    : DsSecondaryButtonWidget(
        label: label,
        icon: icon,
        state: state,
        loading: loading,
        loadingSemanticLabel: 'Cargando',
        onPressed: onPressed,
      );

ShapeDecoration _surface(WidgetTester tester, Type button) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(button),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as ShapeDecoration;

void _noop() {}

class _CustomLoading extends DsLoading {
  const _CustomLoading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Inner loader',
    child: const Icon(Icons.more_horiz, size: 12),
  );
}
