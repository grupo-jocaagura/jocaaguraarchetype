part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A compact secondary action for mobile layouts (icon + label).
///
/// - Responsive spacing and sizes are derived from [BlocResponsive].
/// - Uses Material 3 buttons through [TextButton] with theme-level styling.
/// - Accessible by default: exposes [semanticsLabel] and uses [tooltip].
///
/// ## Parameters
/// - [icon]: Leading icon.
/// - [label]: Short text label (ellipsized).
/// - [onPressed]: Tap callback; if null, the option is disabled.
/// - [responsive]: Instance of [BlocResponsive] to compute metrics.
/// - [semanticsLabel]: Optional explicit label for screen readers.
/// - [tooltip]: Optional tooltip on long-press/hover.
/// - [selected]: Optional selected state for highlighting.
///
/// ## Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()..setSizeForTesting(const Size(400, 800));
/// return MobileSecondaryOptionWidget(
///   icon: Icons.settings,
///   label: 'Settings',
///   responsive: resp,
///   onPressed: () {},
///   selected: false,
///   tooltip: 'Open settings',
/// );
/// ```
class MobileSecondaryOptionWidget extends StatelessWidget {
  const MobileSecondaryOptionWidget({
    required this.icon,
    required this.label,
    required this.responsive,
    required this.onPressed,
    this.semanticsLabel,
    this.tooltip,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final BlocResponsive responsive;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final String? tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final double base = responsive.columnWidth.clamp(48.0, 200.0);
    final double height = (base * 0.6).clamp(36.0, 48.0);
    final double gap = (responsive.gutterWidth * 0.5).clamp(4.0, 12.0);
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: gap,
      vertical: (gap * 0.5).clamp(2.0, 8.0),
    );

    final bool isEnabled = onPressed != null;
    final Color fg = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface.withValues(alpha: isEnabled ? 0.1 : 0.6);
    final Color bg = selected
        ? scheme.secondaryContainer
        : scheme.surfaceContainerLow; // M3-friendly

    final Widget child = ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: height * 0.6, color: fg),
            SizedBox(width: gap),
            Flexible(
              child: Text(
                label,
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

    final Widget button = TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => bg,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => scheme.primary.withValues(alpha: 0.94),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      child: child,
    );

    final Widget withTooltip = tooltip == null
        ? button
        : Tooltip(
            message: tooltip,
            child: button,
          );

    return Semantics(
      button: true,
      selected: selected,
      enabled: isEnabled,
      label: semanticsLabel ?? label,
      child: withTooltip,
    );
  }
}
