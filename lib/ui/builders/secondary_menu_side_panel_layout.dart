part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Default tablet/desktop layout for [PageWithSecondaryMenuWidget].
///
/// - [content] como área principal.
/// - [items] en un panel lateral (si no está vacío).
class SecondaryMenuSidePanelLayout extends StatelessWidget {
  const SecondaryMenuSidePanelLayout({
    required this.responsive,
    required this.content,
    required this.backgroundColor,
    required this.items,
    this.panelColumns = 2,
    this.secondaryOnRight = true,
    this.animate = true,
    super.key,
  });

  final BlocResponsive responsive;
  final Widget content;
  final List<ModelMainMenuModel> items;
  final Color backgroundColor;

  final int panelColumns;
  final bool secondaryOnRight;
  final bool animate;

  static Widget defaultBuilder(
    BuildContext context,
    BlocResponsive responsive,
    Widget content,
    List<ModelMainMenuModel> items,
    Color backgroundColor,
    int panelColumns,
    bool secondaryOnRight,
    bool animate,
  ) {
    return SecondaryMenuSidePanelLayout(
      responsive: responsive,
      content: content,
      items: items,
      backgroundColor: backgroundColor,
      panelColumns: panelColumns,
      secondaryOnRight: secondaryOnRight,
      animate: animate,
    );
  }

  bool get _hasPanel => items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth;

    final int maxPanelColumns =
        (responsive.columnsNumber - 1).clamp(1, responsive.columnsNumber);
    final int effectivePanelColumns = panelColumns.clamp(1, maxPanelColumns);

    final double panelW =
        _hasPanel ? responsive.widthByColumns(effectivePanelColumns) : 0.0;

    final double screenW = responsive.size.width;
    final double contentGap = _hasPanel ? gap : 0.0;

    final double designW = responsive.workAreaSize.width;

    final double contentMaxWidth =
        (screenW - panelW - contentGap).clamp(360.0, designW);

    final List<Widget> rowChildren = <Widget>[
      Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: content,
        ),
      ),
      if (_hasPanel) ...<Widget>[
        SizedBox(width: gap),
        SizedBox(
          width: panelW,
          child: _maybeAnimated(
            key: const ValueKey<String>('panel-secondary'),
            child: _buildActionsPanel(context, gap),
          ),
        ),
      ],
    ];

    final List<Widget> ordered =
        secondaryOnRight ? rowChildren : rowChildren.reversed.toList();

    return Container(
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mh),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ordered,
        ),
      ),
    );
  }

  Widget _buildActionsPanel(BuildContext context, double gap) {
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(gap * 0.75),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final ModelMainMenuModel it in items)
              Padding(
                padding: EdgeInsets.symmetric(vertical: gap * 0.25),
                child: DrawerOptionWidget(
                  responsive: responsive,
                  label: it.label,
                  icon: it.iconData,
                  selected: it.selected,
                  onTap: it.onPressed,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _maybeAnimated({required Widget child, Key? key}) {
    if (!animate) {
      return child;
    }
    return AnimatedSwitcher(
      key: key,
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
