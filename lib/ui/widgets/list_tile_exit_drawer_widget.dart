part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A Material 3, responsive **"exit / sign out"** drawer tile.
///
/// Visual cues:
/// - Uses the error/danger palette by default (configurable).
/// - Hover/focus tint and ripple.
/// - Optional confirmation dialog before executing [onExit].
///
/// Accessibility:
/// - Exposes proper semantics for screen readers.
/// - Single-line, ellipsized label.
///
/// Responsiveness:
/// - Paddings and minimum height derive from [BlocResponsive] (no magic numbers).
///
/// ### Parameters
/// - [responsive]: Source of responsive metrics (required).
/// - [label]: Visible label (default: `"Sign out"`).
/// - [icon]: Leading icon (default: [Icons.logout]).
/// - [onExit]: Callback executed on confirmation (or directly if [confirmBeforeExit] is `false`).
/// - [confirmBeforeExit]: If `true`, shows a confirm dialog (default: `true`).
/// - [confirmTitle], [confirmMessage], [confirmActionLabel], [cancelActionLabel]:
///   i18n-friendly dialog texts.
/// - [tooltip]: Optional tooltip (hover/long-press).
/// - [semanticsLabel]: Optional screen-reader label override.
/// - [dangerColors]: If `true`, styles the row using error-container colors (default).
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(390, 844));
///
/// Drawer(
///   child: SafeArea(
///     child: ListView(
///       children: <Widget>[
///         ListTileExitDrawerWidget(
///           responsive: resp,
///           onExit: () { /* sign out */ },
///           confirmBeforeExit: true,
///           confirmTitle: 'Sign out',
///           confirmMessage: 'Are you sure you want to sign out?',
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
class ListTileExitDrawerWidget extends StatefulWidget {
  const ListTileExitDrawerWidget({
    required this.responsive,
    required this.onExit,
    super.key,
    this.label = 'Sign out',
    this.icon = Icons.logout,
    this.confirmBeforeExit = true,
    this.confirmTitle = 'Confirm',
    this.confirmMessage = 'Are you sure?',
    this.confirmActionLabel = 'Yes',
    this.cancelActionLabel = 'Cancel',
    this.tooltip,
    this.semanticsLabel,
    this.dangerColors = true,
    this.enabled = true,
  });

  final BlocResponsive responsive;
  final VoidCallback onExit;

  final String label;
  final IconData icon;

  final bool confirmBeforeExit;
  final String confirmTitle;
  final String confirmMessage;
  final String confirmActionLabel;
  final String cancelActionLabel;

  final String? tooltip;
  final String? semanticsLabel;
  final bool enabled;

  /// If true, uses error/danger palette; if false, uses neutral surface style.
  final bool dangerColors;

  @override
  State<ListTileExitDrawerWidget> createState() =>
      _ListTileExitDrawerWidgetState();
}

class _ListTileExitDrawerWidgetState extends State<ListTileExitDrawerWidget> {
  bool _hovered = false;
  bool _focused = false;

  @override
  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      widget.responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double gap = widget.responsive.gutterWidth.clamp(8.0, 16.0);
    final EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: gap,
      vertical: (gap * 0.6).clamp(6.0, 12.0),
    );
    final double minHeight =
        (widget.responsive.columnWidth * 0.8).clamp(44.0, 56.0);

    // 🎯 Usa `enabled` (no onExit != null)
    final Color fgNeutral =
        scheme.onSurface.withValues(alpha: widget.enabled ? 0.1 : 0.62);
    final Color bgNeutral = scheme.surfaceContainerLow;

    final Color fgDanger = scheme.onErrorContainer;
    final Color bgDanger = scheme.errorContainer;

    final Color fg = widget.dangerColors ? fgDanger : fgNeutral;
    final Color baseBg = widget.dangerColors ? bgDanger : bgNeutral;
    final Color hoverBg = (widget.dangerColors ? scheme.error : scheme.primary)
        .withValues(alpha: widget.dangerColors ? 0.88 : 0.94);
    final Color bg =
        (_hovered || _focused) ? _mix(baseBg, hoverBg, 0.35) : baseBg;

    final Widget tile = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Row(
        children: <Widget>[
          Icon(widget.icon, color: fg, size: minHeight * 0.5),
          SizedBox(width: gap),
          Expanded(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );

    final Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: contentPadding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: tile,
    );

    final Widget interactive = Focus(
      onFocusChange: (bool v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashFactory: InkRipple.splashFactory,
          onTap: widget.enabled ? _handleTap : null, // 👈 usa enabled
          child: container,
        ),
      ),
    );

    final Widget withTooltip = (widget.tooltip == null)
        ? interactive
        : Tooltip(message: widget.tooltip, child: interactive);

    return Semantics(
      button: true,
      enabled: widget.enabled, // 👈 usa enabled
      label: widget.semanticsLabel ?? widget.label,
      child: withTooltip,
    );
  }

  Future<void> _handleTap() async {
    if (!widget.confirmBeforeExit) {
      widget.onExit();
      return;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        final ColorScheme scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(widget.confirmTitle),
          content: Text(widget.confirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(widget.cancelActionLabel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(widget.confirmActionLabel),
            ),
          ],
        );
      },
    );
    if (ok ?? false) {
      widget.onExit();
    }
  }

  Color _mix(Color a, Color b, double t) {
    return Color.fromARGB(
      (a.a + ((b.a - a.a) * t)).round(),
      (a.r + ((b.r - a.r) * t)).round(),
      (a.g + ((b.g - a.g) * t)).round(),
      (a.b + ((b.b - a.b) * t)).round(),
    );
  }
}
