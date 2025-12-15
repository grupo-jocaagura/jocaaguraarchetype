part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Single façade for navigation, UI wiring, and cross-cutting concerns.
///
/// This widget is the **entry point** for building pages in the archetype:
/// it wires:
///
/// - Loading state (via [AppManager.loading]).
/// - Responsive layout (via [BlocResponsive]).
/// - Main navigation shell: [Scaffold] with drawer, app bar, and work area.
/// - Global notifications (via [MySnackBarWidget]).
///
/// By default it uses [PageLoadingBoundary], [PageScaffoldShell],
/// [MainDrawer] and [PageAppBar], but projects can override any of these via
/// the optional builder callbacks.
///
/// ### Usage
///
/// ```dart
/// // Default usage:
/// class HomePage extends StatelessWidget {
///   const HomePage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return const PageBuilder(
///       page: HomeView(),
///     );
///   }
/// }
///
/// // Customizing only the drawer:
/// class HomePageWithCustomDrawer extends StatelessWidget {
///   const HomePageWithCustomDrawer({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return PageBuilder(
///       page: const HomeView(),
///       drawerBuilder: (BuildContext context, AppManager app,
///           BlocResponsive r, List<ModelMainMenuModel> items) {
///         if (items.isEmpty) {
///           return null;
///         }
///         return OkaneDrawer(
///           app: app,
///           responsive: r,
///           items: items,
///         );
///       },
///     );
///   }
/// }
/// ```
class PageBuilder extends StatelessWidget {
  const PageBuilder({
    super.key,
    this.page,
    this.showAppBar = true,
    this.loadingBoundaryBuilder,
    this.scaffoldShellBuilder,
    this.drawerBuilder,
    this.appBarBuilder,
  });

  /// Main page content to render inside the work area.
  final Widget? page;

  /// Whether the app bar should be visible by default.
  ///
  /// This value is forwarded to [BlocResponsive.showAppbar].
  final bool showAppBar;

  /// Optional override for the loading boundary widget.
  final PageLoadingBoundaryBuilder? loadingBoundaryBuilder;

  /// Optional override for the scaffold shell widget.
  final PageScaffoldShellBuilder? scaffoldShellBuilder;

  /// Optional override for the main drawer widget.
  final MainDrawerBuilder? drawerBuilder;

  /// Optional override for the app bar widget.
  final PageAppBarBuilder? appBarBuilder;

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    final BlocResponsive responsive = app.responsive;

    app.responsive.showAppbar = showAppBar;

    final PageLoadingBoundaryBuilder boundaryBuilder = loadingBoundaryBuilder ??
        (
          BuildContext context,
          AbstractAppManager app,
          BlocResponsive r,
          Widget? page,
        ) =>
            PageLoadingBoundary(
              app: app,
              responsive: r,
              page: page,
              scaffoldShellBuilder: scaffoldShellBuilder,
              drawerBuilder: drawerBuilder,
              appBarBuilder: appBarBuilder,
            );

    return boundaryBuilder(
      context,
      app,
      responsive,
      page,
    );
  }
}
