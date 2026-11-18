import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DsGalleryPage', () {
    testWidgets(
      'Given gallery page When index is tapped Then shows index page',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DsGalleryPage()));

        await tester.tap(find.text('Index'));
        await tester.pumpAndSettle();

        expect(find.text('Design System Gallery Index'), findsOneWidget);
        expect(find.text('ModelThemeData'), findsOneWidget);
        expect(find.text('ModelDsExtendedTokens'), findsOneWidget);
      },
    );

    testWidgets(
      'Given index page When ModelDataVizPalette tile is tapped Then opens data viz page',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DsGalleryPage()));

        await tester.tap(find.text('Index'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('ModelDataVizPalette'));
        await tester.pumpAndSettle();

        expect(find.text('ModelDataVizPalette'), findsWidgets);
        expect(find.text('Categorical'), findsOneWidget);
        expect(find.text('Sequential'), findsOneWidget);
      },
    );

    testWidgets('Releases its own BLoC and keeps the external BLoC usable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: DsGalleryPage()));
      final Stream<ModelDsGalleryState> internal = tester
          .widget<StreamBuilder<ModelDsGalleryState>>(
            find.byType(StreamBuilder<ModelDsGalleryState>),
          )
          .stream!;
      bool internalClosed = false;
      final StreamSubscription<ModelDsGalleryState> subscription = internal
          .listen(null, onDone: () => internalClosed = true);
      addTearDown(subscription.cancel);

      final BlocGallery external = BlocGallery()..goToIndex();
      addTearDown(external.dispose);
      await tester.pumpWidget(MaterialApp(home: DsGalleryPage(bloc: external)));
      await tester.pumpAndSettle();
      expect(internalClosed, isTrue);
      expect(find.text('Design System Gallery Index'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      external.next();
      await tester.pumpWidget(MaterialApp(home: DsGalleryPage(bloc: external)));
      await tester.pumpAndSettle();
      expect(find.text('Theme config'), findsOneWidget);
    });

    testWidgets('Component pages and previews follow the active DS', (
      WidgetTester tester,
    ) async {
      final ModelDesignSystem system = defaultModelDesignSystem().copyWith(
        tokens: const ModelDsExtendedTokens(
          spacing: 20,
          elevationXl: 10,
          borderRadiusXXl: 37,
          withAlpha: 0.20,
        ),
      );
      final BlocGallery bloc = BlocGallery(designSystem: system);
      addTearDown(bloc.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: DsGalleryPage(bloc: bloc),
        ),
      );
      await tester.tap(find.text('Index'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ListView>(find.byType(ListView)).padding,
        const EdgeInsets.all(20),
      );
      final Finder surfaceTile = find.text('DsLayeredSurfaceWidget');
      await tester.scrollUntilVisible(surfaceTile.hitTestable(), 200);
      await tester.pumpAndSettle();
      await tester.tap(surfaceTile);
      await tester.pumpAndSettle();

      final Finder surfaces = find.byType(DsLayeredSurfaceWidget);
      final Finder controls = find.byType(DsGalleryNavigationControls);
      final Finder navMaterial = find
          .descendant(of: controls, matching: find.byType(Material))
          .first;
      final Finder surfaceClips = find.descendant(
        of: surfaces,
        matching: find.byType(ClipRRect),
      );
      expect(surfaces, findsNWidgets(2));
      expect(
        Theme.of(tester.element(controls)).colorScheme,
        system.theme.darkScheme,
      );
      expect(tester.widget<Material>(navMaterial).elevation, 10);
      expect(
        tester
            .widgetList<ClipRRect>(surfaceClips)
            .map((ClipRRect clip) => clip.borderRadius),
        everyElement(BorderRadius.circular(37)),
      );

      final List<Element> previews = tester.elementList(surfaces).toList();
      expect(
        previews.map((Element context) => Theme.of(context).brightness),
        <Brightness>[Brightness.light, Brightness.dark],
      );
      expect(previews.first.dsSemantic, system.semanticLight);
      expect(previews.last.dsSemantic, system.semanticDark);
      for (final Element preview in previews) {
        expect(preview.dsTokens, system.tokens);
        expect(preview.dsDataViz, system.dataViz);
        expect(Theme.of(preview).cardTheme.elevation, system.tokens.elevation);
      }

      final ModelDsExtendedTokens updatedTokens = system.tokens.copyWith(
        spacing: 22,
        elevationXl: 11,
        borderRadiusXXl: 41,
        withAlpha: 0.22,
      );
      bloc.setDesignSystem(system.copyWith(tokens: updatedTokens));
      await tester.pumpAndSettle();

      expect(tester.widget<Material>(navMaterial).elevation, 11);
      expect(surfaces, findsNWidgets(2));
      expect(
        tester
            .widgetList<ClipRRect>(surfaceClips)
            .map((ClipRRect clip) => clip.borderRadius),
        everyElement(BorderRadius.circular(41)),
      );
      for (final Element preview in tester.elementList(surfaces)) {
        expect(preview.dsTokens, updatedTokens);
      }

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('DsInteractiveBuilder'), findsWidgets);
      expect(find.text('Enabled'), findsNWidgets(2));
      expect(find.text('Loading'), findsNWidgets(2));
      expect(find.text('Disabled'), findsNWidgets(2));
      expect(find.text('Unavailable'), findsNWidgets(2));
    });
  });
}
