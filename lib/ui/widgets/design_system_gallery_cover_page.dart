part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Shows the cover page for a design system gallery.
///
/// The cover is represented by a [ModelDsComponentAnatomy]. By convention, the
/// cover anatomy should use a stable id such as `ds.gallery.cover`.
class DesignSystemGalleryCoverPage extends StatelessWidget {
  const DesignSystemGalleryCoverPage({
    required this.anatomy,
    this.onStart,
    this.onOpenDetailedInfo,
    this.onOpenLink,
    super.key,
  });

  /// Anatomy metadata used to render the gallery cover.
  final ModelDsComponentAnatomy anatomy;

  /// Called when the user wants to start exploring the gallery.
  final VoidCallback? onStart;

  /// Called when the user requests detailed external information.
  final ValueChanged<ModelDsComponentAnatomy>? onOpenDetailedInfo;

  /// Called when the user selects an additional external link.
  final ValueChanged<ModelDsComponentLink>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                anatomy.name,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                anatomy.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: tokens.spacingLg),
              _GalleryTagsWrap(tags: anatomy.tags),
              SizedBox(height: tokens.spacingLg),
              _GalleryMetadataCard(anatomy: anatomy),
              SizedBox(height: tokens.spacingLg),
              _GalleryLinksCard(
                anatomy: anatomy,
                onOpenDetailedInfo: onOpenDetailedInfo,
                onOpenLink: onOpenLink,
              ),
              SizedBox(height: tokens.spacingXl),
              FilledButton(
                onPressed: onStart,
                child: const Text('Start gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
