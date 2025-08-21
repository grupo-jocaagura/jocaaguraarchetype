part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Composes a page body with an optional secondary menu, adapting to device size
/// via [BlocResponsive]. It does **not** own navigation; it only lays out UI.
///
/// ## Policy
/// - **Mobile**: secondary menu appears as a floating bottom bar (overlay).
/// - **Tablet/Desktop/TV**: secondary menu is rendered as a side panel.
/// - Gaps, margins and panel widths are derived from [BlocResponsive].
///
/// ### Parameters
/// - [responsive]: Required instance of [BlocResponsive].
/// - [content]: Required main page widget.
/// - [secondaryMenu]: Optional widget for the secondary actions.
/// - [panelColumns]: Side panel width in columns for tablet/desktop (default: 2).
/// - [secondaryOnRight]: If true (default), side panel is on the right.
/// - [animate]: Enables slide/opacity animation for the menu (default: true).
/// - [backgroundColor]: Optional background; defaults to theme surface.
/// - [safeArea]: Applies [SafeArea] to the whole composition (default: true).
///
/// ### Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()..setSizeForTesting(const Size(1280, 800));
///
/// return PageWithSecondaryMenuWidget(
///   responsive: resp,
///   content: const MyPage(),
///   secondaryMenu: MySecondaryMenu(), // e.g. a list of quick actions
///   panelColumns: 2,
///   secondaryOnRight: true,
/// );
/// ```
///
/// ### Notes
/// - For a multi-panel shell (primary + secondary + content), prefer
///   [WorkAreaWidget]. This widget focuses on a single page + secondary menu.
class PageWithSecondaryMenuWidget extends StatelessWidget {
  const PageWithSecondaryMenuWidget({
    required this.responsive,
    required this.content,
    super.key,
    this.secondaryMenu,
    this.panelColumns = 2,
    this.secondaryOnRight = true,
    this.animate = true,
    this.backgroundColor,
    this.safeArea = true,
  });

  final BlocResponsive responsive;
  final Widget content;
  final Widget? secondaryMenu;

  /// Side panel width (tablet/desktop), expressed in columns.
  final int panelColumns;

  /// Panel side for tablet/desktop.
  final bool secondaryOnRight;

  /// Enable slide/opacity animation on menu.
  final bool animate;

  final Color? backgroundColor;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    // Sync metrics with current context.
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = backgroundColor ?? scheme.surface;

    final Widget body = switch (responsive.deviceType) {
      ScreenSizeEnum.mobile => _mobile(context, bg),
      ScreenSizeEnum.tablet => _tabletDesktop(context, bg, isDesktop: false),
      ScreenSizeEnum.desktop ||
      ScreenSizeEnum.tv =>
        _tabletDesktop(context, bg, isDesktop: true),
    };

    return safeArea ? SafeArea(child: body) : body;
  }

  // ---------------- Mobile: overlay bottom bar ----------------
  Widget _mobile(BuildContext context, Color bg) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth.clamp(8.0, 16.0);

    final Widget overlay = secondaryMenu == null
        ? const SizedBox.shrink()
        : Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: mh, right: mh, bottom: gap),
              child: _maybeAnimated(
                key: const ValueKey<String>('mobile-secondary'),
                child: Material(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(gap * 0.5),
                    child: secondaryMenu,
                  ),
                ),
              ),
            ),
          );

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
        overlay,
      ],
    );
  }

  // ------------- Tablet/Desktop: side panel -------------------
  Widget _tabletDesktop(
    BuildContext context,
    Color bg, {
    required bool isDesktop,
  }) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth;
    final double panelW = secondaryMenu != null
        ? responsive
            .widthByColumns(panelColumns.clamp(1, responsive.columnsNumber))
        : 0.0;

    final double maxW = responsive.workAreaSize.width;
    final double contentGap = secondaryMenu == null ? 0.0 : gap;
    final double contentW = (maxW - panelW - contentGap).clamp(360.0, maxW);

    final List<Widget> rowChildren = <Widget>[
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentW),
        child: content,
      ),
      if (secondaryMenu != null) ...<Widget>[
        SizedBox(width: gap),
        SizedBox(
          width: panelW,
          child: _maybeAnimated(
            key: const ValueKey<String>('panel-secondary'),
            child: secondaryMenu!,
          ),
        ),
      ],
    ];

    final List<Widget> ordered =
        secondaryOnRight ? rowChildren : rowChildren.reversed.toList();

    return Container(
      color: bg,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mh),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ordered,
          ),
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
