part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A secondary action for larger layouts (tablet/desktop).
///
/// Shares API with [MobileSecondaryOptionWidget] to unify usage.
/// Adds hover/focus visuals suitable for pointer-based UIs.
///
/// ## Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()..setSizeForTesting(const Size(1280, 800));
/// return SecondaryOptionWidget(
///   icon: Icons.dashboard,
///   label: 'Dashboard',
///   responsive: resp,
///   selected: true,
///   onPressed: () {},
/// );
/// ```
class SecondaryOptionWidget extends StatefulWidget {
  const SecondaryOptionWidget({
    required this.icon,
    required this.label,
    required this.responsive,
    required this.onPressed,
    super.key,
    this.semanticsLabel,
    this.tooltip,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final BlocResponsive responsive;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final String? tooltip;
  final bool selected;

  @override
  State<SecondaryOptionWidget> createState() => _SecondaryOptionWidgetState();
}

class _SecondaryOptionWidgetState extends State<SecondaryOptionWidget> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isEnabled = widget.onPressed != null;

    // Wider than mobile: leverage a larger surface and spacing from responsive.
    final double base = widget.responsive.widthByColumns(2).clamp(120.0, 360.0);
    final double height =
        (widget.responsive.columnWidth * 0.7).clamp(40.0, 56.0);
    final double gap = widget.responsive.gutterWidth.clamp(8.0, 16.0);

    final Color fg = widget.selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface.withValues(alpha: isEnabled ? 0.1 : 0.6);

    final Color bgBase = widget.selected
        ? scheme.secondaryContainer
        : scheme.surfaceContainer; // M3-friendly

    final Color bg = !_hovered && !_focused
        ? bgBase
        : scheme.secondaryContainer
            .withValues(alpha: widget.selected ? 0.15 : 0.75);

    final BorderSide border = BorderSide(
      color: widget.selected
          ? scheme.secondary
          : scheme.outlineVariant.withValues(alpha: _focused ? 0.1 : 0.6),
    );

    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: height, maxWidth: base),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gap, vertical: gap * 0.5),
        child: Row(
          children: <Widget>[
            Icon(widget.icon, size: height * 0.6, color: fg),
            SizedBox(width: gap),
            Expanded(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget body = Focus(
      onFocusChange: (bool v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        opaque: false,
        child: TextButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(bg),
            overlayColor:
                WidgetStateProperty.all(scheme.primary.withValues(alpha: 0.94)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                side: border,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          child: content,
        ),
      ),
    );

    final Widget withTooltip = widget.tooltip == null
        ? body
        : Tooltip(message: widget.tooltip, child: body);

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: isEnabled,
      label: widget.semanticsLabel ?? widget.label,
      child: withTooltip,
    );
  }
}
