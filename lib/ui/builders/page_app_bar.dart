part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Default app bar implementation for the archetype.
///
/// It renders:
///
/// - A title bound to [PageManager.currentTitleStream].
/// - A back button when [PageManager.canPopStream] is `true`.
/// - A [ValueKey] that depends on [hasDrawer] to force correct leading widget.
///
/// ### Usage
///
/// ```dart
/// // Default usage via builder:
/// final PreferredSizeWidget? appBar = PageAppBar.defaultBuilder(
///   context,
///   app,
///   responsive,
///   true, // hasDrawer
/// );
///
/// // Direct usage:
/// final PageAppBar widget = PageAppBar(
///   app: app,
///   responsive: responsive,
///   hasDrawer: true,
/// );
/// ```
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({
    required this.app,
    required this.responsive,
    required this.hasDrawer,
    this.label = 'Back',
    super.key,
  });

  final String label;

  /// Application manager used for navigation and title streams.
  final AppManager app;

  /// Responsive configuration used to compute toolbar height.
  final BlocResponsive responsive;

  /// Whether the surrounding [Scaffold] has a drawer attached.
  ///
  /// This value is embedded into the widget [key] so that Flutter can
  /// correctly recompute the leading icon when the drawer appears or
  /// disappears.
  final bool hasDrawer;

  /// Default builder used by [PageScaffoldShell] and [PageBuilder].
  static PreferredSizeWidget? defaultBuilder(
    BuildContext context,
    AppManager app,
    BlocResponsive responsive,
    bool hasDrawer,
  ) {
    return PageAppBar(
      app: app,
      responsive: responsive,
      hasDrawer: hasDrawer,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(responsive.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: ValueKey<String>('appbar_hasDrawer_$hasDrawer'),
      toolbarHeight: responsive.appBarHeight,
      title: StreamBuilder<String>(
        stream: app.pageManager.currentTitleStream,
        initialData: app.pageManager.currentTitle,
        builder: (
          _,
          __,
        ) {
          final String title = app.pageManager.currentTitle;
          return Text(title);
        },
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
          stream: app.pageManager.canPopStream,
          initialData: app.pageManager.canPop,
          builder: (
            _,
            __,
          ) {
            final bool canPop = app.pageManager.canPop;
            if (!canPop) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: app.pop,
              icon: const Icon(Icons.chevron_left),
              tooltip: label,
            );
          },
        ),
      ],
    );
  }
}
