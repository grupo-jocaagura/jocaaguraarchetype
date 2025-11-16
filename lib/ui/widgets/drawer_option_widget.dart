part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A responsive, accessible option row for navigation drawers.
///
/// Uses [BlocResponsive] to derive paddings and sizes, and Material 3 tokens
/// from the current [Theme]. Designed to be used in primary/secondary drawers
/// and navigation rails.
///
/// ### Visual behavior
/// - **Selected**: filled container using `secondaryContainer`.
/// - **Hover/Focus**: subtle container tint.
/// - **Disabled**: lowered opacity and no tap feedback.
/// - Optional **leading**/**trailing** widgets and **badgeCount** support.
///
/// ### Parameters
/// - [responsive]: Metrics provider from `jocaagura_domain`.
/// - [label]: Main text label (single line, ellipsized).
/// - [onTap]: Tap callback; null disables the option.
/// - [selected]: Whether the option is currently active.
/// - [icon]: Convenience leading [IconData] (ignored if [leading] is provided).
/// - [leading], [trailing]: Custom widgets for extremes of the row.
/// - [badgeCount]: If provided and > 0, renders a small count badge (trailing).
/// - [tooltip]: Optional tooltip on long-press/hover.
/// - [semanticsLabel]: Optional explicit label for screen readers.
/// - [enabled]: Forces disabled state (in addition to `onTap == null`).
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(1280, 800));
///
/// Drawer(
///   child: ListView(
///     padding: EdgeInsets.zero,
///     children: <Widget>[
///       DrawerHeader(child: Text('Menu')),
///       DrawerOptionWidget(
///         responsive: resp,
///         icon: Icons.dashboard,
///         label: 'Dashboard',
///         selected: true,
///         onTap: () {},
///       ),
///       DrawerOptionWidget(
///         responsive: resp,
///         icon: Icons.settings,
///         label: 'Settings',
///         badgeCount: 3,
///         onTap: () {},
///         tooltip: 'Open Settings',
///       ),
///       DrawerOptionWidget(
///         responsive: resp,
///         icon: Icons.logout,
///         label: 'Logout',
///         onTap: null, // disabled
///       ),
///     ],
///   ),
/// )
/// ```
class DrawerOptionWidget extends StatefulWidget {
  const DrawerOptionWidget({
    required this.responsive,
    required this.label,
    required this.onTap,
    super.key,
    this.selected = false,
    this.icon,
    this.leading,
    this.trailing,
    this.badgeCount,
    this.tooltip,
    this.semanticsLabel,
    this.enabled = true,
  });

  final BlocResponsive responsive;

  /// Main single-line label.
  final String label;

  /// Tap callback. If null, the option is disabled.
  final VoidCallback? onTap;

  /// Whether this option is the current/active destination.
  final bool selected;

  /// Convenience leading icon. Ignored if [leading] is provided.
  final IconData? icon;

  /// Custom leading widget (e.g., avatar). Takes precedence over [icon].
  final Widget? leading;

  /// Custom trailing widget. Ignored if [badgeCount] is provided and > 0.
  final Widget? trailing;

  /// Optional count badge rendered on trailing side.
  final int? badgeCount;

  /// Tooltip text on hover/long-press.
  final String? tooltip;

  /// Accessibility label override.
  final String? semanticsLabel;

  /// Forces disabled state even if [onTap] is non-null.
  final bool enabled;

  @override
  State<DrawerOptionWidget> createState() => _DrawerOptionWidgetState();
}

class _DrawerOptionWidgetState extends State<DrawerOptionWidget> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    // Sync metrics with context (no MediaQuery direct usage).
    if (context.mounted) {
      widget.responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool isEnabled = widget.enabled && widget.onTap != null;

    // Responsive tokens
    final double gap = widget.responsive.gutterWidth.clamp(8.0, 16.0);
    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: gap,
      vertical: (gap * 0.6).clamp(6.0, 12.0),
    );
    final double minHeight =
        (widget.responsive.columnWidth * 0.8).clamp(44.0, 56.0);

    // Colors
    final Color fgBase = scheme.onSurface.withValues(
      alpha: isEnabled ? 0.87 : 0.38,
    );
    final Color fgSelected = scheme.onSecondaryContainer;
    final Color fg = widget.selected ? fgSelected : fgBase;

    final Color bgBase = scheme.surfaceContainerHigh;
    final Color bgSelected = scheme.secondaryContainer;

    final Color bgHover = widget.selected
        ? bgSelected.withValues(alpha: 0.98)
        : bgBase.withValues(alpha: 0.95);

    final Color bg = widget.selected
        ? bgSelected
        : (_hovered || _focused ? bgHover : bgBase);

    // Left indicator for selected/focus
    final bool showIndicator = widget.selected || _focused;
    final Color indicatorColor =
        widget.selected ? scheme.secondary : scheme.outlineVariant;
    final double indicatorWidth = showIndicator ? 3.0 : 0.0;

    // Leading
    final Widget? leading = widget.leading ??
        (widget.icon != null
            ? Icon(widget.icon, color: fg, size: minHeight * 0.5)
            : null);

    // Trailing / Badge
    final Widget? trailing =
        (widget.badgeCount != null && widget.badgeCount! > 0)
            ? _Badge(count: widget.badgeCount!, colorScheme: scheme)
            : widget.trailing;

    final Widget tile = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Row(
        children: <Widget>[
          // Left indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: indicatorWidth,
            height: minHeight,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: gap * 0.75),
              child: Row(
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    leading,
                    SizedBox(width: gap),
                  ],
                  Expanded(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(color: fg),
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    SizedBox(width: gap),
                    trailing,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: contentPadding,
      child: tile,
    );

    final VoidCallback? effectiveOnTap = isEnabled ? widget.onTap : null;

    final Widget interactive = Focus(
      onFocusChange: (bool v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: effectiveOnTap,
          borderRadius: BorderRadius.circular(12),
          splashFactory: InkRipple.splashFactory,
          child: container,
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
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.colorScheme});

  final int count;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final String text = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
