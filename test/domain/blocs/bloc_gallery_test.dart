import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocGallery', () {
    test(
      'Given default gallery When created Then starts at cover page',
      () {
        final ModelDesignSystem designSystem = _fakeDesignSystem();
        final BlocGallery bloc = BlocGallery(designSystem: designSystem);

        expect(bloc.state.currentIndex, 0);
        expect(bloc.state.currentPage?.id, 'ds.gallery.cover');
        expect(bloc.state.canGoPrevious, isFalse);
        expect(bloc.state.canGoNext, isTrue);

        bloc.dispose();
      },
    );

    test(
      'Given gallery at first page When previous is called Then keeps index',
      () {
        final ModelDesignSystem designSystem = _fakeDesignSystem();
        final BlocGallery bloc = BlocGallery(designSystem: designSystem);

        bloc.previous();

        expect(bloc.state.currentIndex, 0);

        bloc.dispose();
      },
    );

    test(
      'Given gallery When goTo invalid index Then keeps current page',
      () {
        final ModelDesignSystem designSystem = _fakeDesignSystem();
        final BlocGallery bloc = BlocGallery(designSystem: designSystem);

        bloc.goTo(999);

        expect(bloc.state.currentIndex, 0);

        bloc.dispose();
      },
    );

    test(
      'Given gallery When reset is called Then returns to cover page',
      () {
        final ModelDesignSystem designSystem = _fakeDesignSystem();
        final BlocGallery bloc = BlocGallery(designSystem: designSystem);

        bloc.goTo(4);
        bloc.reset();

        expect(bloc.state.currentIndex, 0);
        expect(bloc.state.currentPage?.id, 'ds.gallery.cover');

        bloc.dispose();
      },
    );
    test(
      'Given default gallery When goToIndex is called Then moves to index page',
      () {
        final BlocGallery bloc = BlocGallery();

        bloc.goToIndex();

        expect(bloc.state.currentPage?.id, 'ds.gallery.index');

        bloc.dispose();
      },
    );

    test(
      'Given default gallery When grouped Then exposes pages by section',
      () {
        final BlocGallery bloc = BlocGallery();

        final Map<String, List<ModelDsGalleryPageEntry>> sections =
            bloc.state.pagesBySection;

        expect(sections.containsKey('Start'), isTrue);
        expect(sections.containsKey('Models'), isTrue);
        expect(sections.containsKey('Typography'), isTrue);

        bloc.dispose();
      },
    );
  });
}

ModelDesignSystem _fakeDesignSystem() {
  return ModelDesignSystem(
    theme: ModelThemeData(
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
    ),
    tokens: const ModelDsExtendedTokens(),
    semanticLight: ModelSemanticColors.fallbackLight(),
    semanticDark: ModelSemanticColors.fallbackDark(),
    dataViz: ModelDataVizPalette.fallback(),
  );
}
