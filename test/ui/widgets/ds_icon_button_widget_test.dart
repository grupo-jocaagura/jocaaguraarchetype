import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('adjacent buttons each own their full square target', (
    WidgetTester tester,
  ) async {
    final List<String> taps = <String>[];
    await tester.pumpWidget(
      _host(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DsIconButtonWidget(
              icon: Icons.add,
              semanticLabel: 'Add',
              onPressed: () => taps.add('add'),
            ),
            DsIconButtonWidget(
              icon: Icons.remove,
              semanticLabel: 'Remove',
              onPressed: () => taps.add('remove'),
            ),
          ],
        ),
      ),
    );

    final Finder buttons = find.byType(DsIconButtonWidget);
    final Rect left = tester.getRect(buttons.first);
    final Rect right = tester.getRect(buttons.last);
    expect(left.size, const Size.square(48));
    expect(right.size, const Size.square(48));
    expect(left.right, right.left);
    final Rect surface = tester.getRect(_surface(buttons.first));
    expect(surface.size, const Size.square(32));
    expect(surface.center, left.center);
    expect(
      tester.widget<DsIconButtonWidget>(buttons.first).variant,
      DsSurfaceVariant.filled,
    );

    await tester.tapAt(Offset(left.right - 1, left.top + 1));
    expect(taps, <String>['add']);
    await tester.tapAt(Offset(right.left + 1, right.top + 1));
    expect(taps, <String>['add', 'remove']);
  });

  testWidgets(
    'extra space in a grid cell stays outside the activation target',
    (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 100,
            height: 80,
            child: DsIconButtonWidget(
              icon: Icons.add,
              semanticLabel: 'Add',
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      final Rect cell = tester.getRect(find.byType(DsIconButtonWidget));
      final Rect target = tester.getRect(find.byType(InkWell));
      expect(target.size, const Size.square(48));
      expect(target.center, cell.center);
      await tester.tapAt(Offset(target.left - 1, target.center.dy));
      expect(taps, 0);
      await tester.tapAt(Offset(target.left + 1, target.center.dy));
      expect(taps, 1);
    },
  );

  testWidgets(
    'focus draws a ring and the named action works with keyboard and semantics',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        int taps = 0;
        await tester.pumpWidget(
          _host(
            DsIconButtonWidget(
              icon: Icons.add,
              semanticLabel: '  Add item  ',
              onPressed: () => taps++,
            ),
          ),
        );
        final Finder button = find.byType(DsIconButtonWidget);
        final Finder name = find.bySemanticsLabel('Add item');
        expect(name, findsOneWidget);
        expect(tester.getSemantics(name).flagsCollection.isButton, isTrue);
        expect(tester.getSemantics(name).childrenCount, 0);
        final Finder ring = find.descendant(
          of: button,
          matching: find.byWidgetPredicate((Widget widget) {
            return widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).border != null;
          }),
        );
        expect(ring, findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(ring, findsOneWidget);
        expect(tester.getSize(ring), const Size.square(48));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(taps, 1);
        tester.semantics.tap(find.semantics.byLabel('Add item'));
        expect(taps, 2);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('rejects a blank accessible action name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DsIconButtonWidget(
          icon: Icons.add,
          semanticLabel: '   ',
          onPressed: _noop,
        ),
      ),
    );
    expect(tester.takeException(), isArgumentError);
  });

  testWidgets(
    'controlled states keep their visual priority and activation rules',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        int taps = 0;
        Future<void> render(
          ModelInteractiveState state, {
          IconData? selectedIcon,
        }) => tester.pumpWidget(
          _host(
            DsIconButtonWidget(
              icon: Icons.favorite_border,
              selectedIcon: selectedIcon,
              semanticLabel: 'Toggle favorite',
              state: state,
              onPressed: () => taps++,
            ),
          ),
        );
        final Finder name = find.bySemanticsLabel('Toggle favorite');
        final Finder button = find.byType(DsIconButtonWidget);
        await render(const ModelInteractiveState(isSelected: true));
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);

        await render(
          const ModelInteractiveState(
            isEnabled: false,
            isSelected: true,
            reasonText: 'Locked',
          ),
          selectedIcon: Icons.favorite,
        );
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(tester.getSemantics(name).hint, 'Locked');
        expect(
          tester
              .getSemantics(name)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
        );
        await tester.tap(button);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(taps, 0);

        await render(
          const ModelInteractiveState(
            isLoading: true,
            isSelected: true,
            errorText: 'Retry',
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
        expect(find.byIcon(Icons.check), findsNothing);
        expect(find.byIcon(Icons.error_outline), findsNothing);
        expect(tester.getSemantics(name).value, 'Loading');
        expect(
          tester
              .getSemantics(name)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
        );
        await tester.tap(button);
        expect(taps, 0);

        await render(
          const ModelInteractiveState(errorText: 'Try again', isSelected: true),
        );
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.byIcon(Icons.check), findsNothing);
        tester.semantics.tap(find.semantics.byLabel('Toggle favorite'));
        expect(taps, 1);

        await render(
          const ModelInteractiveState(isVisible: false, isLoading: true),
        );
        expect(tester.getSize(button), Size.zero);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(name, findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'both loaders keep the action name and fit inside the icon slot',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        for (final DsLoading loading in const <DsLoading>[
          DsLoadingWidget(),
          _CustomLoading(),
        ]) {
          await tester.pumpWidget(
            _host(
              DsIconButtonWidget(
                icon: Icons.sync,
                semanticLabel: 'Sync settings',
                loadingSemanticLabel: 'Sincronizando',
                onPressed: _noop,
                state: const ModelInteractiveState(isLoading: true),
                loading: loading,
              ),
            ),
          );
          final Finder indicator = loading is DsLoadingWidget
              ? find.byType(CircularProgressIndicator)
              : find.byType(_CustomLoading);
          expect(tester.getSize(indicator), const Size.square(16));
          expect(
            tester.getSize(find.byType(DsIconButtonWidget)),
            const Size.square(48),
          );
          final Finder name = find.bySemanticsLabel('Sync settings');
          expect(name, findsOneWidget);
          expect(tester.getSemantics(name).value, 'Sincronizando');
          expect(find.bySemanticsLabel('Inner loader'), findsNothing);
        }
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'semantic colors are shared with the item button in both variants',
    (WidgetTester tester) async {
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
        for (final bool useExtension in <bool>[true, false]) {
          final ThemeData theme = ThemeData(
            brightness: brightness,
            extensions: <ThemeExtension<dynamic>>[
              if (useExtension) DsSemanticColorsExtension(semantic: custom),
            ],
          );
          final ModelSemanticColors expected = useExtension ? custom : fallback;
          for (final DsSurfaceVariant variant in DsSurfaceVariant.values) {
            for (final ModelInteractiveSemantic intent
                in ModelInteractiveSemantic.values) {
              final ModelInteractiveState state = ModelInteractiveState(
                semantic: intent,
              );
              await tester.pumpWidget(
                _host(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DsIconButtonWidget(
                        icon: Icons.add,
                        semanticLabel: 'Add',
                        variant: variant,
                        state: state,
                        onPressed: _noop,
                      ),
                      DsItemButtonWidget(
                        label: 'Add',
                        variant: variant,
                        state: state,
                        onPressed: _noop,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  theme: theme,
                ),
              );
              final Finder iconButton = find.byType(DsIconButtonWidget);
              final Material actual = tester.widget<Material>(
                _surface(iconButton),
              );
              final Material item = tester.widget<Material>(
                find
                    .descendant(
                      of: find.byType(DsItemWidget),
                      matching: find.byType(Material),
                    )
                    .first,
              );
              final ColorScheme colors = theme.colorScheme;
              final (
                Color container,
                Color onContainer,
                Color border,
              ) = switch (intent) {
                ModelInteractiveSemantic.success => (
                  expected.successContainer,
                  expected.onSuccessContainer,
                  expected.success,
                ),
                ModelInteractiveSemantic.warning => (
                  expected.warningContainer,
                  expected.onWarningContainer,
                  expected.warning,
                ),
                ModelInteractiveSemantic.danger => (
                  colors.errorContainer,
                  colors.onErrorContainer,
                  colors.error,
                ),
                ModelInteractiveSemantic.primary => (
                  colors.primaryContainer,
                  colors.onPrimaryContainer,
                  colors.primary,
                ),
                ModelInteractiveSemantic.secondary => (
                  colors.secondaryContainer,
                  colors.onSecondaryContainer,
                  colors.secondary,
                ),
                ModelInteractiveSemantic.neutral => (
                  colors.surfaceContainerHighest,
                  colors.onSurface,
                  colors.outline,
                ),
              };
              final bool outlined = variant == DsSurfaceVariant.outlined;
              expect(actual.color, outlined ? colors.surface : container);
              expect(actual.color, item.color);
              final BorderSide actualBorder =
                  (actual.shape! as CircleBorder).side;
              expect(
                actualBorder,
                outlined ? BorderSide(color: border) : BorderSide.none,
              );
              final DsIconWidget glyph = tester.widget<DsIconWidget>(
                find.descendant(
                  of: iconButton,
                  matching: find.byType(DsIconWidget),
                ),
              );
              expect(glyph.color, outlined ? colors.onSurface : onContainer);
            }
          }
        }
      }
    },
  );
}

void _noop() {}

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  home: Scaffold(body: Center(child: child)),
);

Finder _surface(Finder button) =>
    find.descendant(of: button, matching: find.byType(Material)).last;

class _CustomLoading extends DsLoading {
  const _CustomLoading();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 30,
    child: Icon(Icons.hourglass_empty, semanticLabel: 'Inner loader'),
  );
}
