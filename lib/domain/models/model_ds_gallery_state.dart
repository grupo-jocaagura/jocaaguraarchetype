part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Builds a gallery page from the gallery BLoC and current state.
///
/// The builder receives [BlocGallery] so cover pages or custom pages can call
/// gallery actions such as next, previous or goTo without depending on an
/// external navigation system.
typedef DsGalleryPageBuilder = Widget Function(
  BuildContext context,
  BlocGallery bloc,
  ModelDsGalleryState state,
);

/// Immutable descriptor for a gallery page.
@immutable
class ModelDsGalleryPageEntry {
  const ModelDsGalleryPageEntry({
    required this.id,
    required this.title,
    required this.builder,
    this.section = 'General',
    this.description = '',
  });

  final String id;
  final String title;
  final String section;
  final String description;
  final DsGalleryPageBuilder builder;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        section,
        description,
      );

  @override
  bool operator ==(Object other) {
    return other is ModelDsGalleryPageEntry &&
        other.id == id &&
        other.title == title &&
        other.section == section &&
        other.description == description;
  }
}

@immutable
class ModelDsGalleryState {
  const ModelDsGalleryState({
    required this.designSystem,
    required this.pages,
    this.currentIndex = 0,
  });

  final ModelDesignSystem designSystem;
  final List<ModelDsGalleryPageEntry> pages;
  final int currentIndex;

  int get pageCount => pages.length;

  bool get hasPages => pages.isNotEmpty;

  ModelDsGalleryPageEntry? get currentPage {
    if (!hasPages) {
      return null;
    }

    if (currentIndex < 0 || currentIndex >= pages.length) {
      return null;
    }

    return pages[currentIndex];
  }

  bool get canGoPrevious => hasPages && currentIndex > 0;

  bool get canGoNext => hasPages && currentIndex < pages.length - 1;

  String get pageIndicatorLabel {
    if (!hasPages) {
      return '0 / 0';
    }

    return '${currentIndex + 1} / ${pages.length}';
  }

  Map<String, List<ModelDsGalleryPageEntry>> get pagesBySection {
    final Map<String, List<ModelDsGalleryPageEntry>> out =
        <String, List<ModelDsGalleryPageEntry>>{};

    for (final ModelDsGalleryPageEntry page in pages) {
      out.putIfAbsent(page.section, () => <ModelDsGalleryPageEntry>[]);
      out[page.section]!.add(page);
    }

    return out;
  }

  int indexOfPage(ModelDsGalleryPageEntry page) {
    return pages.indexWhere(
      (ModelDsGalleryPageEntry candidate) => candidate.id == page.id,
    );
  }

  ModelDsGalleryState copyWith({
    ModelDesignSystem? designSystem,
    List<ModelDsGalleryPageEntry>? pages,
    int? currentIndex,
  }) {
    return ModelDsGalleryState(
      designSystem: designSystem ?? this.designSystem,
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
