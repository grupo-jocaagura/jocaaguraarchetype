part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Main scaffold shell for pages.
///
/// This widget composes:
///
/// - Responsive layout (via [BlocResponsive] streams).
/// - Main menu drawer (via [MainDrawerBuilder]).
/// - App bar (via [PageAppBarBuilder]).
/// - Work area ([WorkAreaWidget]) and global notifications.
///
/// ### Usage
///
/// ```dart
/// Widget myShellBuilder(
///   BuildContext context,
///   AppManager app,
///   BlocResponsive r,
///   Widget? page,
/// ) {
///   return PageScaffoldShell(
///     app: app,
///     responsive: r,
///     page: page,
///   );
/// }
/// ```
class PageScaffoldShell extends StatelessWidget {
  const PageScaffoldShell({
    required this.app,
    required this.responsive,
    required this.page,
    MainDrawerBuilder? drawerBuilder,
    PageAppBarBuilder? appBarBuilder,
    super.key,
  })  : drawerBuilder = drawerBuilder ?? MainDrawer.defaultBuilder,
        appBarBuilder = appBarBuilder ?? PageAppBar.defaultBuilder;

  /// Application manager that provides navigation, menus and notifications.
  final AppManager app;

  /// Responsive configuration for this page.
  final BlocResponsive responsive;

  /// Main page content to render inside the work area.
  final Widget? page;

  /// Builder used to create the main drawer.
  final MainDrawerBuilder drawerBuilder;

  /// Builder used to create the app bar.
  final PageAppBarBuilder appBarBuilder;

  /// Default factory used by [PageLoadingBoundary] and [PageBuilder]
  /// when no custom shell builder is provided.
  static Widget defaultBuilder(
    BuildContext context,
    AppManager app,
    BlocResponsive responsive,
    Widget? page,
  ) {
    return PageScaffoldShell(
      app: app,
      responsive: responsive,
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Size>(
      stream: responsive.appScreenSizeStream,
      initialData: responsive.size,
      builder: (_, __) {
        return StreamBuilder<List<ModelMainMenuModel>>(
          stream: app.mainMenu.listMenuOptionsStream,
          initialData: app.mainMenu.listMenuOptions,
          builder: (
            _,
            __,
          ) {
            final List<ModelMainMenuModel> items = app.mainMenu.listMenuOptions;

            final Widget? drawerWidget = drawerBuilder(
              context,
              app,
              responsive,
              items,
            );

            return StreamBuilder<bool>(
              stream: responsive.showAppbarStream,
              initialData: responsive.showAppbar,
              builder: (
                _,
                __,
              ) {
                final bool showAppbar = responsive.showAppbar;

                final PreferredSizeWidget? appBarWidget = showAppbar
                    ? appBarBuilder(
                        context,
                        app,
                        responsive,
                        drawerWidget != null,
                      )
                    : null;

                return Scaffold(
                  drawer: drawerWidget,
                  appBar: appBarWidget,
                  body: Stack(
                    children: <Widget>[
                      WorkAreaWidget(
                        responsive: responsive,
                        content: page ?? const SizedBox.shrink(),
                      ),
                      MySnackBarWidget.fromStringStream(
                        responsive: responsive,
                        toastStream: app.notifications.textStream,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
