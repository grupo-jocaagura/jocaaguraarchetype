part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// High-level container for the app's **main menu** (rail/panel or top bar).
///
/// This widget arranges a list of menu items responsively using [BlocResponsive].
/// It supports both **vertical** (rail/panel) and **horizontal** (top bar) layouts,
/// optional **collapsed** mode (icon-only), scrolling, and selection handling.
///
/// ### Layout policy
/// - **Axis.vertical** (rail/panel):
///   - Default full mode: icon + label + optional badge.
///   - Collapsed mode: **icon-only** with tooltip (labels hidden).
/// - **Axis.horizontal** (top bar):
///   - Items flow in a row with scroll when overflowed.
///
/// Collapsing can be **forced** via [collapsed] or **auto-detected** with
/// [autoCollapse] based on available width (columns). Auto collapse only
/// applies to `Axis.vertical`.
///
/// ### Parameters
/// - [responsive]: Metrics provider (required).
/// - [items]: List of [MainMenuItem] (required).
/// - [selectedId]: Currently selected item id (optional).
/// - [onSelect]: Callback when an item is tapped (id).
/// - [axis]: `Axis.vertical` (rail/panel) or `Axis.horizontal` (top bar).
/// - [collapsed]: Force collapsed (icon-only) mode for vertical layout.
/// - [autoCollapse]: Auto-collapse rail if `maxWidthColumns <= 1` (default: true).
/// - [maxWidthColumns]: Clamp max width of the menu by columns (vertical only).
/// - [safeArea]: Wraps with `SafeArea`.
/// - [semanticLabel]: Optional overall semantics label for the menu.
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()
///   ..setSizeForTesting(const Size(1280, 800));
///
/// final items = <MainMenuItem>[
///   MainMenuItem(id: 'home', label: 'Home', icon: Icons.home),
///   MainMenuItem(id: 'dash', label: 'Dashboard', icon: Icons.dashboard, badgeCount: 5),
///   MainMenuItem(id: 'settings', label: 'Settings', icon: Icons.settings),
/// ];
///
/// MainMenuWidget(
///   responsive: resp,
///   items: items,
///   selectedId: 'dash',
///   onSelect: (id) => debugPrint('Select → $id'),
///   axis: Axis.vertical,   // use Axis.horizontal for a top bar
///   maxWidthColumns: 3,
///   autoCollapse: true,
/// );
/// ```
class MainMenuWidget extends StatelessWidget {
  const MainMenuWidget({
    required this.responsive,
    required this.items,
    super.key,
    this.selectedId,
    this.onSelect,
    this.axis = Axis.vertical,
    this.collapsed,
    this.autoCollapse = true,
    this.maxWidthColumns,
    this.safeArea = true,
    this.semanticLabel,
    this.backgroundColor,
    this.padding,
  });

  final BlocResponsive responsive;

  /// Menu entries.
  final List<MainMenuItem> items;

  /// Currently selected item id.
  final String? selectedId;

  /// Fired when an item is tapped.
  final ValueChanged<String>? onSelect;

  /// Menu orientation: vertical rail/panel or horizontal top bar.
  final Axis axis;

  /// Force collapsed (icon-only) mode for vertical layout.
  final bool? collapsed;

  /// Auto-collapse vertical rail if `maxWidthColumns <= 1`.
  final bool autoCollapse;

  /// Clamp menu width (vertical), using `responsive.widthByColumns(value)`.
  final int? maxWidthColumns;

  /// Wrap in SafeArea.
  final bool safeArea;

  /// Global semantics label for the menu.
  final String? semanticLabel;

  /// Optional background color for the menu container.
  final Color? backgroundColor;

  /// Optional padding inside the container.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final bool isVertical = axis == Axis.vertical;
    final bool isCollapsed = _resolveCollapsed(isVertical);

    final Widget content = isVertical
        ? _buildVertical(context, isCollapsed)
        : _buildHorizontal(context);

    final Widget container = Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Container(
        color: backgroundColor,
        child: padding == null
            ? content
            : Padding(padding: padding!, child: content),
      ),
    );

    return safeArea ? SafeArea(child: container) : container;
  }

  bool _resolveCollapsed(bool isVertical) {
    if (!isVertical) {
      return false;
    }
    if (collapsed != null) {
      return collapsed!;
    }
    if (!autoCollapse) {
      return false;
    }
    final int cols = responsive.columnsNumber;
    final int maxCols = (maxWidthColumns ?? 2).clamp(1, cols);
    // If max width of the rail is 1 column, collapse to icon-only.
    return maxCols <= 1 || responsive.isMobile;
  }

  // ---------- VERTICAL (RAIL/PANEL) ----------
  Widget _buildVertical(BuildContext context, bool collapsed) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth.clamp(8.0, 16.0);
    final double maxW = (maxWidthColumns != null)
        ? responsive.widthByColumns(
            maxWidthColumns!.clamp(1, responsive.columnsNumber),
          )
        : responsive.workAreaSize.width;

    final Widget list = ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: mh, vertical: gap),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: gap),
      itemBuilder: (BuildContext ctx, int i) {
        final MainMenuItem it = items[i];
        final bool selected = it.id == selectedId;

        if (!collapsed) {
          // full option (icon + label) using our reusable component
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: MainMenuOptionWidget(
              responsive: responsive,
              icon: it.icon,
              label: it.label,
              badgeCount: it.badgeCount,
              selected: selected,
              enabled: it.enabled,
              tooltip: it.tooltip,
              semanticsLabel: it.semanticsLabel ?? it.label,
              onTap: it.enabled ? () => onSelect?.call(it.id) : null,
              maxWidthColumns: maxWidthColumns,
            ),
          );
        }

        // collapsed: render a compact, icon-only tile (keep consistent styling)
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: _CollapsedRailItem(
            responsive: responsive,
            icon: it.icon,
            selected: selected,
            enabled: it.enabled,
            tooltip: it.tooltip ?? it.label,
            semanticsLabel: it.semanticsLabel ?? it.label,
            badgeCount: it.badgeCount,
            onTap: it.enabled ? () => onSelect?.call(it.id) : null,
          ),
        );
      },
    );

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: maxW,
        child: list,
      ),
    );
  }

  // ---------- HORIZONTAL (TOP BAR) ----------
  Widget _buildHorizontal(BuildContext context) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth.clamp(8.0, 16.0);
    final double maxW = responsive.workAreaSize.width;

    final List<Widget> rowChildren = <Widget>[
      for (final MainMenuItem it in items) ...<Widget>[
        MainMenuOptionWidget(
          responsive: responsive,
          icon: it.icon,
          label: it.label,
          badgeCount: it.badgeCount,
          selected: it.id == selectedId,
          enabled: it.enabled,
          tooltip: it.tooltip,
          semanticsLabel: it.semanticsLabel ?? it.label,
          onTap: it.enabled ? () => onSelect?.call(it.id) : null,
          axis: Axis.horizontal,
        ),
        SizedBox(width: gap),
      ],
    ];

    return Align(
      child: SizedBox(
        width: maxW,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mh, vertical: gap * 0.5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(children: rowChildren),
          ),
        ),
      ),
    );
  }
}

/// Data model for [MainMenuWidget] items.
class MainMenuItem {
  const MainMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badgeCount,
    this.enabled = true,
    this.tooltip,
    this.semanticsLabel,
  });

  /// Stable identifier for the menu item.
  final String id;

  /// Visible label (used in full mode and a11y label in collapsed).
  final String label;

  /// Leading icon for the item.
  final IconData icon;

  /// Optional numeric badge (e.g., unread count).
  final int? badgeCount;

  /// Whether the item is enabled and tappable.
  final bool enabled;

  /// Optional tooltip text.
  final String? tooltip;

  /// Optional explicit semantics label; falls back to [label].
  final String? semanticsLabel;
}

/// Compact icon-only item for collapsed vertical rails.
///
/// Uses Material 3 surfaces and responsive sizing for coherence with
/// [MainMenuOptionWidget].
class _CollapsedRailItem extends StatefulWidget {
  const _CollapsedRailItem({
    required this.responsive,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.tooltip,
    required this.semanticsLabel,
    required this.onTap,
    this.badgeCount,
  });

  final BlocResponsive responsive;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final String tooltip;
  final String semanticsLabel;
  final VoidCallback? onTap;
  final int? badgeCount;

  @override
  State<_CollapsedRailItem> createState() => _CollapsedRailItemState();
}

class _CollapsedRailItemState extends State<_CollapsedRailItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final double gap = widget.responsive.gutterWidth.clamp(8.0, 16.0);
    final double side = (widget.responsive.columnWidth * 1.0).clamp(44.0, 72.0);

    final Color fgSelected = scheme.onPrimaryContainer;
    final Color fgBase =
        scheme.onSurface.withValues(alpha: widget.enabled ? 0.05 : 0.62);
    final Color fg = widget.selected ? fgSelected : fgBase;

    final Color bgBase = scheme.surfaceContainerLow;
    final Color bgSelected = scheme.primaryContainer;
    final Color bgHover =
        scheme.primary.withValues(alpha: widget.selected ? 0.9 : 0.94);
    final Color bg = widget.selected
        ? (_hovered || _focused ? _mix(bgSelected, bgHover, 0.35) : bgSelected)
        : (_hovered || _focused ? _mix(bgBase, bgHover, 0.35) : bgBase);

    final BorderRadius radius = BorderRadius.circular(12);

    final Widget iconWithBadge = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(widget.icon, size: side * 0.5, color: fg),
        if ((widget.badgeCount ?? 0) > 0)
          Positioned(
            right: -2,
            top: -2,
            child: _Badge(count: widget.badgeCount!, colorScheme: scheme),
          ),
      ],
    );

    final Widget body = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: side,
      height: side,
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      alignment: Alignment.center,
      child: iconWithBadge,
    );

    final Widget interactive = Focus(
      onFocusChange: (bool v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          borderRadius: radius,
          onTap: widget.enabled ? widget.onTap : null,
          child: Padding(
            padding: EdgeInsets.all(gap * 0.25),
            child: body,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: widget.enabled,
      label: widget.semanticsLabel,
      child: Tooltip(message: widget.tooltip, child: interactive),
    );
  }

// En _CollapsedRailItemState
  Color _mix(Color a, Color b, double t) {
    final double tt = t.clamp(0.0, 1.0);
    return Color.lerp(a, b, tt)!;
  }
}
