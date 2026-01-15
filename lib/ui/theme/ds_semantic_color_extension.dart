part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

@immutable
class DsSemanticColorsExtension
    extends ThemeExtension<DsSemanticColorsExtension> {
  const DsSemanticColorsExtension({
    required this.semantic,
  });

  final ModelSemanticColors semantic;

  @override
  DsSemanticColorsExtension copyWith({
    ModelSemanticColors? semantic,
  }) {
    return DsSemanticColorsExtension(
      semantic: semantic ?? this.semantic,
    );
  }

  @override
  DsSemanticColorsExtension lerp(
    ThemeExtension<DsSemanticColorsExtension>? other,
    double time,
  ) {
    if (other is! DsSemanticColorsExtension) {
      return this;
    }
    return (time < 0.5) ? this : other;
  }
}

extension DsSemanticContextX on BuildContext {
  ModelSemanticColors get dsSemantic {
    final DsSemanticColorsExtension? ext =
        Theme.of(this).extension<DsSemanticColorsExtension>();
    if (ext == null) {
      throw StateError(
        'Missing DsSemanticColorsExtension in ThemeData.extensions',
      );
    }
    return ext.semantic;
  }
}
