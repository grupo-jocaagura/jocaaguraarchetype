part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reusable visual surface that composes DS gradient, texture and overlay.
///
/// The widget is intentionally visual-only. It does not execute business
/// logic, handle gestures, or know about button semantics.
class DsLayeredSurfaceWidget extends StatelessWidget {
  const DsLayeredSurfaceWidget({
    required this.child,
    required this.gradientColors,
    super.key,
    this.borderRadius,
    this.overlayColor,
    this.textureColor,
    this.textureHighlightColor,
    this.border,
    this.padding,
    this.opacity = 1.0,
  });

  /// Content rendered above all visual layers.
  final Widget child;

  /// Base DS colors used to build the gradient layer.
  final List<Color> gradientColors;

  /// Optional border radius. Defaults to the current DS radius token.
  final BorderRadius? borderRadius;

  /// Color mixed over the gradient and texture to improve contrast.
  final Color? overlayColor;

  /// Color used by the texture painter.
  final Color? textureColor;

  /// Opposite color used for the shifted texture highlight and shine.
  final Color? textureHighlightColor;

  /// Optional border rendered above the visual layers.
  final BoxBorder? border;

  /// Optional internal padding.
  final EdgeInsetsGeometry? padding;

  /// Overall visual opacity for disabled or quiet states.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final BorderRadius resolvedRadius =
        borderRadius ?? BorderRadius.circular(context.dsTokens.borderRadiusXXl);
    final List<Color> resolvedGradientColors = gradientColors.isEmpty
        ? <Color>[Theme.of(context).colorScheme.primary]
        : gradientColors;
    final Color resolvedOverlay =
        overlayColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);
    final Color resolvedTexture =
        textureColor ??
        Theme.of(context).colorScheme.surface.withValues(alpha: 0.16);
    final Color resolvedTextureHighlight =
        textureHighlightColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: resolvedGradientColors.length == 1
                  ? <Color>[
                      resolvedGradientColors.single,
                      resolvedGradientColors.single,
                    ]
                  : resolvedGradientColors,
            ),
            border: border,
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: DsOrganicTexturePainter(
                    color: resolvedTexture,
                    highlightColor: resolvedTextureHighlight,
                  ),
                ),
              ),
              Positioned.fill(child: ColoredBox(color: resolvedOverlay)),
              Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a subtle reusable organic texture for DS layered surfaces.
class DsOrganicTexturePainter extends CustomPainter {
  const DsOrganicTexturePainter({
    required this.color,
    required this.highlightColor,
  });

  /// Texture stroke and fill color.
  final Color color;

  /// Shifted opposite color used to create a metallic relief effect.
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final Paint veinPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.1, size.shortestSide * 0.062)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint highlightVeinPaint = Paint()
      ..color = highlightColor.withValues(alpha: highlightColor.a * 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.4, size.shortestSide * 0.008)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint contourPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.95, size.shortestSide * 0.1)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint highlightContourPaint = Paint()
      ..color = highlightColor.withValues(alpha: highlightColor.a * 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.34, size.shortestSide * 0.006)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _paintFlowingVeins(canvas, size, veinPaint);
    _paintOrganicContours(canvas, size, contourPaint);
    canvas.save();
    canvas.translate(size.shortestSide * 0.08, -size.shortestSide * 0.045);
    _paintFlowingVeins(canvas, size, highlightVeinPaint);
    _paintOrganicContours(canvas, size, highlightContourPaint);
    canvas.restore();
  }

  void _paintFlowingVeins(Canvas canvas, Size size, Paint paint) {
    final int lineCount = max(3, (size.height / 9).round());
    final double amplitude = max(2.0, size.shortestSide * 0.1);

    for (int index = 0; index < lineCount; index++) {
      final double baseY = (index + 0.45) * size.height / lineCount;
      final double phase = index * 1.61803398875;
      final Path path = Path()
        ..moveTo(-size.width * 0.05, _organicWaveY(baseY, phase, amplitude));

      const int segments = 5;
      for (int segment = 0; segment < segments; segment++) {
        final double startX = (segment / segments) * size.width;
        final double endX = ((segment + 1) / segments) * size.width;
        final double controlX1 = startX + size.width / segments * 0.34;
        final double controlX2 = startX + size.width / segments * 0.72;
        final double y1 = _organicWaveY(
          baseY,
          phase + segment * 0.78,
          amplitude,
        );
        final double y2 = _organicWaveY(
          baseY,
          phase + segment * 1.13,
          amplitude,
        );
        final double y3 = _organicWaveY(
          baseY,
          phase + segment * 1.47,
          amplitude,
        );

        path.cubicTo(controlX1, y1, controlX2, y2, endX, y3);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _paintOrganicContours(Canvas canvas, Size size, Paint paint) {
    final double cell = max(20.0, size.shortestSide * 0.58);
    int seed = 0;

    for (double x = -cell; x < size.width + cell; x += cell * 0.84) {
      for (double y = -cell; y < size.height + cell; y += cell * 0.72) {
        seed++;
        final double jitterX = (_hash(seed, 11) - 0.5) * cell * 0.48;
        final double jitterY = (_hash(seed, 23) - 0.5) * cell * 0.42;
        final Offset center = Offset(
          x + cell * 0.5 + jitterX,
          y + cell * 0.5 + jitterY,
        );
        final double radiusX = cell * (0.34 + _hash(seed, 37) * 0.22);
        final double radiusY = cell * (0.2 + _hash(seed, 41) * 0.18);
        final double startAngle = _hash(seed, 53) * pi * 2;
        final double sweep = pi * (0.95 + _hash(seed, 59) * 0.75);

        _paintIrregularArc(
          canvas: canvas,
          center: center,
          radiusX: radiusX,
          radiusY: radiusY,
          startAngle: startAngle,
          sweep: sweep,
          seed: seed,
          paint: paint,
        );
      }
    }
  }

  void _paintIrregularArc({
    required Canvas canvas,
    required Offset center,
    required double radiusX,
    required double radiusY,
    required double startAngle,
    required double sweep,
    required int seed,
    required Paint paint,
  }) {
    const int points = 18;
    final Path path = Path();

    for (int index = 0; index <= points; index++) {
      final double t = index / points;
      final double angle = startAngle + sweep * t;
      final double wobble =
          1.0 +
          sin(angle * 2.1 + seed) * 0.08 +
          sin(angle * 4.7 + seed * 0.37) * 0.04;
      final Offset point = Offset(
        center.dx + cos(angle) * radiusX * wobble,
        center.dy + sin(angle) * radiusY * wobble,
      );

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  double _organicWaveY(double baseY, double phase, double amplitude) {
    return baseY +
        sin(phase) * amplitude +
        sin(phase * 2.37 + 0.8) * amplitude * 0.42;
  }

  double _hash(int seed, int salt) {
    final double value = sin(seed * 12.9898 + salt * 78.233) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant DsOrganicTexturePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.highlightColor != highlightColor;
  }
}
