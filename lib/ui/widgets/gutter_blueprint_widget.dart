part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Visualizes a **gutter** area based on [BlocResponsive.gutterWidth].
///
/// Useful as a design aide, spacer, or to debug grid spacing.
/// Supports **horizontal** (height = gutterWidth) and **vertical**
/// (width = gutterWidth) orientations, optional hatch, and custom extent.
///
/// ### Parameters
/// - [responsive]: Responsive metrics (required).
/// - [axis]: Orientation of the gutter ([Axis.horizontal] or [Axis.vertical]).
/// - [extent]: Length along the main axis (if null, expands).
/// - [color]: Base fill color; defaults to a subtle outline variant.
/// - [showHatch]: If `true`, draws a diagonal hatch inside the gutter.
/// - [radius]: Corner radius.
/// - [opacity]: Master overlay opacity.
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(1280, 800));
///
/// Row(
///   children: [
///     SizedBox(width: resp.widthByColumns(3), child: const Placeholder()),
///     GutterBlueprintWidget(responsive: resp, axis: Axis.vertical, extent: 200),
///     SizedBox(width: resp.widthByColumns(3), child: const Placeholder()),
///   ],
/// );
/// ```
class GutterBlueprintWidget extends StatelessWidget {
  const GutterBlueprintWidget({
    required this.responsive,
    super.key,
    this.axis = Axis.vertical,
    this.extent,
    this.color,
    this.showHatch = true,
    this.radius = 6.0,
    this.opacity = 0.25,
  });

  final BlocResponsive responsive;
  final Axis axis;
  final double? extent;
  final Color? color;
  final bool showHatch;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double thickness = responsive.gutterWidth;
    final Color fill = (color ?? scheme.outlineVariant).withValues(alpha: 0.65);

    final Widget painter = CustomPaint(
      painter: _GutterPainter(
        color: fill,
        showHatch: showHatch,
        radius: radius,
      ),
    );

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width:
              axis == Axis.vertical ? thickness : (extent ?? double.infinity),
          height:
              axis == Axis.horizontal ? thickness : (extent ?? double.infinity),
          child: painter,
        ),
      ),
    );
  }
}

class _GutterPainter extends CustomPainter {
  _GutterPainter({
    required this.color,
    required this.showHatch,
    required this.radius,
  });

  final Color color;
  final bool showHatch;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Paint p = Paint()..color = color;
    canvas.drawRRect(r, p);

    if (!showHatch) {
      return;
    }

    final Paint hatch = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;

    const double step = 8.0;
    // Draw ↘ diagonals across the rect
    for (double y = -size.width; y < size.height + size.width; y += step) {
      final Offset p1 = Offset(0, y);
      final Offset p2 = Offset(size.width, y - size.width);
      canvas.drawLine(p1, p2, hatch);
    }
  }

  @override
  bool shouldRepaint(covariant _GutterPainter oldDelegate) {
    return color != oldDelegate.color ||
        showHatch != oldDelegate.showHatch ||
        radius != oldDelegate.radius;
  }
}
