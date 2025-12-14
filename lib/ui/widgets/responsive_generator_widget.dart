part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Generates a **wrap/flow** of items where each tile width equals a number
/// of responsive columns from [BlocResponsive].
///
/// Great for building quick “cards grids” aligned to your design system, without
/// hardcoding pixel widths. It wraps to the next line when running out of space.
///
/// ### Parameters
/// - [responsive]: metrics provider.
/// - [itemCount]: items to render.
/// - [spanForIndex]: returns the **column span** (>=1) for a given index.
/// - [itemBuilder]: builds the tile for the given index.
/// - [gapOverride]: custom gap between tiles; defaults to [BlocResponsive.gutterWidth].
/// - [padding]: outer padding; defaults to horizontal marginWidth and vertical gutter.
///
/// ### Example
/// ```dart
/// ResponsiveGeneratorWidget(
///   responsive: resp,
///   itemCount: 10,
///   spanForIndex: (i, r) => (i % 3) + 1, // 1..3 columns
///   itemBuilder: (ctx, i, r) => Container(height: 120, color: Colors.grey.shade200),
/// );
/// ```
class ResponsiveGeneratorWidget extends StatelessWidget {
  const ResponsiveGeneratorWidget({
    required this.responsive,
    required this.itemCount,
    required this.itemBuilder,
    required this.spanForIndex,
    super.key,
    this.gapOverride,
    this.padding,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
  });

  final BlocResponsive responsive;
  final int itemCount;

  /// Builder that receives (context, index, responsive).
  final Widget Function(BuildContext, int, BlocResponsive) itemBuilder;

  /// Returns how many **columns** a tile at [index] should occupy.
  final int Function(int index, BlocResponsive responsive) spanForIndex;

  final double? gapOverride;
  final EdgeInsets? padding;

  /// Align items in the main/run axes.
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;

  @override
  Widget build(BuildContext context) {
    final double mh = responsive.marginWidth;
    final double gap = (gapOverride ?? responsive.gutterWidth).clamp(0.0, 64.0);

    final List<Widget> children = <Widget>[
      for (int i = 0; i < itemCount; i++)
        SizedBox(
          width: responsive.widthByColumns(
            spanForIndex(i, responsive).clamp(1, responsive.columnsNumber),
          ),
          child: itemBuilder(context, i, responsive),
        ),
    ];

    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(mh, gap, mh, gap),
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        alignment: alignment,
        runAlignment: runAlignment,
        children: children,
      ),
    );
  }
}
