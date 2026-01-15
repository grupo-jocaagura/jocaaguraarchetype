part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

@immutable
class DsDataVizPaletteExtension
    extends ThemeExtension<DsDataVizPaletteExtension> {
  const DsDataVizPaletteExtension({
    required this.palette,
  });

  final ModelDataVizPalette palette;

  @override
  DsDataVizPaletteExtension copyWith({
    ModelDataVizPalette? palette,
  }) {
    return DsDataVizPaletteExtension(
      palette: palette ?? this.palette,
    );
  }

  @override
  DsDataVizPaletteExtension lerp(
    ThemeExtension<DsDataVizPaletteExtension>? other,
    double time,
  ) {
    if (other is! DsDataVizPaletteExtension) {
      return this;
    }
    return (time < 0.5) ? this : other;
  }
}

extension DsDataVizContextX on BuildContext {
  ModelDataVizPalette get dsDataViz {
    final DsDataVizPaletteExtension? ext =
        Theme.of(this).extension<DsDataVizPaletteExtension>();
    if (ext == null) {
      throw StateError(
        'Missing DsDataVizPaletteExtension in ThemeData.extensions',
      );
    }
    return ext.palette;
  }
}
