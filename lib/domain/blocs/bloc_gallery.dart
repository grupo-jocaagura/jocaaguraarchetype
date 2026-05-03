part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// BLoC that controls the Design System gallery state.
///
/// This BLoC owns:
/// - the active [ModelDesignSystem],
/// - the current page index,
/// - the list of gallery pages.
///
/// It intentionally does not depend on Flutter Navigator. Consumers can embed
/// [DsGalleryPage] inside any app/navigation system.
class BlocGallery extends BlocModule {
  BlocGallery({
    ModelDesignSystem? designSystem,
    List<ModelDsGalleryPageEntry>? pages,
  }) : _state = BlocGeneral<ModelDsGalleryState>(
          ModelDsGalleryState(
            designSystem: designSystem ?? defaultModelDesignSystem(),
            pages: pages ??
                BlocGallery.defaultPages(
                  designSystem: designSystem ?? defaultModelDesignSystem(),
                ),
          ),
        );

  static const String name = 'BlocGallery';

  final BlocGeneral<ModelDsGalleryState> _state;

  Stream<ModelDsGalleryState> get stream => _state.stream;

  ModelDsGalleryState get state => _state.value;

  ModelDesignSystem get designSystem => state.designSystem;

  void emit(ModelDsGalleryState next) {
    if (next != _state.value) {
      _state.value = next;
    }
  }

  void next() {
    if (!state.canGoNext) {
      return;
    }

    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  void previous() {
    if (!state.canGoPrevious) {
      return;
    }

    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  void goTo(int index) {
    if (index < 0 || index >= state.pages.length) {
      return;
    }

    if (index == state.currentIndex) {
      return;
    }

    emit(state.copyWith(currentIndex: index));
  }

  void goToIndex() {
    final int index = state.pages.indexWhere(
      (ModelDsGalleryPageEntry page) => page.id == 'ds.gallery.index',
    );

    if (index >= 0) {
      goTo(index);
    }
  }

  void reset() {
    if (state.currentIndex == 0) {
      return;
    }

    emit(state.copyWith(currentIndex: 0));
  }

  void setDesignSystem(ModelDesignSystem designSystem) {
    final List<ModelDsGalleryPageEntry> nextPages =
        BlocGallery.defaultPages(designSystem: designSystem);

    final int nextIndex = state.currentIndex.clamp(
      0,
      nextPages.isEmpty ? 0 : nextPages.length - 1,
    );

    emit(
      ModelDsGalleryState(
        designSystem: designSystem,
        pages: nextPages,
        currentIndex: nextIndex,
      ),
    );
  }

  static List<ModelDsGalleryPageEntry> defaultPages({
    required ModelDesignSystem designSystem,
  }) {
    return <ModelDsGalleryPageEntry>[
      ModelDsGalleryPageEntry(
        id: 'ds.gallery.cover',
        title: 'Cover',
        section: 'Start',
        description: 'Design System gallery cover.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return DesignSystemGalleryCoverPage(
            anatomy: BlocGallery.defaultCoverAnatomy(),
            onStart: bloc.next,
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.gallery.index',
        title: 'Index',
        section: 'Start',
        description: 'Internal gallery index grouped by sections.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return DsGalleryIndexPage(
            state: state,
            onGoTo: bloc.goTo,
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.theme_data',
        title: 'ModelThemeData',
        section: 'Models',
        description: 'ColorScheme and TextTheme theme snapshot.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return ModelThemeDataPage(
            model: state.designSystem.theme,
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.text_theme.light',
        title: 'Light TextTheme',
        section: 'Typography',
        description: 'Typography scale for light theme.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return Theme(
            data: state.designSystem.theme.toThemeData(
              brightness: Brightness.light,
            ),
            child: TextThemePage(
              title: 'Light TextTheme',
              textTheme: state.designSystem.theme.lightTextTheme,
            ),
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.text_theme.dark',
        title: 'Dark TextTheme',
        section: 'Typography',
        description: 'Typography scale for dark theme.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return Theme(
            data: state.designSystem.theme.toThemeData(
              brightness: Brightness.dark,
            ),
            child: TextThemePage(
              title: 'Dark TextTheme',
              textTheme: state.designSystem.theme.darkTextTheme,
            ),
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.tokens',
        title: 'ModelDsExtendedTokens',
        section: 'Models',
        description: 'Spacing, radius, elevation, alpha and durations.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return ModelDsExtendedTokensPage(
            model: state.designSystem.tokens,
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.semantic_colors.light',
        title: 'Light Semantic Colors',
        section: 'Semantic Colors',
        description: 'Success, warning and info palette for light surfaces.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return ModelSemanticColorsPage(
            title: 'Light Semantic Colors',
            model: state.designSystem.semanticLight,
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.semantic_colors.dark',
        title: 'Dark Semantic Colors',
        section: 'Semantic Colors',
        description: 'Success, warning and info palette for dark surfaces.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return ModelSemanticColorsPage(
            title: 'Dark Semantic Colors',
            model: state.designSystem.semanticDark,
          );
        },
      ),
      ModelDsGalleryPageEntry(
        id: 'ds.model.data_viz',
        title: 'ModelDataVizPalette',
        section: 'Models',
        description: 'Categorical and sequential colors for charts.',
        builder: (
          BuildContext context,
          BlocGallery bloc,
          ModelDsGalleryState state,
        ) {
          return ModelDataVizPalettePage(
            model: state.designSystem.dataViz,
          );
        },
      ),
    ];
  }

  static ModelDsComponentAnatomy defaultCoverAnatomy() {
    return const ModelDsComponentAnatomy(
      id: 'ds.gallery.cover',
      name: 'cover',
      description:
          'Internal gallery for inspecting the active Design System models and reusable widgets.',
      tags: <String>[
        'gallery',
        'design-system',
        'documentation',
      ],
      status: ModelDsComponentStatusEnum.stable,
      platforms: <ModelDsComponentPlatformEnum>[
        ModelDsComponentPlatformEnum.android,
        ModelDsComponentPlatformEnum.ios,
        ModelDsComponentPlatformEnum.web,
        ModelDsComponentPlatformEnum.windows,
        ModelDsComponentPlatformEnum.macos,
        ModelDsComponentPlatformEnum.linux,
      ],
      slots: <ModelDsComponentSlot>[
        ModelDsComponentSlot(
          name: 'CoverContent',
          role: 'Presents the gallery purpose and the start action.',
          rules: <String>[
            'Must explain the gallery purpose.',
            'Must allow users to start the gallery flow.',
          ],
          tokensUsed: <String>[
            'spacing',
            'borderRadius',
            'titleLarge',
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _state.dispose();
  }
}
