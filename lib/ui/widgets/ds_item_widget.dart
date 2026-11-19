part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A passive grid item with visual content above a label that wraps at the active text scale.
///
/// Keep the [child] compact and free of nested controls. [size] defaults to a
/// square using `spacingXXl`. The preferred width stays fixed and the height
/// grows to fit the label when parent constraints allow.
class DsItemWidget extends StatelessWidget {
  const DsItemWidget({
    required this.child,
    required this.label,
    this.size,
    this.variant = DsSurfaceVariant.filled,
    super.key,
  }) : _appearance = null;

  const DsItemWidget._styled({
    required this.child,
    required this.label,
    required this.size,
    required this.variant,
    required this._appearance,
  });

  final Widget child;
  final String label;
  final Size? size;
  final DsSurfaceVariant variant;
  final _DsSurfaceAppearance? _appearance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final Size dimensions = size ?? Size.square(tokens.spacingXXl);
    if (!dimensions.isFinite || dimensions.isEmpty) {
      throw ArgumentError.value(
        size,
        'size',
        'Use finite, positive dimensions.',
      );
    }
    final _DsSurfaceAppearance appearance =
        _appearance ?? _DsSurfaceAppearance.resolve(theme, variant);
    final DefaultTextStyle defaults = DefaultTextStyle.of(context);
    final TextStyle? themeLabel = theme.textTheme.labelMedium;
    TextStyle labelStyle = themeLabel?.inherit == false
        ? themeLabel!
        : defaults.style.merge(themeLabel);
    if (MediaQuery.boldTextOf(context)) {
      labelStyle = labelStyle.merge(
        const TextStyle(fontWeight: FontWeight.bold),
      );
    }
    labelStyle = labelStyle.copyWith(
      color: appearance.foreground,
      inherit: false,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.constrainWidth(dimensions.width);
        final double preferredHeight = constraints.constrainHeight(
          dimensions.height,
        );
        final double shortestSide = min(width, preferredHeight);
        final double inset = min(tokens.spacingSm, shortestSide / 8);
        final double gap = min(tokens.spacingXs, shortestSide / 16);
        final double labelWidth = max(0, width - 2 * inset);
        final TextScaler scaler = MediaQuery.textScalerOf(context);
        final TextDirection direction = Directionality.of(context);
        final Locale? locale = Localizations.maybeLocaleOf(context);
        final TextHeightBehavior? heightBehavior =
            defaults.textHeightBehavior ??
            DefaultTextHeightBehavior.maybeOf(context);
        final TextPainter painter = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textAlign: TextAlign.center,
          textDirection: direction,
          locale: locale,
          textScaler: scaler,
          textWidthBasis: defaults.textWidthBasis,
          textHeightBehavior: heightBehavior,
        );
        late final double labelHeight;
        late final List<double> lineBottoms;
        try {
          painter.layout(maxWidth: labelWidth);
          labelHeight = painter.height;
          lineBottoms = painter
              .computeLineMetrics()
              .map((LineMetrics line) => line.baseline + line.descent)
              .toList();
        } finally {
          painter.dispose();
        }

        // Retain the compact visual slot where possible, then give its space
        // back to the label before truncating under a tight height constraint.
        final double preferredVisual =
            max(0, preferredHeight - 2 * inset - gap) * 0.6;
        final double minimumVisual = min(preferredVisual, tokens.spacingLg);
        final double height = constraints.constrainHeight(
          max(
            preferredHeight,
            (2 * inset + minimumVisual + gap + labelHeight).ceilToDouble(),
          ),
        );
        final double innerHeight = max(0, height - 2 * inset);
        final double firstLine = lineBottoms.isEmpty
            ? 0
            : lineBottoms.first.ceilToDouble();
        final double reservedVisual = min(
          minimumVisual,
          max(0, innerHeight - gap - firstLine),
        );
        final double visualHeight = (innerHeight - gap - labelHeight).clamp(
          reservedVisual,
          preferredVisual,
        );
        final double actualGap = visualHeight > 0 ? gap : 0;
        final double labelSpace = innerHeight - visualHeight - actualGap;
        final int visibleLines = labelHeight <= labelSpace
            ? lineBottoms.length
            : lineBottoms
                  .where((double bottom) => bottom.ceilToDouble() <= labelSpace)
                  .length;
        final Widget labelText = Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(labelMedium: labelStyle),
          ),
          child: DefaultTextStyle.merge(
            softWrap: true,
            textWidthBasis: defaults.textWidthBasis,
            textHeightBehavior: heightBehavior,
            child: DsTextParagraphWidget(
              label: label,
              role: DsTextStyleKey.labelMedium,
              textAlign: TextAlign.center,
              maxLines: max(1, visibleLines),
              overflow: TextOverflow.ellipsis,
              semanticLabel: label,
            ),
          ),
        );
        return SizedBox(
          width: width,
          height: height,
          child: Material(
            color: appearance.background,
            shape: _itemShape(tokens, appearance),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (visualHeight > 0)
                    SizedBox(
                      height: visualHeight,
                      child: Center(
                        child: IconTheme.merge(
                          data: IconThemeData(color: appearance.foreground),
                          child: DefaultTextStyle.merge(
                            style: TextStyle(color: appearance.foreground),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: actualGap),
                  Expanded(
                    child: Center(
                      child: visibleLines == 0
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: labelWidth,
                                child: labelText,
                              ),
                            )
                          : labelText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

ModelDsExtendedTokens _itemTokensOf(BuildContext context) =>
    Theme.of(context).extension<DsExtendedTokensExtension>()?.tokens ??
    const ModelDsExtendedTokens();

RoundedRectangleBorder _itemShape(
  ModelDsExtendedTokens tokens,
  _DsSurfaceAppearance appearance,
) => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(tokens.borderRadius),
  side: appearance.border == null
      ? BorderSide.none
      : BorderSide(
          color: appearance.border!,
          width: appearance.emphasized
              ? tokens.borderRadiusXs
              : tokens.borderRadiusXs / 2,
        ),
);
