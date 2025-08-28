part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Paints a responsive column grid "blueprint" to visualize margins, gutters
/// and column widths provided by [BlocResponsive].
///
/// Typical usage is to overlay this widget on top of a page while designing
/// or debugging responsive layouts.
///
/// ### What it shows
/// - Left/Right outer **margins**
/// - **Columns** areas (filled with a low-opacity color)
/// - **Gutters** between columns (optional hatch)
/// - Optional column **indices** labels
///
/// ### Parameters
/// - [responsive]: The [BlocResponsive] source of metrics.
/// - [columnsColor]: Fill color for columns (low opacity recommended).
/// - [guttersColor]: Color for gutter separators / hatch.
/// - [marginsColor]: Color for margins.
/// - [showGuttersHatch]: Whether to draw diagonal hatch on gutters.
/// - [showIndices]: Whether to draw column index labels (1-based).
/// - [height]: Constrains the blueprint height (defaults to expand).
/// - [radius]: Border radius applied to column rects.
/// - [strokeWidth]: Line thickness for outlines/hatch.
/// - [opacity]: Master opacity for the whole overlay.
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(1280, 800));
///
/// Stack(
///   children: [
///     MyContent(),
///     IgnorePointer( // allow clicks to pass-through
///       child: ColumnBlueprintWidget(
///         responsive: resp,
///         showIndices: true,
///         opacity: 0.5,
///       ),
///     ),
///   ],
/// );
/// ```
///
/// ### Notes
/// - This is a **debug/design** aid. Consider hiding it in production.
/// - Widths are based on `responsive.workAreaSize`, `marginWidth`,
///   `columnsNumber`, `columnWidth`, and `gutterWidth`.
class ColumnBlueprintWidget extends StatelessWidget {
  const ColumnBlueprintWidget({
    required this.responsive,
    super.key,
    this.columnsColor,
    this.guttersColor,
    this.marginsColor,
    this.showGuttersHatch = true,
    this.showIndices = false,
    this.height,
    this.radius = 6.0,
    this.strokeWidth = 1.0,
    this.opacity = 0.35,
  });

  final BlocResponsive responsive;
  final Color? columnsColor;
  final Color? guttersColor;
  final Color? marginsColor;
  final bool showGuttersHatch;
  final bool showIndices;
  final double? height;
  final double radius;
  final double strokeWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    // Mantener métricas sincronizadas con el contexto
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color colColor =
        (columnsColor ?? scheme.primary).withValues(alpha: 0.82);
    final Color gutColor =
        (guttersColor ?? scheme.outlineVariant).withValues(alpha: 0.45);
    final Color marColor =
        (marginsColor ?? scheme.error).withValues(alpha: 0.82);

    final double mh = responsive.marginWidth;
    final int cols = responsive.columnsNumber;
    final double cw = responsive.columnWidth;
    final double gw = responsive.gutterWidth;

    // Ancho útil de trabajo (donde viven columnas + gutters)
    final double workW = responsive.workAreaSize.width;

    final Widget painter = CustomPaint(
      size: Size(workW + mh * 2, height ?? double.infinity),
      painter: _BlueprintPainter(
        marginWidth: mh,
        columnsNumber: cols,
        columnWidth: cw,
        gutterWidth: gw,
        columnsColor: colColor,
        guttersColor: gutColor,
        marginsColor: marColor,
        showGuttersHatch: showGuttersHatch,
        showIndices: showIndices,
        radius: radius,
        strokeWidth: strokeWidth,
        textStyle: DefaultTextStyle.of(context).style.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.3),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
      ),
    );

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: RepaintBoundary(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: workW + mh * 2,
            height: height,
            child: painter,
          ),
        ),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  _BlueprintPainter({
    required this.marginWidth,
    required this.columnsNumber,
    required this.columnWidth,
    required this.gutterWidth,
    required this.columnsColor,
    required this.guttersColor,
    required this.marginsColor,
    required this.showGuttersHatch,
    required this.showIndices,
    required this.radius,
    required this.strokeWidth,
    required this.textStyle,
  });

  final double marginWidth;
  final int columnsNumber;
  final double columnWidth;
  final double gutterWidth;
  final Color columnsColor;
  final Color guttersColor;
  final Color marginsColor;
  final bool showGuttersHatch;
  final bool showIndices;
  final double radius;
  final double strokeWidth;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final double fullW = size.width;
    final double h = size.height.isFinite ? size.height : 2000.0; // fallback
    final double workW = fullW - marginWidth * 2;

    final Paint pCols = Paint()..color = columnsColor;
    final Paint pGuts = Paint()
      ..color = guttersColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final Paint pMargins = Paint()..color = marginsColor;

    // Margins (left/right bands)
    final Rect leftMargin = Rect.fromLTWH(0, 0, marginWidth, h);
    final Rect rightMargin =
        Rect.fromLTWH(fullW - marginWidth, 0, marginWidth, h);
    canvas.drawRect(leftMargin, pMargins);
    canvas.drawRect(rightMargin, pMargins);

    // Columns + Guts
    double x = marginWidth;
    RRect rrect(Rect r) => RRect.fromRectAndRadius(r, Radius.circular(radius));

    final TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    for (int i = 0; i < columnsNumber; i++) {
      // Draw column
      final Rect col = Rect.fromLTWH(x, 0, columnWidth, h);
      canvas.drawRRect(rrect(col), pCols);

      // Label index (center-top)
      if (showIndices) {
        tp.text = TextSpan(text: '${i + 1}', style: textStyle);
        tp.layout(maxWidth: columnWidth);
        final Offset textOffset = Offset(
          x + (columnWidth - tp.width) / 2,
          6.0,
        );
        tp.paint(canvas, textOffset);
      }

      x += columnWidth;

      // Draw gutter (separator line + hatch)
      final bool hasGutter = i < columnsNumber - 1;
      if (hasGutter) {
        // vertical separator line centered in gutter
        final double gx = x + gutterWidth / 2;
        canvas.drawLine(Offset(gx, 0), Offset(gx, h), pGuts);

        if (showGuttersHatch) {
          _drawHatch(
            canvas,
            Offset(x, 0),
            gutterWidth,
            h,
            guttersColor,
            strokeWidth,
          );
        }
        x += gutterWidth;
      }
    }

    // Outline full work area (optional subtle stroke using guttersColor)
    final Paint outline = Paint()
      ..color = guttersColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRect(Rect.fromLTWH(marginWidth, 0, workW, h), outline);
  }

  void _drawHatch(
    Canvas canvas,
    Offset origin,
    double w,
    double h,
    Color color,
    double stroke,
  ) {
    final Paint p = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = stroke;

    const double step = 8.0;
    // Diagonals ↘ across the gutter
    for (double y = 0; y < h + w; y += step) {
      final Offset p1 = Offset(origin.dx, origin.dy + y);
      final Offset p2 = Offset(origin.dx + w, origin.dy + y - w);
      canvas.drawLine(p1, p2, p);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter old) {
    return marginWidth != old.marginWidth ||
        columnsNumber != old.columnsNumber ||
        columnWidth != old.columnWidth ||
        gutterWidth != old.gutterWidth ||
        columnsColor != old.columnsColor ||
        guttersColor != old.guttersColor ||
        marginsColor != old.marginsColor ||
        showGuttersHatch != old.showGuttersHatch ||
        showIndices != old.showIndices ||
        radius != old.radius ||
        strokeWidth != old.strokeWidth ||
        textStyle != old.textStyle;
  }
}
