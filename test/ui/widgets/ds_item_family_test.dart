import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('all DS text widgets follow their theme role', (
    WidgetTester tester,
  ) async {
    const List<DsInlineTextWidget> samples = <DsInlineTextWidget>[
      DsTextDisplayLargeWidget(label: 'displayLarge'),
      DsTextDisplayMediumWidget(label: 'displayMedium'),
      DsTextDisplaySmallWidget(label: 'displaySmall'),
      DsTextHeadlineLargeWidget(label: 'headlineLarge'),
      DsTextHeadlineMediumWidget(label: 'headlineMedium'),
      DsTextHeadlineSmallWidget(label: 'headlineSmall'),
      DsTextTitleLargeWidget(label: 'titleLarge'),
      DsTextTitleMediumWidget(label: 'titleMedium'),
      DsTextTitleSmallWidget(label: 'titleSmall'),
      DsTextBodyLargeWidget(label: 'bodyLarge'),
      DsTextBodyMediumWidget(label: 'bodyMedium'),
      DsTextBodySmallWidget(label: 'bodySmall'),
      DsTextLabelLargeWidget(label: 'labelLarge'),
      DsTextLabelMediumWidget(label: 'labelMedium'),
      DsTextLabelSmallWidget(label: 'labelSmall'),
      DsInlineTextWidget(label: 'generic', role: DsTextStyleKey.titleSmall),
    ];
    TextTheme styles = const TextTheme();
    for (final DsTextStyleKey role in DsTextStyleKey.values) {
      styles = role.set(
        styles,
        TextStyle(fontSize: 10.0 + role.index, fontWeight: FontWeight.w800),
      );
    }

    await tester.pumpWidget(
      _host(
        const Wrap(children: samples),
        theme: ThemeData(textTheme: styles),
      ),
    );

    for (final DsInlineTextWidget sample in samples) {
      final Text text = tester.widget<Text>(find.text(sample.label));
      final DsTextStyleKey expectedRole = sample.label == 'generic'
          ? DsTextStyleKey.titleSmall
          : DsTextStyleKey.values.byName(sample.label);
      expect(text.style!.fontSize, 10.0 + expectedRole.index);
      expect(text.style!.fontWeight, FontWeight.w800);
    }
  });

  testWidgets('paragraph applies its theme role and line limit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DsTextParagraphWidget(
              label: 'Paragraph copy',
              paragraphStyle: DsTextParagraphStyle.detail,
              maxLines: 3,
              semanticLabel: 'Complete paragraph',
            ),
            DsTextParagraphWidget(
              label: 'Explicit role',
              paragraphStyle: DsTextParagraphStyle.detail,
              role: DsTextStyleKey.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        theme: ThemeData(
          textTheme: const TextTheme(
            bodySmall: TextStyle(fontSize: 19),
            labelMedium: TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
    final Text text = tester.widget<Text>(find.text('Paragraph copy'));
    expect(text.style!.fontSize, 19);
    expect(text.maxLines, 3);
    expect(text.semanticsLabel, 'Complete paragraph');
    final Text explicit = tester.widget<Text>(find.text('Explicit role'));
    expect(explicit.style!.fontSize, 17);
    expect(explicit.overflow, TextOverflow.ellipsis);
  });

  testWidgets('short labels keep the default and themed compact sizes', (
    WidgetTester tester,
  ) async {
    const Widget item = DsItemWidget(label: 'OK', child: Icon(Icons.star));
    await tester.pumpWidget(_host(item));
    expect(tester.getSize(find.byType(DsItemWidget)), const Size.square(64));
    final ThemeData tokenTheme = defaultModelDesignSystem()
        .copyWith(tokens: const ModelDsExtendedTokens(spacingXXl: 72))
        .toThemeData(brightness: Brightness.light);
    await tester.pumpWidget(_host(item, theme: tokenTheme));
    expect(tester.getSize(find.byType(DsItemWidget)), const Size.square(72));
    expect(find.byType(InkWell), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a scaled translated label wraps and grows without reducing labelMedium',
    (WidgetTester tester) async {
      const String label = 'Configuration and alerts';
      const Size preferred = Size(104, 68);
      const TextHeightBehavior heightBehavior = TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      );
      await tester.pumpWidget(
        _host(
          DefaultTextStyle.merge(
            softWrap: false,
            textHeightBehavior: heightBehavior,
            child: const MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: DsItemWidget(
                size: preferred,
                variant: DsSurfaceVariant.outlined,
                label: label,
                child: Icon(Icons.bookmark),
              ),
            ),
          ),
          theme: ThemeData(
            textTheme: const TextTheme(
              labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
      final Size rendered = tester.getSize(find.byType(DsItemWidget));
      expect(rendered.width, preferred.width);
      expect(rendered.height, greaterThan(preferred.height));
      final Text text = tester.widget<Text>(find.text(label));
      expect(text.style!.fontSize, 16);
      expect(text.style!.fontWeight, FontWeight.w800);
      expect(text.maxLines, greaterThan(1));
      expect(
        tester
            .widget<DsTextParagraphWidget>(find.byType(DsTextParagraphWidget))
            .role,
        DsTextStyleKey.labelMedium,
      );
      final RenderParagraph paragraph = _paragraph(tester, label);
      expect(paragraph.textScaler.scale(10), 20);
      expect(paragraph.textHeightBehavior, heightBehavior);
      expect(paragraph.softWrap, isTrue);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(
        paragraph
            .getBoxesForSelection(
              const TextSelection(baseOffset: 0, extentOffset: label.length),
            )
            .last
            .bottom,
        lessThanOrEqualTo(paragraph.size.height),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a tight grid keeps complete semantics when the label is truncated',
    (WidgetTester tester) async {
      const String label = 'Notification settings';
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        for (final bool interactive in <bool>[false, true]) {
          final Widget item = interactive
              ? DsItemButtonWidget(
                  label: label,
                  onPressed: () {},
                  child: const Icon(Icons.settings),
                )
              : const DsItemWidget(label: label, child: Icon(Icons.settings));
          await tester.pumpWidget(
            _host(
              MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(3)),
                child: SizedBox.square(dimension: 48, child: item),
              ),
            ),
          );
          expect(
            tester.getSize(find.byType(DsItemWidget)),
            const Size.square(48),
          );
          expect(
            tester.widget<Text>(find.text(label)).overflow,
            TextOverflow.ellipsis,
          );
          expect(_paragraph(tester, label).didExceedMaxLines, isTrue);
          expect(
            tester.getSemantics(find.bySemanticsLabel(label)).label,
            label,
          );
          expect(tester.takeException(), isNull);
        }
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'one accessible button supports tap, keyboard and semantic activation',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int taps = 0;
      await tester.pumpWidget(
        _host(
          DsItemButtonWidget(
            label: 'Open',
            semanticLabel: ' Open folder ',
            onPressed: () => taps++,
            child: const Icon(Icons.folder, semanticLabel: 'Inner icon'),
          ),
        ),
      );

      final Finder button = find.bySemanticsLabel('Open folder');
      expect(button, findsOneWidget);
      expect(find.bySemanticsLabel('Inner icon'), findsNothing);
      final SemanticsNode node = tester.getSemantics(button);
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(node.childrenCount, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
      tester.semantics.tap(find.semantics.byLabel('Open folder'));
      expect(taps, 2);
      await tester.tap(find.byType(DsItemButtonWidget));
      expect(taps, 3);
      semantics.dispose();
    },
  );

  testWidgets(
    'state priority keeps selection, supports retry and bounds loading',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int taps = 0;
      Future<void> render(
        ModelInteractiveState state, {
        DsLoading loading = const DsLoadingWidget(),
      }) => tester.pumpWidget(
        _host(
          DsItemButtonWidget(
            label: 'Save',
            state: state,
            loading: loading,
            onPressed: () => taps++,
            child: const Icon(Icons.save),
          ),
        ),
      );
      final Finder button = find.byType(DsItemButtonWidget);

      await render(
        const ModelInteractiveState(isVisible: false, isLoading: true),
      );
      expect(find.byType(DsItemWidget), findsNothing);
      await render(
        const ModelInteractiveState(isLoading: true, errorText: 'Retry'),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Save')).value,
        'Loading',
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Save'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      await tester.tap(button);
      expect(taps, 0);
      expect(
        tester.getSize(find.byType(CircularProgressIndicator)),
        const Size.square(24),
      );

      await render(
        const ModelInteractiveState(isLoading: true),
        loading: const _CustomLoading(),
      );
      expect(find.byType(_CustomLoading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await render(
        const ModelInteractiveState(isSelected: true, isEnabled: false),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Save'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      await tester.tap(button);
      expect(taps, 0);

      await render(const ModelInteractiveState(errorText: 'Try again'));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Save')).hint,
        'Try again',
      );
      await tester.tap(button);
      expect(taps, 1);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets(
    'semantic surfaces use DS or brightness fallback and keep default label contrast',
    (WidgetTester tester) async {
      for (final Brightness brightness in Brightness.values) {
        final ModelSemanticColors fallback = brightness == Brightness.dark
            ? ModelSemanticColors.fallbackDark()
            : ModelSemanticColors.fallbackLight();
        final ModelSemanticColors custom = fallback.copyWith(
          successContainer: const Color(0xFF003152),
          onSuccessContainer: Colors.white,
          warningContainer: const Color(0xFF512819),
          onWarningContainer: Colors.white,
        );
        for (final bool useExtension in <bool>[false, true]) {
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
              await tester.pumpWidget(
                _host(
                  DsItemButtonWidget(
                    label: 'Action',
                    state: ModelInteractiveState(semantic: intent),
                    variant: variant,
                    onPressed: () {},
                    child: const Icon(Icons.star),
                  ),
                  theme: theme,
                ),
              );
              final Material surface = tester.widget<Material>(
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
              expect(surface.color, outlined ? colors.surface : container);
              if (outlined) {
                expect(
                  (surface.shape! as RoundedRectangleBorder).side.color,
                  border,
                );
              }
              final Color labelColor = tester
                  .widget<Text>(find.text('Action'))
                  .style!
                  .color!;
              expect(labelColor, outlined ? colors.onSurface : onContainer);
              expect(
                _contrast(surface.color!, labelColor),
                greaterThanOrEqualTo(4.5),
                reason: '$brightness / $variant / $intent',
              );
            }
          }
        }
      }
    },
  );
}

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  home: Scaffold(body: Center(child: child)),
);

RenderParagraph _paragraph(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(
      find
          .descendant(of: find.text(label), matching: find.byType(RichText))
          .last,
    );

double _contrast(Color a, Color b) {
  final double aLuminance = a.computeLuminance();
  final double bLuminance = b.computeLuminance();
  return aLuminance > bLuminance
      ? (aLuminance + 0.05) / (bLuminance + 0.05)
      : (bLuminance + 0.05) / (aLuminance + 0.05);
}

class _CustomLoading extends DsLoading {
  const _CustomLoading();

  @override
  Widget build(BuildContext context) => const Icon(Icons.hourglass_empty);
}
