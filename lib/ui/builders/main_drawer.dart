part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Default main drawer implementation for the archetype.
///
/// It renders:
///
/// - A header with the current page title (from [PageManager]).
/// - A list of [DrawerOptionWidget] built from [ModelMainMenuModel] items.
///
/// When there are no items, the recommended builder ([defaultBuilder])
/// returns `null` so that no drawer is attached to the [Scaffold].
///
/// ### Usage
///
/// ```dart
/// // Default usage via builder:
/// Widget? drawer = MainDrawer.defaultBuilder(
///   context,
///   app,
///   responsive,
///   app.mainMenu.listMenuOptions,
/// );
///
/// // Direct usage:
/// final Widget widget = MainDrawer(
///   app: app,
///   responsive: responsive,
///   items: app.mainMenu.listMenuOptions,
/// );
/// ```
class MainDrawer extends StatelessWidget {
  const MainDrawer({
    required this.app,
    required this.responsive,
    required this.items,
    super.key,
  });

  /// Application manager used to obtain the current page title.
  final AbstractAppManager app;

  /// Responsive configuration used to compute paddings and gutters.
  final BlocResponsive responsive;

  /// Menu items to render as drawer options.
  final List<ModelMainMenuModel> items;

  /// Default builder used by [PageScaffoldShell] and [PageBuilder].
  static Widget? defaultBuilder(
    BuildContext context,
    AbstractAppManager app,
    BlocResponsive responsive,
    List<ModelMainMenuModel> items,
  ) {
    if (items.isEmpty) {
      return null;
    }
    return MainDrawer(
      app: app,
      responsive: responsive,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gap = responsive.gutterWidth;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            top: responsive.gutterWidth,
            bottom: responsive.gutterWidth,
          ),
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: StreamBuilder<String>(
                  stream: app.pageManager.currentTitleStream,
                  initialData: app.pageManager.currentTitle,
                  builder: (
                    _,
                    __,
                  ) {
                    final String title = app.pageManager.currentTitle;
                    return Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    );
                  },
                ),
              ),
            ),
            for (final ModelMainMenuModel item in items)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: gap,
                  vertical: (responsive.gutterWidth * 0.25).clamp(4.0, 8.0),
                ),
                child: DrawerOptionWidget(
                  responsive: responsive,
                  label: item.label,
                  icon: item.iconData,
                  selected: item.selected,
                  onTap: () {
                    item.onPressed();
                    final ScaffoldState? scaffoldState =
                        Scaffold.maybeOf(context);
                    if (scaffoldState?.isDrawerOpen ?? false) {
                      scaffoldState!.closeDrawer();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
