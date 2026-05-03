part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Builds a gallery preview using the local preview [BuildContext].
///
/// This builder is useful when the same component must be rendered in
/// independent theme trees, such as light and dark side-by-side previews.
typedef GalleryPreviewBuilder = Widget Function(BuildContext context);

/// Builds an asset preview from a gallery asset key.
typedef GalleryAssetPreviewBuilder = Widget Function(
  BuildContext context,
  String previewAssetKey,
);

/// Builds a remote image preview from a gallery image URL.
typedef GalleryUrlImagePreviewBuilder = Widget Function(
  BuildContext context,
  String previewUrlImage,
);
