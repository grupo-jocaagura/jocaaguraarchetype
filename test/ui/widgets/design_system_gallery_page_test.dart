import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('DesignSystemGalleryPage', () {
    testWidgets(
      'Given anatomy and preview builder When rendered Then shows side by side preview',
      (WidgetTester tester) async {
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy();
        final ModelDesignSystem designSystem = _fakeDesignSystem();

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryPage(
              anatomy: anatomy,
              designSystem: designSystem,
              previewBuilder: (BuildContext context) {
                return const Text('preview child');
              },
            ),
          ),
        );

        expect(find.text(anatomy.name), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('preview child'), findsNWidgets(2));
      },
    );

    testWidgets(
      'Given anatomy without preview builder When rendered Then does not show side by side preview',
      (WidgetTester tester) async {
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy();
        final ModelDesignSystem designSystem = _fakeDesignSystem();

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryPage(
              anatomy: anatomy,
              designSystem: designSystem,
            ),
          ),
        );

        expect(find.text(anatomy.name), findsOneWidget);
        expect(find.text('Light'), findsNothing);
        expect(find.text('Dark'), findsNothing);
      },
    );

    testWidgets(
      'Given preview asset key and asset builder When rendered Then uses asset builder',
      (WidgetTester tester) async {
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy(
          previewAssetKey: 'assets/previews/button.png',
        );
        final ModelDesignSystem designSystem = _fakeDesignSystem();

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryPage(
              anatomy: anatomy,
              designSystem: designSystem,
              previewAssetBuilder: (
                BuildContext context,
                String previewAssetKey,
              ) {
                return Text('asset $previewAssetKey');
              },
            ),
          ),
        );

        expect(
          find.text('asset assets/previews/button.png'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Given detailed info callback When button is tapped Then delegates action',
      (WidgetTester tester) async {
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy(
          urlDetailedInfo: 'https://example.com/spec',
        );
        final ModelDesignSystem designSystem = _fakeDesignSystem();
        ModelDsComponentAnatomy? selectedAnatomy;

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryPage(
              anatomy: anatomy,
              designSystem: designSystem,
              onOpenDetailedInfo: (ModelDsComponentAnatomy value) {
                selectedAnatomy = value;
              },
            ),
          ),
        );

        await tester.tap(find.text('Open detailed information'));
        await tester.pump();

        expect(selectedAnatomy, anatomy);
      },
    );

    testWidgets(
      'Given anatomy links When link is tapped Then delegates link action',
      (WidgetTester tester) async {
        const ModelDsComponentLink link = ModelDsComponentLink(
          label: 'Figma',
          url: 'https://example.com/figma',
        );
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy(
          links: <ModelDsComponentLink>[link],
        );
        final ModelDesignSystem designSystem = _fakeDesignSystem();
        ModelDsComponentLink? selectedLink;

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryPage(
              anatomy: anatomy,
              designSystem: designSystem,
              onOpenLink: (ModelDsComponentLink value) {
                selectedLink = value;
              },
            ),
          ),
        );

        await tester.tap(find.text('Figma'));
        await tester.pump();

        expect(selectedLink, link);
      },
    );
  });

  group('DesignSystemGalleryCoverPage', () {
    testWidgets(
      'Given cover anatomy When rendered Then shows cover information',
      (WidgetTester tester) async {
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy(
          id: 'ds.gallery.cover',
          name: 'cover',
          description: 'Design system gallery cover.',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryCoverPage(
              anatomy: anatomy,
            ),
          ),
        );

        expect(find.text('cover'), findsOneWidget);
        expect(find.text('Design system gallery cover.'), findsOneWidget);
      },
    );

    testWidgets(
      'Given start callback When start button is tapped Then calls onStart',
      (WidgetTester tester) async {
        final ModelDsComponentAnatomy anatomy = _fakeAnatomy(
          id: 'ds.gallery.cover',
          name: 'cover',
        );
        bool started = false;

        await tester.pumpWidget(
          MaterialApp(
            home: DesignSystemGalleryCoverPage(
              anatomy: anatomy,
              onStart: () {
                started = true;
              },
            ),
          ),
        );

        await tester.tap(find.text('Start gallery'));
        await tester.pump();

        expect(started, isTrue);
      },
    );
  });
}

ModelDsComponentAnatomy _fakeAnatomy({
  String id = 'ds.button.primary',
  String name = 'Primary button',
  String description = 'Primary action button.',
  String previewAssetKey = '',
  String previewUrlImage = '',
  String urlDetailedInfo = '',
  List<ModelDsComponentLink> links = const <ModelDsComponentLink>[],
}) {
  return ModelDsComponentAnatomy(
    id: id,
    name: name,
    description: description,
    tags: const <String>['button', 'action'],
    status: ModelDsComponentStatusEnum.stable,
    platforms: const <ModelDsComponentPlatformEnum>[
      ModelDsComponentPlatformEnum.web,
      ModelDsComponentPlatformEnum.windows,
      ModelDsComponentPlatformEnum.android,
      ModelDsComponentPlatformEnum.ios,
    ],
    previewAssetKey: previewAssetKey,
    previewUrlImage: previewUrlImage,
    urlDetailedInfo: urlDetailedInfo,
    links: links,
    slots: const <ModelDsComponentSlot>[
      ModelDsComponentSlot(
        name: 'Container',
        role: 'Holds the interactive surface.',
        rules: <String>['Use DS spacing and radius tokens.'],
        tokensUsed: <String>['spacing', 'borderRadius'],
      ),
    ],
  );
}

ModelDesignSystem _fakeDesignSystem() {
  return ModelDesignSystem(
    theme: ModelDesignSystem.fromThemeData(
      lightTheme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
    ),
    tokens: const ModelDsExtendedTokens(),
    semanticLight: ModelSemanticColors.fallbackLight(),
    semanticDark: ModelSemanticColors.fallbackDark(),
    dataViz: ModelDataVizPalette.fallback(),
  );
}
