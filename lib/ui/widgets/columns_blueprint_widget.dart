part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Lays out children in a single row using responsive column spans.
/// Widths, margins and gutters are derived from [BlocResponsive].
///
/// This widget is useful to quickly prototype grid-aligned sections
/// (e.g., header bars, toolbars, 2–4 column content rows) without
/// hardcoding sizes. If you need a visual overlay of the grid, you
/// can stack this with [ColumnBlueprintWidget].
///
/// ### How it works
/// - The total grid is `responsive.columnsNumber`.
/// - Each child requests a `span` in columns (>=1).
/// - The widget clamps and normalizes spans to fit the row.
/// - Between children it uses the responsive `gutterWidth`.
/// - Horizontal padding equals `responsive.marginWidth`.
///
/// ### Parameters
/// - [responsive]: Metrics provider.
/// - [children]: List of [ColumnSlot] with `span` and `child`.
/// - [mainAxisAlignment]: Horizontal distribution of the row
///   (applies when there is extra free space).
/// - [crossAxisAlignment]: Vertical alignment of children.
/// - [gapOverride]: Optional custom gap instead of `gutterWidth`.
/// - [backgroundColor]: Optional background for the row area.
/// - [showGuides]: If `true`, draws a subtle guides overlay for columns.
/// - [safeArea]: Wraps the area with `SafeArea`.
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(1280, 800));
///
/// ColumnsBlueprintWidget(
///   responsive: resp,
///   children: [
///     ColumnSlot(span: 2, child: ElevatedButton(onPressed: () {}, child: const Text('A'))),
///     ColumnSlot(span: 6, child: const Text('Main content aligned to 6 cols')),
///     ColumnSlot(span: 2, child: OutlinedButton(onPressed: () {}, child: const Text('B'))),
///   ],
///   mainAxisAlignment: MainAxisAlignment.start,
///   crossAxisAlignment: CrossAxisAlignment.center,
///   showGuides: false, // set true while designing
/// );
/// ```
///
/// ### Notes
/// - If total requested spans exceed available columns, extra spans are
///   trimmed from the last items (non-destructive to children).
/// - For multi-row flows, compose several [ColumnsBlueprintWidget] or
///   create a vertical `Column` of rows.
class ColumnsBlueprintWidget extends StatelessWidget {
  const ColumnsBlueprintWidget({
    required this.responsive,
    required this.children,
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.gapOverride,
    this.backgroundColor,
    this.showGuides = false,
    this.safeArea = true,
  }) : assert(children.length > 0, 'children must not be empty');

  final BlocResponsive responsive;
  final List<ColumnSlot> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? gapOverride;
  final Color? backgroundColor;
  final bool showGuides;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    // Keep metrics in sync
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final double mh = responsive.marginWidth;
    final double workW = responsive.workAreaSize.width;
    final int totalCols = responsive.columnsNumber;
    final double gap = (gapOverride ?? responsive.gutterWidth).clamp(0.0, 64.0);

    // Normalize spans to fit available columns (trim overflow at the end).
    final List<_SlotLayout> slots =
        _computeSlots(children, totalCols, responsive, gap);

    final Widget row = SizedBox(
      width: workW,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildRowChildren(slots, gap),
      ),
    );

    final Widget padded = Container(
      color: backgroundColor,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mh),
        child: Stack(
          children: <Widget>[
            if (showGuides)
              // very light guides using the domain metrics
              _GuidesOverlay(responsive: responsive),
            row,
          ],
        ),
      ),
    );

    return safeArea ? SafeArea(child: padded) : padded;
  }

  List<_SlotLayout> _computeSlots(
    List<ColumnSlot> children,
    int totalCols,
    BlocResponsive r,
    double gap,
  ) {
    final List<_SlotLayout> result = <_SlotLayout>[];
    int used = 0;

    for (final ColumnSlot slot in children) {
      final int want = slot.span.clamp(1, totalCols);
      final int remain = totalCols - used;
      if (remain <= 0) {
        // no more columns available—add zero width spacer to keep indices aligned
        result.add(_SlotLayout(slot: slot, px: 0.0));
        continue;
      }
      final int grant = want.clamp(1, remain);
      final double width = r.widthByColumns(grant);
      used += grant;
      result.add(_SlotLayout(slot: slot, px: width));
    }
    return result;
  }

  List<Widget> _buildRowChildren(List<_SlotLayout> slots, double gap) {
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < slots.length; i++) {
      final _SlotLayout sl = slots[i];
      widgets.add(
        SizedBox(
          width: sl.px,
          child: sl.slot.child,
        ),
      );
      if (i != slots.length - 1) {
        widgets.add(SizedBox(width: gap));
      }
    }
    return widgets;
  }
}

/// Child descriptor for [ColumnsBlueprintWidget].
///
/// The [span] requests how many responsive columns the [child] should occupy.
class ColumnSlot {
  const ColumnSlot({
    required this.span,
    required this.child,
  }) : assert(span >= 1, 'span must be >= 1');

  /// Requested number of responsive columns (>= 1).
  final int span;

  /// The content to place within the allocated width.
  final Widget child;
}

class _SlotLayout {
  const _SlotLayout({required this.slot, required this.px});
  final ColumnSlot slot;
  final double px; // computed pixel width
}

/// Very subtle column guides (non-interactive) to help during design.
/// Use `showGuides: true` to enable; otherwise not painted.
class _GuidesOverlay extends StatelessWidget {
  const _GuidesOverlay({required this.responsive});

  final BlocResponsive responsive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int cols = responsive.columnsNumber;
    final double cw = responsive.columnWidth;
    final double gw = responsive.gutterWidth;
    final Color c = theme.colorScheme.outlineVariant.withValues(alpha: 0.88);

    return IgnorePointer(
      child: Row(
        children: List<Widget>.generate(cols * 2 - 1, (int i) {
          final bool isCol = i.isEven;
          final double w = isCol ? cw : gw;
          return SizedBox(
            width: w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isCol ? c : Colors.transparent,
              ),
            ),
          );
        }),
      ),
    );
  }
}
