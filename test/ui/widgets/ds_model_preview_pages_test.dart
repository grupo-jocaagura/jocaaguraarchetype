import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('DS model preview pages', () {
    testWidgets(
      'Given ModelThemeData When rendered Then shows theme sections',
      (WidgetTester tester) async {
        final ModelThemeData model = ModelThemeData(
          lightScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
          darkScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          lightTextTheme: Typography.material2021().black,
          darkTextTheme: Typography.material2021().white,
          useMaterial3: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ModelThemeDataPage(model: model),
          ),
        );

        expect(find.text('ModelThemeData'), findsOneWidget);
        expect(find.text('Theme config'), findsOneWidget);
        expect(find.text('Light ColorScheme'), findsOneWidget);
        expect(find.text('Dark ColorScheme'), findsOneWidget);
      },
    );

    testWidgets(
      'Given TextTheme When rendered Then shows text style names',
      (WidgetTester tester) async {
        final TextTheme textTheme = Typography.material2021().black;

        await tester.pumpWidget(
          MaterialApp(
            home: TextThemePage(textTheme: textTheme),
          ),
        );

        expect(find.text('TextTheme'), findsWidgets);
        expect(find.text(TextThemeKeys.displayLarge), findsOneWidget);
        expect(find.text(TextThemeKeys.bodyMedium), findsOneWidget);
        expect(find.text(TextThemeKeys.labelSmall), findsOneWidget);
      },
    );

    testWidgets(
      'Given ModelDsExtendedTokens When rendered Then shows token sections',
      (WidgetTester tester) async {
        const ModelDsExtendedTokens model = ModelDsExtendedTokens();

        await tester.pumpWidget(
          const MaterialApp(
            home: ModelDsExtendedTokensPage(model: model),
          ),
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
          MaterialApp(
            home: ModelSemanticColorsPage(model: model),
          ),
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
          MaterialApp(
            home: ModelDataVizPalettePage(model: model),
          ),
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
      },
    );
  });
}
