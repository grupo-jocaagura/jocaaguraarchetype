part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Constrains [child] to the width of **3 responsive columns**.
///
/// See [Responsive1x1Widget] for details.
class Responsive1x3Widget extends ResponsiveNxBase {
  const Responsive1x3Widget({
    required super.responsive,
    required super.child,
    super.key,
    super.alignment,
    super.padding,
  }) : super(columns: 3);
}
