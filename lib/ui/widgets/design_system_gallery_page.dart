part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Shows a design system anatomy page with optional live preview.
///
/// This page uses [ModelDsComponentAnatomy] as the single source of truth for
/// title, description, tags, slots, image references and external links.
class DesignSystemGalleryPage extends StatelessWidget {
  const DesignSystemGalleryPage({
    required this.anatomy,
    required this.designSystem,
    this.previewBuilder,
    this.previewAssetBuilder,
    this.previewUrlImageBuilder,
    this.onOpenDetailedInfo,
    this.onOpenLink,
    super.key,
  });

  /// Component anatomy metadata shown by the page.
  final ModelDsComponentAnatomy anatomy;

  /// Design system used for side-by-side previews.
  final ModelDesignSystem designSystem;

  /// Optional live Flutter preview.
  final GalleryPreviewBuilder? previewBuilder;

  /// Optional builder for [ModelDsComponentAnatomy.previewAssetKey].
  final GalleryAssetPreviewBuilder? previewAssetBuilder;

  /// Optional builder for [ModelDsComponentAnatomy.previewUrlImage].
  final GalleryUrlImagePreviewBuilder? previewUrlImageBuilder;

  /// Called when the user requests detailed external information.
  final ValueChanged<ModelDsComponentAnatomy>? onOpenDetailedInfo;

  /// Called when the user selects an additional external link.
  final ValueChanged<ModelDsComponentLink>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _GalleryHeader(anatomy: anatomy),
              const SizedBox(height: 24),
              if (previewBuilder != null) ...<Widget>[
                SideBySideWidget(
                  designSystem: designSystem,
                  builder: previewBuilder!,
                ),
                const SizedBox(height: 24),
              ],
              if (anatomy.previewAssetKey?.isNotEmpty ?? false) ...<Widget>[
                _GalleryAssetPreview(
                  previewAssetKey: anatomy.previewAssetKey.toString(),
                  previewAssetBuilder: previewAssetBuilder,
                ),
                const SizedBox(height: 24),
              ],
              if (anatomy.previewUrlImage?.isNotEmpty ?? false) ...<Widget>[
                _GalleryUrlImagePreview(
                  previewUrlImage: anatomy.previewUrlImage.toString(),
                  previewUrlImageBuilder: previewUrlImageBuilder,
                ),
                const SizedBox(height: 24),
              ],
              _GalleryDescriptionCard(anatomy: anatomy),
              const SizedBox(height: 16),
              _GallerySlotsCard(anatomy: anatomy),
              const SizedBox(height: 16),
              _GalleryLinksCard(
                anatomy: anatomy,
                onOpenDetailedInfo: onOpenDetailedInfo,
                onOpenLink: onOpenLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
