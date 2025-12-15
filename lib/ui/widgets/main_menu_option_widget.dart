part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A primary navigation option for the main menu (panel/rail/top bar).
///
/// - **Responsive**: paddings and sizes derive from [BlocResponsive].
/// - **Accessible**: proper semantics, tooltip, focus/hover states.
/// - **Customizable**: horizontal/vertical layout, badge, custom leading/trailing.
/// - **Material 3**: selected state uses `primaryContainer`.
///
/// ### Visual behavior
/// - `selected`: filled container using primaryContainer; prominent indicator.
/// - `hover/focus`: subtle tint.
/// - `disabled`: reduced opacity and no tap.
///
/// ### Parameters
/// - [responsive]: Metrics provider from `jocaagura_domain`.
/// - [label]: Main text.
/// - [onTap]: Tap callback; null disables the option.
/// - [selected]: Whether this option is active.
/// - [icon]: Convenience leading icon (ignored if [leading] provided).
/// - [leading], [trailing]: Custom slots.
/// - [badgeCount]: Optional counter (e.g., notifications).
/// - [axis]: Layout direction (vertical puts the icon above the label).
/// - [enabled]: Forces disabled state even if [onTap] is non-null.
/// - [tooltip], [semanticsLabel]: A11y aids.
/// - [maxWidthColumns]: Optional max width (in columns) clamp for large screens.
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(1280, 800));
///
/// MainMenuOptionWidget(
///   responsive: resp,
///   icon: Icons.dashboard,
///   label: 'Dashboard',
///   selected: true,
///   onTap: () {},
///   axis: Axis.vertical, // icon above label (great for side rails)
///   badgeCount: 7,
///   tooltip: 'Open dashboard',
/// );
/// ```
class MainMenuOptionWidget extends StatefulWidget {
  const MainMenuOptionWidget({
    required this.responsive,
    required this.label,
    required this.onTap,
    super.key,
    this.selected = false,
    this.icon,
    this.leading,
    this.trailing,
    this.badgeCount,
    this.axis = Axis.vertical,
    this.enabled = true,
    this.tooltip,
    this.semanticsLabel,
    this.maxWidthColumns,
  });

  final BlocResponsive responsive;
  final String label;
  final VoidCallback? onTap;

  final bool selected;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final int? badgeCount;

  /// Layout orientation. `vertical` = icon over label (good for rails);
  /// `horizontal` = icon leading, label trailing (good for bars).
  final Axis axis;

  final bool enabled;
  final String? tooltip;
  final String? semanticsLabel;

  /// If provided, clamps the max width using `responsive.widthByColumns(n)`.
  final int? maxWidthColumns;

  @override
  State<MainMenuOptionWidget> createState() => _MainMenuOptionWidgetState();
}

class _MainMenuOptionWidgetState extends State<MainMenuOptionWidget> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool isEnabled = widget.enabled && widget.onTap != null;

    // Responsive tokens
    final double gap = widget.responsive.gutterWidth.clamp(8.0, 16.0);
    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: gap,
      vertical:
          (gap * (widget.axis == Axis.vertical ? 0.9 : 0.6)).clamp(6.0, 16.0),
    );

    // Size heuristics based on a column width (keeps coherence across app)
    final double minHeight = (widget.responsive.columnWidth *
            (widget.axis == Axis.vertical ? 1.0 : 0.8))
        .clamp(44.0, 72.0);

    final double? maxW = (widget.maxWidthColumns != null)
        ? widget.responsive.widthByColumns(
            widget.maxWidthColumns!.clamp(1, widget.responsive.columnsNumber),
          )
        : null;

    // Colors
    final Color fgSelected = scheme.onPrimaryContainer;
    final Color fgBase =
        scheme.onSurface.withValues(alpha: isEnabled ? 0.05 : 0.62);
    final Color fg = widget.selected ? fgSelected : fgBase;

    final Color bgBase = scheme.surfaceContainerLow;
    final Color bgSelected = scheme.primaryContainer;
    final Color bgHover =
        scheme.primary.withValues(alpha: widget.selected ? 0.90 : 0.94);
    final Color bg = widget.selected
        ? (_hovered || _focused ? _mix(bgSelected, bgHover, 0.35) : bgSelected)
        : (_hovered || _focused ? _mix(bgBase, bgHover, 0.35) : bgBase);

    // Indicator (prominent in primary menu)
    final bool showIndicator = widget.selected || _focused;
    final Color indicatorColor =
        widget.selected ? scheme.primary : scheme.outlineVariant;
    final double indicatorExtent = showIndicator ? 3.0 : 0.0;

    // Leading logic
    final Widget? leading = widget.leading ??
        (widget.icon != null
            ? Icon(widget.icon, color: fg, size: minHeight * 0.5)
            : null);

    // Trailing / Badge
    final Widget? trailing =
        (widget.badgeCount != null && widget.badgeCount! > 0)
            ? _Badge(count: widget.badgeCount!, colorScheme: scheme)
            : widget.trailing;

    // Content composition
    final Widget label = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.titleSmall?.copyWith(
        color: fg,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      textAlign:
          widget.axis == Axis.vertical ? TextAlign.center : TextAlign.start,
    );

    final List<Widget> axisChildren = (widget.axis == Axis.vertical)
        ? <Widget>[
            if (leading != null) leading,
            if (leading != null) SizedBox(height: gap * 0.5),
            Flexible(child: label),
            if (trailing != null) ...<Widget>[
              SizedBox(height: gap * 0.5),
              trailing,
            ],
          ]
        : <Widget>[
            if (leading != null) leading,
            if (leading != null) SizedBox(width: gap),
            Flexible(child: label),
            if (trailing != null) ...<Widget>[
              SizedBox(width: gap),
              trailing,
            ],
          ];

    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxWidth: maxW ?? double.infinity,
      ),
      child: Padding(
        padding: contentPadding,
        child: (widget.axis == Axis.vertical)
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: axisChildren,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: axisChildren,
              ),
      ),
    );

// left indicator rail for horizontal bar

    final BorderRadius radius = BorderRadius.circular(12);

    final Widget body = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: (widget.axis == Axis.vertical)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // top indicator (full width)
                if (indicatorExtent > 0)
                  Container(
                    height: indicatorExtent,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                content,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (indicatorExtent > 0)
                  Container(
                    width: indicatorExtent,
                    height: minHeight,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                  ),
                // was: Expanded(child: content),
                Flexible(child: content),
              ],
            ),
    );

    final Widget interactive = Focus(
      onFocusChange: (bool v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          borderRadius: radius,
          splashFactory: InkRipple.splashFactory,
          onTap: isEnabled ? widget.onTap : null,
          child: body,
        ),
      ),
    );

    final Widget withTooltip = (widget.tooltip == null)
        ? interactive
        : Tooltip(message: widget.tooltip, child: interactive);

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: isEnabled,
      label: widget.semanticsLabel ?? widget.label,
      child: withTooltip,
    );
  }

  Color _mix(Color a, Color b, double t) {
    final double tt = t.clamp(0.0, 1.0);
    return Color.lerp(a, b, tt)!;
  }
}
