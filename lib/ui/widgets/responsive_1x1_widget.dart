part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Constrains [child] to the width of **1 responsive column** and centers it
/// within the work area (margins from [BlocResponsive] are applied).
///
/// ### Example
/// ```dart
/// Responsive1x1Widget(
///   responsive: resp,
///   child: TextField(controller: c),
/// );
/// ```
class Responsive1x1Widget extends ResponsiveNxBase {
  const Responsive1x1Widget({
    required super.responsive,
    required super.child,
    super.key,
    super.alignment,
    super.padding,
  }) : super(columns: 1);
}
