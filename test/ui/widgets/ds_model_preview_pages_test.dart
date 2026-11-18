import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DS model preview pages', () {
    testWidgets(
      'Given ModelThemeData When rendered Then shows theme sections',
      (WidgetTester tester) async {
        final ModelThemeData model = ModelThemeData(
          lightScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          darkScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          lightTextTheme: Typography.material2021().black,
          darkTextTheme: Typography.material2021().white,
          useMaterial3: true,
        );

        await tester.pumpWidget(
          MaterialApp(home: ModelThemeDataPage(model: model)),
        );

        expect(find.text('ModelThemeData'), findsOneWidget);
        expect(find.text('Theme config'), findsOneWidget);
        expect(find.text('Light ColorScheme'), findsOneWidget);
        expect(find.text('Dark ColorScheme'), findsOneWidget);
      },
    );

    testWidgets('Theme previews keep the extensions supplied by the model', (
      WidgetTester tester,
    ) async {
      final ModelDesignSystem designSystem = defaultModelDesignSystem()
          .copyWith(tokens: const ModelDsExtendedTokens(spacing: 20));
      await tester.pumpWidget(
        MaterialApp(
          theme: designSystem.toThemeData(brightness: Brightness.light),
          home: ModelThemeDataPage(
            model: _ThemeModelWithExtensions(designSystem),
          ),
        ),
      );

      final Iterable<Element> previews = tester.elementList(
        find.byType(TextThemePreviewWidget),
      );
      expect(previews, hasLength(2));
      for (final Element preview in previews) {
        expect(preview.dsTokens, designSystem.tokens);
        expect(preview.dsDataViz, designSystem.dataViz);
        expect(
          preview.dsSemantic,
          Theme.of(preview).brightness == Brightness.dark
              ? designSystem.semanticDark
              : designSystem.semanticLight,
        );
      }
    });

    testWidgets('Given TextTheme When rendered Then shows text style names', (
      WidgetTester tester,
    ) async {
      final TextTheme textTheme = Typography.material2021().black;

      await tester.pumpWidget(
        MaterialApp(home: TextThemePage(textTheme: textTheme)),
      );

      expect(find.text('TextTheme'), findsWidgets);
      expect(find.text(TextThemeKeys.displayLarge), findsOneWidget);
      expect(find.text(TextThemeKeys.bodyMedium), findsOneWidget);
      expect(find.text(TextThemeKeys.labelSmall), findsOneWidget);
    });

    testWidgets(
      'Given ModelDsExtendedTokens When rendered Then shows token sections',
      (WidgetTester tester) async {
        const ModelDsExtendedTokens model = ModelDsExtendedTokens();

        await tester.pumpWidget(
          const MaterialApp(home: ModelDsExtendedTokensPage(model: model)),
        );

        expect(find.text('ModelDsExtendedTokens'), findsOneWidget);
        expect(find.text('Spacing'), findsOneWidget);
        expect(find.text('Border radius'), findsOneWidget);
        expect(find.text('Elevation'), findsOneWidget);
        expect(find.text('Alpha'), findsOneWidget);
        expect(find.text('Animation durations'), findsOneWidget);
      },
    );

    testWidgets(
      'Given ModelSemanticColors When rendered Then shows semantic pairs',
      (WidgetTester tester) async {
        final ModelSemanticColors model = ModelSemanticColors.fallbackLight();

        await tester.pumpWidget(
          MaterialApp(home: ModelSemanticColorsPage(model: model)),
        );

        expect(find.text('ModelSemanticColors'), findsAtLeast(1));
        expect(find.text('success'), findsOneWidget);
        expect(find.text('warning'), findsOneWidget);
        expect(find.text('info'), findsOneWidget);
      },
    );

    testWidgets(
      'Given ModelDataVizPalette When rendered Then shows palette sections',
      (WidgetTester tester) async {
        final ModelDataVizPalette model = ModelDataVizPalette.fallback();

        await tester.pumpWidget(
          MaterialApp(home: ModelDataVizPalettePage(model: model)),
        );

        expect(find.text('ModelDataVizPalette'), findsOneWidget);
        expect(find.text('Categorical'), findsOneWidget);
        expect(find.text('Sequential'), findsOneWidget);
        expect(find.text('Palette helpers'), findsOneWidget);
      },
    );
    testWidgets(
      'Given SideBySideWidget inside scroll view When rendered Then shows previews',
      (WidgetTester tester) async {
        final ModelDesignSystem designSystem = defaultModelDesignSystem();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Text('Before preview'),
                    SideBySideWidget(
                      designSystem: designSystem,
                      builder: (BuildContext context) {
                        return const Text('Preview child');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Before preview'), findsOneWidget);
        expect(find.text('Preview child'), findsNWidgets(2));
      },
    );
    testWidgets(
      'Given SideBySideWidget When rendered Then shows light and dark previews',
      (WidgetTester tester) async {
        final ModelDesignSystem designSystem = defaultModelDesignSystem();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SideBySideWidget(
                designSystem: designSystem,
                spacing: 12,
                builder: (BuildContext context) {
                  return const Text('Preview child');
                },
              ),
            ),
          ),
        );

        expect(find.text('Light'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('Preview child'), findsNWidgets(2));
        expect(
          tester
              .widget<SideBySideWidget>(find.byType(SideBySideWidget))
              .spacing,
          12,
        );
      },
    );

    testWidgets('Preview builders inherit the styling of their own panel', (
      WidgetTester tester,
    ) async {
      final ModelDesignSystem designSystem = defaultModelDesignSystem()
          .copyWith(tokens: const ModelDsExtendedTokens(spacing: 20));
      final Map<Brightness, Material?> surfaces = <Brightness, Material?>{};
      final Map<Brightness, Color?> textColors = <Brightness, Color?>{};
      final Map<Brightness, Color?> iconColors = <Brightness, Color?>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: SideBySideWidget(
                  designSystem: designSystem,
                  builder: (BuildContext context) {
                    final Brightness brightness = Theme.of(context).brightness;
                    surfaces[brightness] = context
                        .findAncestorWidgetOfExactType<Material>();
                    textColors[brightness] = DefaultTextStyle.of(context)
                        .style
                        .color;
                    iconColors[brightness] = IconTheme.of(context).color;
                    return const Text('Preview child');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      for (final ColorScheme scheme in <ColorScheme>[
        designSystem.theme.lightScheme,
        designSystem.theme.darkScheme,
      ]) {
        expect(surfaces[scheme.brightness]?.color, scheme.surface);
        expect(textColors[scheme.brightness], scheme.onSurface);
        expect(iconColors[scheme.brightness], scheme.onSurface);
      }
      final Rect light = tester.getRect(
        find.byWidget(surfaces[Brightness.light]!),
      );
      final Rect dark = tester.getRect(
        find.byWidget(surfaces[Brightness.dark]!),
      );
      expect(dark.left - light.right, designSystem.tokens.spacing);
      expect(tester.takeException(), isNull);
    });
  });
}

class _ThemeModelWithExtensions extends ModelThemeData {
  _ThemeModelWithExtensions(this.designSystem)
    : super(
        lightScheme: designSystem.theme.lightScheme,
        darkScheme: designSystem.theme.darkScheme,
        lightTextTheme: designSystem.theme.lightTextTheme,
        darkTextTheme: designSystem.theme.darkTextTheme,
        useMaterial3: designSystem.theme.useMaterial3,
      );

  final ModelDesignSystem designSystem;

  @override
  ThemeData toThemeData({required Brightness brightness}) {
    return super
        .toThemeData(brightness: brightness)
        .copyWith(
          extensions: <ThemeExtension<dynamic>>[
            DsDataVizPaletteExtension(palette: designSystem.dataViz),
            DsSemanticColorsExtension(
              semantic: brightness == Brightness.dark
                  ? designSystem.semanticDark
                  : designSystem.semanticLight,
            ),
          ],
        );
  }
}
