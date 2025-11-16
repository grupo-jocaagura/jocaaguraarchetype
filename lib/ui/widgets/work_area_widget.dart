part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Composes the main work area with primary menu, optional secondary menu,
/// and the page content. Fully responsive through [BlocResponsive].
///
/// ### Layout policy
/// - **Mobile** (ScreenSizeEnum.mobile):
///   - Primary menu is expected elsewhere (e.g. app bar/drawer).
///   - Secondary menu appears as a **floating bottom bar** (when provided).
///   - Content takes the whole work area width.
/// - **Tablet** (ScreenSizeEnum.tablet):
///   - Primary menu (optional) collapses to a slim side rail (via [primaryMenuWidthColumns]).
///   - Secondary menu appears as a **side panel** (right by default).
/// - **Desktop/TV**:
///   - Primary menu as a **left side panel**.
///   - Secondary menu as a **right side panel**.
///   - Content centered using margins/gutters from [BlocResponsive].
///
/// Widths are computed using:
/// - [BlocResponsive.marginWidth]
/// - [BlocResponsive.widthByColumns]
/// - [BlocResponsive.gutterWidth]
///
/// ## Parameters
/// - [responsive]: The responsive bloc providing metrics & device type.
/// - [content]: Main page content.
/// - [primaryMenu]: Optional left-side menu (rail/panel on larger devices).
/// - [secondaryMenu]: Optional secondary menu (right panel on tablet/desktop;
///   bottom bar on mobile).
/// - [floatingActionButton]: Optional FAB layered over content.
/// - [secondaryMenuOnRight]: If `true` (default), places secondary menu on the right
///   for tablet/desktop.
/// - [primaryMenuWidthColumns], [secondaryMenuWidthColumns]: Column widths (coarse)
///   for side panels on tablet/desktop.
/// - [safeArea]: Wraps the whole work area in a `SafeArea`.
class WorkAreaWidget extends StatelessWidget {
  const WorkAreaWidget({
    required this.responsive,
    required this.content,
    super.key,
    this.primaryMenu,
    this.secondaryMenu,
    this.floatingActionButton,
    this.secondaryMenuOnRight = true,
    this.primaryMenuWidthColumns = 2,
    this.secondaryMenuWidthColumns = 2,
    this.safeArea = true,
    this.backgroundColor,
  });

  final BlocResponsive responsive;
  final Widget content;

  /// Optional left-side menu (rail/panel) for tablet/desktop.
  final Widget? primaryMenu;

  /// Optional secondary menu:
  /// - mobile: bottom floating bar;
  /// - tablet/desktop: side panel (right by default).
  final Widget? secondaryMenu;

  /// Optional floating action button layered over the content.
  final Widget? floatingActionButton;

  /// Side for the secondary panel on tablet/desktop.
  final bool secondaryMenuOnRight;

  /// Coarse width in columns for the primary panel (tablet/desktop).
  final int primaryMenuWidthColumns;

  /// Coarse width in columns for the secondary panel (tablet/desktop).
  final int secondaryMenuWidthColumns;

  /// Wrap entire layout in SafeArea.
  final bool safeArea;

  /// Optional background; defaults to theme surface.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Keep metrics synchronized on rebuild.
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = backgroundColor ?? scheme.surfaceContainerLowest;

    final Widget body = switch (responsive.deviceType) {
      ScreenSizeEnum.mobile => _buildMobile(context, bg),
      ScreenSizeEnum.tablet =>
        _buildTabletDesktop(context, bg, isDesktop: false),
      ScreenSizeEnum.desktop ||
      ScreenSizeEnum.tv =>
        _buildTabletDesktop(context, bg, isDesktop: true),
    };

    return safeArea ? SafeArea(child: body) : body;
  }

  // ----------------------------
  // Mobile: content full width + bottom floating secondary menu (if any)
  // ----------------------------
  Widget _buildMobile(BuildContext context, Color bg) {
    final double mh = responsive.marginWidth;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mh),
            child: content,
          ),
        ),
        if (secondaryMenu != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: mh,
                right: mh,
                bottom: responsive.gutterWidth.clamp(8.0, 16.0),
              ),
              child: secondaryMenu,
            ),
          ),
        if (floatingActionButton != null)
          Positioned(
            right: mh,
            bottom: (responsive.gutterWidth * 3).clamp(48.0, 96.0),
            child: floatingActionButton!,
          ),
      ],
    );
  }

  // ----------------------------
  // Tablet/Desktop: side panels + content centered
  // ----------------------------
  Widget _buildTabletDesktop(
    BuildContext context,
    Color bg, {
    required bool isDesktop,
  }) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth;

    final double primaryW = primaryMenu != null
        ? responsive.widthByColumns(primaryMenuWidthColumns)
        : 0.0;
    final double secondaryW = secondaryMenu != null
        ? responsive.widthByColumns(secondaryMenuWidthColumns)
        : 0.0;

    // Base de layout = grid interno (workArea - 2*margin)
    final double maxW = responsive.workAreaSize.width;
    final double gridW = (maxW - (mh * 2)).clamp(0.0, maxW);

    // Gaps visibles entre panel(es) y contenido
    final int guttersCount = <bool>[primaryMenu != null, secondaryMenu != null]
        .where((bool v) => v)
        .length;
    final double usedGutters = guttersCount > 0 ? gap * guttersCount : 0.0;

    // Resto disponible para el contenido dentro del grid
    final double remaining =
        (gridW - primaryW - secondaryW - usedGutters).clamp(0.0, gridW);

    // Reglas:
    // - Tablet: usar 'remaining' tal cual.
    // - Desktop/TV:
    //    * si hay algún panel => limitar a 320 si cabe; si no cabe, usar 'remaining'
    //    * si NO hay paneles => usar el grid completo.
    final bool anyPanel = primaryMenu != null || secondaryMenu != null;
    final double contentW = switch ((isDesktop, anyPanel)) {
      (true, true) => remaining >= 320.0 ? 320.0 : remaining,
      (true, false) => remaining, // == gridW
      (false, _) => remaining, // tablet
    };

    final List<Widget> rowChildren = <Widget>[
      if (primaryMenu != null) ...<Widget>[
        SizedBox(width: primaryW, child: primaryMenu),
        SizedBox(width: gap),
      ],
      SizedBox(width: contentW, child: content),
      if (secondaryMenu != null) ...<Widget>[
        SizedBox(width: gap),
        SizedBox(width: secondaryW, child: secondaryMenu),
      ],
    ];

    // Invertir sólo si existe secondary; si no, el flag no aplica
    final List<Widget> ordered =
        (secondaryMenu != null && !secondaryMenuOnRight)
            ? rowChildren.reversed.toList()
            : rowChildren;

    // Grid lógico con ancho fijo = gridW
    final Widget grid = SizedBox(
      width: gridW,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ordered,
      ),
    );

    // Sólo activar scroll horizontal si gridW no cabe en el viewport.
    final Widget gridHost = LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints c) {
        final double viewportW = c.maxWidth;
        if (gridW > viewportW) {
          return Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: grid,
            ),
          );
        }
        return Center(child: grid);
      },
    );

    return Stack(
      children: <Widget>[
        Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          child: gridHost,
        ),
        if (floatingActionButton != null)
          Positioned(
            right: mh,
            bottom: mh,
            child: floatingActionButton!,
          ),
      ],
    );
  }
}
