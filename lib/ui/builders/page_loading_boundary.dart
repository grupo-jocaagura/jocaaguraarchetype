part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Top-level loading boundary for pages.
///
/// This widget listens to [AppManager.loading.loadingMsgStream] and:
///
/// - When there is a non-empty message, it shows [LoadingPage].
/// - Otherwise, it delegates to [PageScaffoldShell] (or a custom shell).
///
/// It is public so that projects can test or reuse it without going through
/// [PageBuilder].
///
/// ### Usage
///
/// ```dart
/// Widget build(BuildContext context) {
///   final AppManager app = context.appManager;
///   final BlocResponsive r = app.responsive;
///
///   return PageLoadingBoundary(
///     app: app,
///     responsive: r,
///     page: const HomeView(),
///   );
/// }
/// ```
class PageLoadingBoundary extends StatelessWidget {
  const PageLoadingBoundary({
    required this.app,
    required this.responsive,
    required this.page,
    PageScaffoldShellBuilder? scaffoldShellBuilder,
    MainDrawerBuilder? drawerBuilder,
    PageAppBarBuilder? appBarBuilder,
    super.key,
  })  : scaffoldShellBuilder =
            scaffoldShellBuilder ?? PageScaffoldShell.defaultBuilder,
        drawerBuilder = drawerBuilder ?? MainDrawer.defaultBuilder,
        appBarBuilder = appBarBuilder ?? PageAppBar.defaultBuilder;

  /// Application manager that provides navigation, loading, menu and routing.
  final AppManager app;

  /// Responsive configuration for this page.
  final BlocResponsive responsive;

  /// Main page content to render inside the work area.
  final Widget? page;

  /// Builder used to create the scaffold shell.
  final PageScaffoldShellBuilder scaffoldShellBuilder;

  /// Builder used to create the main drawer.
  final MainDrawerBuilder drawerBuilder;

  /// Builder used to create the app bar.
  final PageAppBarBuilder appBarBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: app.loading.loadingMsgStream,
      initialData: app.loading.loadingMsg,
      builder: (BuildContext context, AsyncSnapshot<String> loadSnap) {
        final String msg = loadSnap.data ?? '';
        if (msg.isNotEmpty) {
          return LoadingPage(msg: msg);
        }

        return scaffoldShellBuilder(
          context,
          app,
          responsive,
          page,
        );
      },
    );
  }
}
